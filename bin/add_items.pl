#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib qw( ./lib ../../lib);

use Gonzo::Database;
use lib qw( ./lib ../lib );
use Iterator::File::Line;
use Data::Dumper;

my $movies_file = "$FindBin::Bin/../../t/data/100k/u.item";

my $i = Iterator::File::Line->new(
    filename => $movies_file,
    filter   => sub {
        my @fields =  split(/\|/, $_[0]);

        # see the MovieLens README
        # movie id | movie title | release date | video release date | IMDb URL | unknown | Action | Adventure | Animation | Children's | Comedy | Crime | Documentary | Drama | Fantasy | Film-Noir | Horror | Musical | Mystery | Romance | Sci-Fi | Thriller | War | Western |

        my @genres = @fields[5..24];
        return {
            external_id     => $fields[0],
            title           => $fields[1],
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
    my $item_meta = $db->create_item( $pref );

    $count++;
}

warn "$count items created.\n";
