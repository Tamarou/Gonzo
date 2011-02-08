package Gonzo;
# ABSTRACT: As your attorney I advise you to rent a very fast car with no top.
use Moose;
with qw( Gonzo::Common );

use Gonzo::Database;

has database => (
    is          => 'ro',
    isa         => 'Gonzo::Database',
    lazy        => 1,
    builder     => '_build_database',
);

sub _build_database {
    my $self = shift;
    my $args = $self->config->fetch('database');
    return Gonzo::Database->new( %{$args} );
}

1;
