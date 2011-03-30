package Gonzo::Schema;
use Moose;
with qw(Gonzo::Common);
extends qw(DBIx::Class::Schema);
use Carp;
use Gonzo::Exception;

has similarity_factory => (
    is          => 'rw',
    isa         => 'Gonzo::SimilarityFactory',
);

__PACKAGE__->load_components(qw(Core Schema::KiokuDB));
__PACKAGE__->exception_action(sub { Gonzo::Exception->throw(@_) });
__PACKAGE__->load_namespaces;

before 'connect' => sub {
    my $self = shift;
    my $user_correlations_source = $self->source('UserCorrelations');
    my $item_correlations_source = $self->source('ItemCorrelations');

    my $map = $self->similarity_factory->similarity_classes;
    foreach my $key ( keys ( %{$map} )) {
        my $sim = $map->{$key};
        $item_correlations_source->add_column( $sim->column_name => $sim->column_info );
        $user_correlations_source->add_column( $sim->column_name => $sim->column_info );
    }
};

after 'deploy' => sub {
    my $self = shift;
    $self->log->debug("Schema deployment completed");
};

1;