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

ok( $schema );

my $user_rs       = $schema->resultset('User');
my $item_rs       = $schema->resultset('Item');
my $rating_rs     = $schema->resultset('Rating');
my $item_stats_rs = $schema->resultset('ItemStatistics');
my $user_stats_rs = $schema->resultset('UserStatistics');

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


my $unique_item_ratings = $rating_rs->search({}, { columns => [ qw/item_id/ ], distinct => 1 })->count;

my $unique_user_ratings = $rating_rs->search({}, { columns => [ qw/user_id/ ], distinct => 1 })->count;

cmp_ok( $unique_item_ratings, '>', 0, "At least one rating created.");
cmp_ok( $unique_user_ratings, '>', 0, "At least one rating created.");

cmp_ok( $item_stats_rs->count, '==', $unique_item_ratings, "Correct numnber of Item stat entries created.");

cmp_ok( $user_stats_rs->count, '==', $unique_user_ratings, "Correct numnber of User stat entries created.");


# pick an item with at least one rating
my $random_item = $rating_rs->search({ item_id => int( rand( $faker_conf{item_count} ) + 1 ) })->first->item;

ok( $random_item );

my $avg_by_dbix = $random_item->average_rating;

cmp_ok( $avg_by_dbix, '>', 0, "average rating greater than zero");

my $avg_by_meta = $random_item->metadata->average_rating;

cmp_ok( $avg_by_dbix, '==', $avg_by_meta, "Average item rating identical for DBIX and Metadata class proxy");

done_testing();