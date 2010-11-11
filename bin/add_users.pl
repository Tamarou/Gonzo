#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib qw( ./lib ../../lib );

use Gonzo::Database;
use lib qw( ./lib ../lib );
use Iterator::File::Line;
use Data::Dumper;

my $users_file = "$FindBin::Bin/../../t/data/100k/u.user";

my $i = Iterator::File::Line->new(
    filename => $users_file,
    filter   => sub {
        my @fields =  split(/\|/, $_[0]);

        # see the README
        # user id | age | gender | occupation | zip code
        return {
            external_id     => $fields[0],
            age             => $fields[1],
            gender          => $fields[2],
            occupation      => $fields[3],
            zip_code        => $fields[4],
        };
    },
);

my $db = Gonzo::Database->new(
    dsn => "dbi:SQLite:dbname=$FindBin::Bin/data/test.db",
);

my $schema = $db->get_schema;
my $count = 0;

while (my $pref = $i->next) {
    #warn Dumper( $pref );
    my $user_meta = $db->create_user( $pref );
    $count++;
}

warn "$count users created.\n";
