#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib qw( ./lib );

use Gonzo::Database;
use lib qw( ./lib ../lib );

my $db = Gonzo::Database->new(
    dsn => "dbi:SQLite:dbname=$FindBin::Bin/data/test.db",
);

my $schema = $db->get_schema;

#$schema->txn_do( sub {
my $users_rs   = $schema->resultset('User');
my $items_rs   = $schema->resultset('Item');
my $ratings_rs = $schema->resultset('Rating');

my $user = $users_rs->find( 23 );

my $item = $items_rs->find(204);
#});

$user->metadata->rate_item( item => $item, rating => 4 );


warn "DONE\n";

