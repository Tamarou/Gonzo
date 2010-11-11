#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib qw( ./lib );

use Gonzo::Database;
use Gonzo::Schema;
use lib qw( ./lib ../lib );
use Data::Dumper;

my $db = Gonzo::Database->new(
    dsn => "dbi:SQLite:dbname=$FindBin::Bin/data/test.db",
);

my $schema = $db->get_schema;
#$schema->storage->debug(1);

my $ratings_rs = $schema->resultset('Rating')->search({}, {order_by => { -asc => 'me.user_id'} } );

my %users = ();
my %items = ();

my $count = 0;

while (my $rating = $ratings_rs->next ) {
    my ( $user, $item ) = (undef, undef );

    if ( defined( $users{$rating->user_id} )) {
        $user = $users{$rating->user_id};
    }
    else {
        $user = $rating->user;
        $users{ $user->id } = $user;
    }

    if ( defined( $items{$rating->item_id} )) {
        $item = $items{$rating->item_id};
    }
    else {
        $item = $rating->item;
        $items{ $item->id } = $item;
    }

    print "($count) XXX Processing rating uid/iid: " . $user->id .  " " . $item->id . "\n";
    $db->update_rating_aggregates( $user, $item );
    $count++;
}

warn "DONE\n";