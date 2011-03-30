use Test::More;
use Try::Tiny;
use Data::Dumper::Concise;

use_ok('Gonzo::SimilarityFactory');


my $factory = Gonzo::SimilarityFactory->new(
    classmap => { pearson => 'Gonzo::Similarity::Pearson', },
);

ok( $factory );

#warn Dumper( $factory );
#ok( 1 == 2 );

done_testing();
