package Gonzo;
# ABSTRACT: As your attorney I advise you to rent a very fast car with no top.
use Moose;
with qw( Gonzo::Common Gonzo::Types);

use Gonzo::Database;
use Gonzo::Exception;
use Gonzo::SimilarityFactory;

has config => (
    isa         => 'Config::Path',
    is          => 'ro',
    lazy        => 1,
    builder     => '_build_config',
);

has config_file => (
    isa         => 'Str',
    is          => 'ro',
    predicate   => 'has_config_file',
);

has database => (
    is          => 'ro',
    isa         => 'Gonzo::Database',
    lazy_build  => 1,
);

has bootstrap_db => (
    traits  => ['Bool'],
    is          => 'ro',
    isa         => 'Bool',
    default     => 0,
);

sub _build_database {
    my $self = shift;
    my $args = $self->config->fetch('database');
    $args->{bootstrap} = 1 if $self->bootstrap_db;
    $args->{similarity_factory} = $self->similarity_factory;

    $args->{user_metadata_class} ||= $self->user_metadata_class;
    $args->{item_metadata_class} ||= $self->item_metadata_class;
    return Gonzo::Database->new( %{$args} );
}

has similarity_factory => (
    is          => 'ro',
    isa         => 'Gonzo::SimilarityFactory',
    lazy_build  => 1,
);

sub _build_similarity_factory {
    my $self = shift;
    my $args = $self->config->fetch('similarity');
    return Gonzo::SimilarityFactory->new( %{$args} );
}

sub _build_config {
    my $self = shift;
    return undef unless $self->has_config_file;
    return Config::Path->new( files => [ $self->config_file ] );
}

1;
