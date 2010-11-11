#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib qw( ./lib ../../lib );
use Carp;
BEGIN { $SIG{__DIE__} = sub { require Carp; Carp::confess(@_) } }

use Gonzo::Database;

my $db = Gonzo::Database->new(
    dsn => "dbi:SQLite:dbname=$FindBin::Bin/data/test.db",
);

my $schema = $db->get_schema;
my $items_rs   = $schema->resultset('Item');

my $item = $items_rs->find(56);

warn sprintf "Looking up by-item recommendations for %s\n", $item->metadata->title;

my @items = $db->recommend_by_item({ item => $item->metadata, threshold => 3 });

foreach my $recd ( @items ) {
    my $recd_meta = $recd->metadata;
    warn sprintf "Recommed %s \n", $recd_meta->title;
}


warn "DONE\n";

