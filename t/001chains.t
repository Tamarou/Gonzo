use Test::More;
use Try::Tiny;
use FindBin;
use Data::Dumper::Concise;
use lib "$FindBin::Bin/lib";
use_ok('Gonzo::TestTemplate');
use_ok('Gonzo::TestTemplate::FakeData');

my $template = Gonzo::TestTemplate->new( persistent_data => 0 );

my $db = $template->database;
my $schema = $db->get_schema;

ok( $schema );


%faker_conf = (
    user_count => 50,
    item_count => 50,
    ratings_per_user => 20,
);

my $faker = Gonzo::TestTemplate::FakeData->new( database => $db );

$faker->generate_data( \%faker_conf );
$faker->import_data;

my $ic_rs = $schema->resultset('ItemCorrelations');

my $items_rs = $ic_rs->search({})->items_rs;

ok( $items_rs, 'Items resultset fetched via item correlations resultset.' );

isa_ok( $items_rs, 'DBIx::Class::ResultSet', 'Items resultset fetched via item correlations resultset.');

isa_ok( $items_rs->first, 'Gonzo::Schema::Result::Item', 'Returned Items via item correleations rs filter.');

my $ranked_ic_rs = $ic_rs->ranked_by('pearson');

ok( $ranked_ic_rs, 'Ranked IC resultset fetched.' );

isa_ok( $ranked_ic_rs, 'DBIx::Class::ResultSet', 'Ranked IC rs isa ResultSet.');

my $last_val = 10000000;
my $test_flag = undef;

while( my $obj = $ranked_ic_rs->next) {
    my $current_val = $obj->get_column('pearson');
    $test_flag++ if $current_val > $last_val;
    $last_val = $current_val;
}

is( $test_flag, undef, 'Sorting by descending distance value works.');

my $random_item = $schema->resultset('Item')->find( int( rand( $faker_conf{item_count} ) + 1 ));

ok( $random_item, 'Pulled an Item at random.');

# this is the meat.

my $related_items_rs = $ic_rs->search({ item_id_one => $random_item->id })->ranked_by('pearson')->items_rs;

ok( $related_items_rs, 'Related items resultset fetched.' );

isa_ok( $related_items_rs, 'DBIx::Class::ResultSet', 'Ranked IC rs isa ResultSet.');

cmp_ok( $related_items_rs->count, '>', 0, 'At least one related item returned.');

# user correlations
my $user_correlations_rs = $schema->resultset('UserCorrelations');

isa_ok( $user_correlations_rs, 'DBIx::Class::ResultSet', 'Correct resultset class fetched.');

my $users_rs = $user_correlations_rs->search({})->users_rs;

ok( $users_rs, 'Users resultset fetched via correlations resultset.' );

ok( $users_rs->isa('DBIx::Class::ResultSet'), 'Correct user resultset class fetched via users_rs.');

isa_ok( $users_rs->first, 'Gonzo::Schema::Result::User', 'Returned Users via user correleations rs filter.');

my $ranked_user_correlations_rs = $user_correlations_rs->ranked_by('pearson');

ok( $ranked_user_correlations_rs, 'Ranked IC resultset fetched.' );

isa_ok( $ranked_user_correlations_rs, 'DBIx::Class::ResultSet', 'Ranked IC rs isa ResultSet.');

$last_val = 10000000;
$test_flag = undef;

while( my $obj = $ranked_user_correlations_rs->next) {
    my $current_val = $obj->get_column('pearson');
    $test_flag++ if $current_val and $current_val > $last_val;
    $last_val = $current_val;
}

is( $test_flag, undef, 'Sorting by descending distance value works.');

done_testing();