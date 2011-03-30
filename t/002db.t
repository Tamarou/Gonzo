use Test::More;
use Try::Tiny;
use FindBin;
use lib "$FindBin::Bin/lib";
use_ok('Gonzo::TestTemplate');
use_ok('Gonzo::Database');

my $template = Gonzo::TestTemplate->new;

# defaults to in-memory storage
my $db = Gonzo::Database->new(
    dsn => $template->db_dsn_memory,
    similarity_factory => $template->similarity_pearson,
    bootstrap => 1,
);

ok( $db, "Database created" );
isa_ok( $db, 'Gonzo::Database', 'DB object is what we expect.');

my $schema = $db->get_schema;

ok( $schema, "Schema object fetched" );
isa_ok( $schema, 'Gonzo::Schema', 'Schema object is what we expect.');

my $kioku = $db->kioku_dir;

ok( $kioku, "KiokuDB object fetched" );
isa_ok( $kioku, 'KiokuDB', 'KiokuDB object is what we expect.');

$schema->deploy({ add_drop_table => 1 });

# check that the tables were created and the resultsets work

my $entries_rs = $schema->resultset('entries');
ok( $entries_rs, "KiokuDB 'entries' resultset fetched" );
isa_ok( $entries_rs, 'DBIx::Class::ResultSet', "KiokuDB 'entries' resultset object is what we expect.");

my $user_rs = $schema->resultset('User');
ok( $user_rs, "Users resultset fetched" );
isa_ok( $user_rs, 'DBIx::Class::ResultSet', "User resultset object is what we expect.");

my $item_rs = $schema->resultset('Item');
ok( $item_rs, "Item resultset fetched" );
isa_ok( $item_rs, 'DBIx::Class::ResultSet', "Item resultset object is what we expect.");

my $rating_rs = $schema->resultset('Rating');
ok( $rating_rs, "Rating resultset fetched" );
isa_ok( $rating_rs, 'DBIx::Class::ResultSet', "Rating resultset object is what we expect.");

my $aggregate_rs = $schema->resultset('RatingAggregate');
ok( $aggregate_rs, "Rating Agrregate resultset fetched" );
isa_ok( $aggregate_rs, 'DBIx::Class::ResultSet', "User resultset object is what we expect.");

done_testing();


