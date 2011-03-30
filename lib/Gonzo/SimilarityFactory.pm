package Gonzo::SimilarityFactory;
use Moose;
with qw( Gonzo::Types );

use Gonzo::Exception;
use Data::Dumper::Concise;

has similarity_classes => (
    traits      => ['Hash'],
    is          => 'ro',
    isa         => 'HashRef[Object]',
    builder     => '_build_similarity_classes',
    required    => 1,
    handles     => {
          set_similarity    => 'set',
          get_similarity    => 'get',
          has_similarity    => 'defined',
      },
);



sub _build_similarity_classes {
    my $self = shift;
    my $ret = {};
    my $map = $self->similarity_classmap;
    my $base = $self->similarity_namespace;

    foreach my $key ( keys ( %$map )) {
        Class::MOP::load_class( $map->{$key} );
        $ret->{$key} = $map->{$key}->new;
    }
    return $ret;
}

has similarity_classmap => (
    is          => 'ro',
    isa         => 'SimilarityClassMap',
    builder  => '_build_similarity_classmap',
    required    => 1,
    init_arg    => 'classmap',
    #coerce      => 1,
);

sub _build_similarity_classmap {
    my $self = shift;

    unless ( $self->can('config') ) {
        Gonzo::Exception->throw("You must either pass a 'classmap' argument or set a config object that implements that option.");
    }
    return $self->config->fetch('classmap');
}

has similarity_namespace => (
    is          => 'ro',
    required    => 1,
    init_arg    => 'namespace',
    default     => sub{ 'Gonzo::Similarity' },
);

1;