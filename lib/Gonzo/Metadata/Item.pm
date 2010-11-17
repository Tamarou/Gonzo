package Gonzo::Metadata::Item;
use Moose;
with qw( Gonzo::DataObject );

has external_id => (
    is          => 'ro',
    isa         => 'Int',
);

has title => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

sub _build_dbix_source_name { 'Item'; }

=head1 METHODS

=head2 B<average_rating()>

Retrieve the average user rating for this item.

B<Arguments>: [none]

B<Returns>: A float representing the raw aggregate average rating for this item.

Note: this method is simply a proxy to a method of the same name in L<Gonzo::Schema::Result::Item>.

=cut

sub average_rating {
    my $self = shift;
    return $self->dbix_row->average_rating;
}

1;