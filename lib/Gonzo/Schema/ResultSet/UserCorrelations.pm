package Gonzo::Schema::ResultSet::UserCorrelations;
use strict;
use warnings;
use base 'Gonzo::Schema::ResultSet';

=head1 METHODS

=head2 B<users_rs>

Convenience method for returning the Users from a given B<UserCorrelations> query.

B<Arguments>: None

B<Returns>: A new B<DBIx::Class::ResultSet> of the selected Users.

=cut

sub users_rs {
    my $self = shift;
    my $obj_rs = $self->search_related('user_two', {});
    return $obj_rs;
}

1;