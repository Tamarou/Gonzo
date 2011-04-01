package Gonzo::Schema::ResultSet::ItemCorrelations;
use strict;
use base 'Gonzo::Schema::ResultSet';

sub items_rs {
    my $self = shift;
    my $items_rs = $self->search_related('item_two', {});
    return $items_rs;
}

1;