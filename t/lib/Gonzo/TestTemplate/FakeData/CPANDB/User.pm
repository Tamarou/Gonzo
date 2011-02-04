package Gonzo::TestTemplate::FakeData::CPANDB::User;
use Moose;
with qw( Gonzo::DataObject );

has external_id => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has cpan_id => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has name => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

sub _build_dbix_source_name { 'User'; }


1;