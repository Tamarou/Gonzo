use Test::More;
use Try::Tiny;
use FindBin;
use lib "$FindBin::Bin/lib";
use_ok('Gonzo::TestTemplate');

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

ok( $schema->source('ItemCorrelations')->has_column('pearson'), "Pearson column added to Item correlations table.");

done_testing();


