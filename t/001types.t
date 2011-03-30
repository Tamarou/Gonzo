use Test::More;
use Try::Tiny;

use_ok('Gonzo::Common');

{
package Testy;
use Moose;
with qw(Gonzo::Common);

has typemap => (
    is  => 'ro',
    isa => 'SimilarityClassMap',
);
__PACKAGE__->meta->make_immutable();

1;
}

my $o = Testy->new( classmap => { pearson => 'Gonzo::Similarity::Pearson' } );

ok( $o );

done_testing();
