#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib qw( ./lib ../../lib );

use Gonzo::Database;
use Data::Dumper;

my $db = Gonzo::Database->new(
    dsn       => "dbi:SQLite:dbname=$FindBin::Bin/data/test.db",
    bootstrap => 1,
);

my $schema = $db->get_schema;

$schema->deploy({ add_drop_table => 1 });

exit(0);



