package Gonzo::Schema::ResultSet::ItemCorrelations;
use strict;
use base 'Gonzo::Schema::ResultSet';

=head1 METHODS

=head2 B<items_rs>

Convenience method for returning the Items from a given B<ItemCorrelations> query.

B<Arguments>: None

B<Returns>: A new B<DBIx::Class::ResultSet> of the selected Items.

=cut

sub items_rs {
    my $self = shift;
    my $items_rs = $self->search_related('item_two', {});
    return $items_rs;
}

1;