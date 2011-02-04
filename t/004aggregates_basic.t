use Test::More;
use Try::Tiny;
use FindBin;
use Data::Dumper;
use lib "$FindBin::Bin/lib";
use_ok('Gonzo::TestTemplate');
use_ok('Gonzo::TestTemplate::FakeData');

my $template = Gonzo::TestTemplate->new( persistent_data => 1, db_args => {bootstrap => 1});

my $db = $template->database;
my $schema = $db->get_schema;

my $user_rs      = $schema->resultset('User');
my $item_rs      = $schema->resultset('Item');
my $rating_rs    = $schema->resultset('Rating');
my $aggregate_rs = $schema->resultset('RatingAggregate');

%faker_conf = (
    user_count => 50,
    item_count => 50,
    ratings_per_user => 20,
);

my $faker = Gonzo::TestTemplate::FakeData->new( database => $db );

$faker->generate_data( \%faker_conf );
$faker->import_data;

# basic integrity checks first
cmp_ok( $user_rs->count, '==', $faker_conf{user_count}, "Correct numnber of users created.");

cmp_ok( $item_rs->count, '==', $faker_conf{item_count}, "Correct numnber of items created.");

cmp_ok( $rating_rs->count, '==', $faker_conf{user_count} * $faker_conf{ratings_per_user}, "Correct numnber of ratings created.");


my $unique_ratings = $rating_rs->search({}, { columns => [ qw/item_id/ ], distinct => 1 })->count;

# aggregates count should be total rated items squared minus total rated items
# since we never calculate the average rating diff between an object and itself.
cmp_ok( $aggregate_rs->count, '==', $unique_ratings ** 2 - $unique_ratings, "Correct numnber of aggregates created.");

# pick an item with at least one rating
my $random_item = $rating_rs->search({ item_id => int( rand( $faker_conf{item_count} ) + 1 ) })->first->item;

ok( $random_item );

my $avg_by_dbix = $random_item->average_rating;

cmp_ok( $avg_by_dbix, '>', 0, "average rating greater than zero");

my $avg_by_meta = $random_item->metadata->average_rating;

cmp_ok( $avg_by_dbix, '==', $avg_by_meta, "Average item rating identical for DBIX and Metadata class proxy");

#warn sprintf "THING %s and THING %s\n", $avg_by_dbix, $avg_by_meta;

done_testing();

=cut





