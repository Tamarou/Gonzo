use Test::More;
use Try::Tiny;
use FindBin;
use Data::Dumper;
use lib "$FindBin::Bin/lib";
use_ok('Gonzo::TestTemplate');

my $template = Gonzo::TestTemplate->new( persistent_data => 0 );

my $gonzo = $template->new_gonzo;

ok( $gonzo, "Gonzo object created." );

my $db = $gonzo->database;

ok( $db, "Database created" );
isa_ok( $db, 'Gonzo::Database', 'DB object is what we expect.');

my $schema = $db->get_schema;

ok( $schema );

my $user_data = {
    external_id => 1313,
    gender      => 'F',
    zip_code    => 60609,
    age         => 900,
    occupation  => 'Time Lord',
};

my $item_data = {
    title       => 'The 400 Blows',
    external_id => 400,
};

my $item_data2 = {
    title       => 'BioDome',
    external_id => 666,
};

my $user_rs      = $schema->resultset('User');
my $item_rs      = $schema->resultset('Item');
my $rating_rs    = $schema->resultset('Rating');
my $aggregate_rs = $schema->resultset('RatingAggregate');

# user object tests
my $user_meta = $db->create_user( $user_data );

ok( $user_meta, 'User created.');
isa_ok( $user_meta, 'Gonzo::Metadata::User', 'Default user metadata object is what we expect.');

cmp_ok( $user_rs->count, '==', 1, 'New User found in DBIC table.');

can_ok( $user_meta, 'dbix_row');

my $user_row = $user_meta->dbix_row;

ok( $user_row, 'User DBIC Row available via dbix_row.');

isa_ok( $user_row, 'Gonzo::Schema::Result::User', 'User DBIC Row belongs to the class we expect.');

my $user_row2 = $user_rs->search({})->first;

ok( $user_row2, 'User DBIC Row available via resultset search.');

cmp_ok( $user_row->id, '==', $user_row2->id, 'DBIC resultset search and metadata dbix_row method return the same Row');

my $user_meta2 = $user_row2->metadata;

ok( $user_meta2, 'User fetched via DBIC Row metadata method.');
isa_ok( $user_meta2, 'Gonzo::Metadata::User', 'dbix-fetched user metadata object is what we expect.');

foreach my $key ( keys( %{$user_data} )) {
    ok( $user_meta->$key eq $user_data->{$key} && $user_meta->$key eq $user_meta2->$key, "User data matches for $key");
}


# item object tests
my $item_meta = $db->create_item( $item_data );

ok( $item_meta, 'Item created.');
isa_ok( $item_meta, 'Gonzo::Metadata::Item', 'Default Item metadata object is what we expect.');

cmp_ok( $item_rs->count, '==', 1, 'New Item found in DBIC table.');

can_ok( $item_meta, 'dbix_row');

my $item_row = $item_meta->dbix_row;

ok( $item_row, 'Item DBIC Row available via dbix_row.');

isa_ok( $item_row, 'Gonzo::Schema::Result::Item', 'Item DBIC Row belongs to the class we expect.');

my $item_row2 = $item_rs->search({})->first;

ok( $item_row2, 'Item DBIC Row available via resultset search.');

cmp_ok( $item_row->id, '==', $item_row2->id, 'DBIC resultset search and metadata dbix_row method return the same Row');

my $item_meta2 = $item_row2->metadata;

ok( $item_meta2, 'Item fetched via DBIC Row metadata method.');
isa_ok( $item_meta2, 'Gonzo::Metadata::Item', 'dbix-fetched Item metadata object is what we expect.');

foreach my $key ( keys( %{$item_data} )) {
    ok( $item_meta->$key eq $item_data->{$key} && $item_meta->$key eq $item_meta2->$key, "Item data matches for $key");
}

# rating tests.

my $rating = $db->rate_item({ user => $user_meta, item => $item_meta, rating_value => 5 });

ok( $rating, 'Rating Row obj returned from rate_item.');
isa_ok( $rating, 'Gonzo::Schema::Result::Rating', 'Rating DBIC Row belongs to the class we expect.');

# aggregate tests

my $item2_meta = $db->create_item( $item_data2 );

ok( $item2_meta, 'Second Item created.');

my $rating2 = $db->rate_item({ user => $user_meta, item => $item2_meta, rating_value => 1 });

ok( $rating2, 'Second Rating created.');

$db->update_item_statistics;
$db->update_item_correlations;
$db->update_user_statistics;
$db->update_user_correlations;

#cmp_ok( $aggregate_rs->search({})->count, '==', 2, 'Two rating aggregates added.');

done_testing();