package Gonzo::Schema::ResultSet::UserCorrelations;
use strict;
use warnings;
use base 'Gonzo::Schema::ResultSet';

sub users_rs {
    my $self = shift;
    my $obj_rs = $self->search_related('user_two', {});
    return $obj_rs;
}

1;