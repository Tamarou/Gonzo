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
my $user_rs   = $schema->resultset('User');

my $user = $user_rs->find(57);

warn sprintf "Looking up by-user recommendations for %s\n", $user->metadata;

my @items = $db->recommend_for_user({ user => $user->metadata });

foreach my $recd ( @items ) {
    my $recd_meta = $recd->metadata;
    warn sprintf "Recommed %s \n", $recd_meta->title;
}


warn "DONE\n";

