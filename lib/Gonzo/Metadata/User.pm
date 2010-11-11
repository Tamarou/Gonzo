package Gonzo::Metadata::User;
use Moose;
with qw( Gonzo::DataObject );

has external_id => (
    is          => 'ro',
    isa         => 'Int',
    required    => 1,
);

has gender => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has zip_code => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has age => (
    is          => 'ro',
    isa         => 'Int',
    required    => 1,
);

has occupation => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

sub _build_dbix_source_name { 'User'; }


1;