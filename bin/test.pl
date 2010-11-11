#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib qw( ./lib );

use KiokuDB;
use Gonzo::Metadata::User;
use Gonzo::Metadata::Item;
use Data::Dumper;

my $dir = KiokuDB->connect(
    "dbi:SQLite:dbname=$FindBin::Bin/data/test.db",
    schema => 'Gonzo::Schema',
    create => 1,
);

my $schema = $dir->backend->schema;

my $user_meta = Gonzo::Metadata::User->new( username => 'ubu', id => 666 );
my $item_meta = Gonzo::Metadata::Item->new( name => 'Widget' );

my $uid = undef;
my $iid = undef;

$dir->txn_do(scope => 1, body => sub {
    my $user = $schema->resultset('User')->create({
        metadata => $user_meta,
    });

    my $item = $schema->resultset('Item')->create({
        metadata => $item_meta,
    });

    warn "user is " . $user->id . "\n";
    warn "item is " . $item->id . "\n";

    $uid = $user->id;
    $iid = $item->id;

    $user->add_to_ratings({ item_id => $iid, rating => 4 });
#     my $rating = $schema->resultset('Ratings')->create({
#         user_id => $uid,
#         item_id => $iid,
#         rating  => 4,
#     });

});

my $fetched_user = $schema->resultset('User')->find( $uid );
my $fetched_item = $schema->resultset('Item')->find( $iid );
my $fetched_rating = $schema->resultset('Rating')->search({ user_id => $uid })->first;

warn "found User ID " . $fetched_user->id . "\n";
warn "found User UNAME " . $fetched_user->metadata->username . "\n";
warn "found Item ID " . $fetched_item->metadata->name . "\n";
warn "found Rating "  . $fetched_rating->timestamp . " " . $fetched_rating->rating . "\n";


