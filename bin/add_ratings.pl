#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib qw( ./lib ../../lib);
use Carp;
BEGIN { $SIG{__DIE__} = sub { Carp::confess(@_) } }

use Gonzo::Database;
use lib qw( ./lib ../lib );
use Iterator::File::Line;
use Data::Dumper;

my $ratings_file = "$FindBin::Bin/../../t/data/100k/u.data";

my $i = Iterator::File::Line->new(
    filename => $ratings_file,
    filter   => sub {
        my @fields =  split(/\t/, $_[0]);

        # see the MovieLens README
        return {
            user_id     => $fields[0],
            title_id    => $fields[1],
            rating      => $fields[2],
        };
    },
);

my $db = Gonzo::Database->new(
    dsn => "dbi:SQLite:dbname=$FindBin::Bin/data/test.db",
);

my $schema = $db->get_schema;

my $users_rs   = $schema->resultset('User');
my $items_rs   = $schema->resultset('Item');
my $ratings_rs = $schema->resultset('Rating');

my %seen_users = ();
my %seen_items = ();
my $count = 0;

#my $s = $db->kioku_dir->new_scope;

#$db->kioku_dir->txn_do(scope => 1, body => sub {
    # external index IDs don't match so do a lookup
    while (my $pref = $i->next) {
        warn "count $count\n" if $count % 100 == 1;
        last if $count == 10000;

        #my ($user_meta, $item_meta) = (undef, undef);

        # this is fugly. Can revisit via custom resultset class or just
        # by adding the external ID to the DBIC tables.
        my $user_meta = $seen_users{$pref->{user_id}} || ($db->search_metadata({
            external_id => $pref->{user_id},
            class       => 'Gonzo::Metadata::User',
        })->all)[0];

        my $item_meta = ($db->search_metadata({
            external_id => $pref->{title_id},
            class       => 'Gonzo::Metadata::Item',
        })->all)[0];



        $db->rate_item({ user => $user_meta, item => $item_meta, rating => $pref->{rating} });
        $count++;
    }
#});

warn "$count ratings added.\n";
