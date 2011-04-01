package Gonzo::Schema::ResultSet;
use strict;
use base 'DBIx::Class::ResultSet';

sub ranked {
    my $self = shift;
    my $col_name = shift;
    return $self->search({}, { order_by => { -desc => $col_name }} );
}

1;