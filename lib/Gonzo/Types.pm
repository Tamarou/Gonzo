package Gonzo::Types;
use Moose::Role;
use Moose::Util::TypeConstraints;
use Data::Dumper::Concise;

subtype 'SimilarityClassMap'
    => as 'HashRef[Str]';

no Moose::Util::TypeConstraints;
1;