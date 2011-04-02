package Gonzo::Schema::ResultSet;
use strict;
use base 'DBIx::Class::ResultSet';

=head1 METHODS

=head2 B<ranked_by($similarity_column_name)>

Convenience method for selecting users and items ordered by a given similairty measure. For use with the B<ItemCorrelations> and B<UserCorrelations> queries.

B<Arguments>: The name of the column to be used when calculating similarity.

B<Returns>: The filtered B<DBIx::Class::ResultSet>.

=cut

sub ranked_by {
    my $self = shift;
    my $col_name = shift;
    return $self->search({}, { order_by => { -desc => $col_name }} );
}

1;