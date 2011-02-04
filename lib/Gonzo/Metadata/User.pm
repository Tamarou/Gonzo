package Gonzo::Metadata::User;
use Moose;
with qw( Gonzo::DataObject );

has external_id => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has username => (
    is          => 'ro',
    isa         => 'Str',

);

has cpan_id => (
    is          => 'ro',
    isa         => 'Str',

);

has gender => (
    is          => 'ro',
    isa         => 'Str',

);

has zip_code => (
    is          => 'ro',
    isa         => 'Str',

);

has age => (
    is          => 'ro',
    isa         => 'Int',

);

has occupation => (
    is          => 'ro',
    isa         => 'Str',
);

sub _build_dbix_source_name { 'User'; }


1;