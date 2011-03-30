use Test::More;
use Try::Tiny;
use FindBin;
use Data::Dumper;
use lib "$FindBin::Bin/lib";
use_ok('Gonzo::TestTemplate');
use_ok('Gonzo::TestTemplate::FakeData');

my $template = Gonzo::TestTemplate->new( persistent_data => 0, db_args => {bootstrap => 1});

my $db = $template->database;
my $schema = $db->get_schema;

my $user_rs      = $schema->resultset('User');
my $item_rs      = $schema->resultset('Item');
my $rating_rs    = $schema->resultset('Rating');

%faker_conf = (
    user_count => 50,
    item_count => 50,
    ratings_per_user => 20,
);

my $faker = Gonzo::TestTemplate::FakeData->new( database => $db );

$faker->generate_data( \%faker_conf );
$faker->import_data;

# basic integrity checks first
cmp_ok( $user_rs->count, '==', $faker_conf{user_count}, "Correct number of users created.");

cmp_ok( $item_rs->count, '==', $faker_conf{item_count}, "Correct number of items created.");

cmp_ok( $rating_rs->count, '==', $faker_conf{user_count} * $faker_conf{ratings_per_user}, "Correct numnber of ratings created.");


done_testing();

=cut





