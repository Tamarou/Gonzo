#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../t/lib";

use Gonzo;
use Try::Tiny;
use CPANDB;
use CPANDB::Distribution;
use Data::Dumper;

my $conf_file = shift;

my $gonzo = Gonzo->new(
    config_file => $conf_file,
    user_metadata_class => 'Gonzo::TestTemplate::FakeData::CPANDB::User',
    item_metadata_class => 'Gonzo::TestTemplate::FakeData::CPANDB::Item'
);

my $db = $gonzo->database;
my $schema = $db->get_schema;


my $user_rs      = $schema->resultset('User');
my $item_rs      = $schema->resultset('Item');
my $rating_rs    = $schema->resultset('Rating');
my $aggregate_rs = $schema->resultset('RatingAggregate');


CPANDB->import();

my %seen_users = ();
my %seen_items = ();
my $stats = {};

# users first
foreach my $user ( CPANDB::Author->select ) {
    my $data = {
        external_id => $user->author,
        cpan_id     => $user->author,
        name        => $user->name,
    };

    my $user_meta = $db->create_user( $data );
    $seen_users{ $data->{external_id} } = $user_meta;
    $stats->{users}++;
}

# now dists
foreach my $dist ( CPANDB::Distribution->select ) {
    my $data = {
        external_id     => $dist->distribution,
        distribution    => $dist->distribution,
        author          => $dist->author,
        release          => $dist->release,

    };

    my $dist_meta = $db->create_item( $data );
    $seen_items{ $data->{external_id} } = $dist_meta;
    $stats->{items}++;
}


my $id_counter = 0;

foreach my $dist_id ( keys( %seen_items ) ) {
    my $dist = $seen_items{$dist_id};
    my $user = $seen_users{ $dist->author };
    my @deps = CPANDB::Dependency->select(
        'where distribution = ?',
        $dist->distribution,
    );

    foreach my $dep ( @deps ) {
        next if $dep->dependency eq 'perl';
        my $dependent_dist = $seen_items{ $dep->dependency };

        unless (defined( $dependent_dist )) {
            warn sprintf "Couldn't find a dist for %s, skipping\n", $dep->dependency;
            next;
        }

        #warn sprintf "Adding vote for %s from user %s \n", $dependent_dist->distribution, $user->cpan_id;

        $db->rate_item({
            user => $user,
            item => $dependent_dist,
            rating_value => 1
        });
    }
}