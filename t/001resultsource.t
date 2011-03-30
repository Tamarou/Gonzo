use Test::More;
use Try::Tiny;
use FindBin;
use Data::Dumper::Concise;
use lib "$FindBin::Bin/lib";
use_ok('Gonzo::TestTemplate');
use_ok('Gonzo::TestTemplate::FakeData');

{
my $template = Gonzo::TestTemplate->new( persistent_data => 1, db_args => {bootstrap => 1});

my $db = $template->database;
my $schema = $db->get_schema;

ok( $schema->resultset('UserCorrelations')->result_source->has_column('pearson'), 'Pearson column visible for User correlations via resultset source when bootstrapping.');

ok( $schema->resultset('ItemCorrelations')->result_source->has_column('pearson'), 'Pearson column visible for Item correlations via resultset source when bootstrapping.');

$template   = undef;
$db         = undef;
$schema     = undef;
}


{
$template = Gonzo::TestTemplate->new( persistent_data => 1 );

my $db = $template->database;
my $schema = $db->get_schema;

ok( $schema->resultset('UserCorrelations')->result_source->has_column('pearson'), 'Pearson column visible for User correlations via resultset source when NOT bootstrapping.');

ok( $schema->resultset('ItemCorrelations')->result_source->has_column('pearson'), 'Pearson column visible for Item correlations via resultset source when NOT bootstrapping.');
}

done_testing();





