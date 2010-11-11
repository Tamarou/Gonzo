package Gonzo::Metadata::Item;
use Moose;
with qw( Gonzo::DataObject );

has external_id => (
    is          => 'ro',
    isa         => 'Int',
    required    => 1,
);

has title => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

sub _build_dbix_source_name { 'Item'; }

1;