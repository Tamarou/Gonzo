package Gonzo::Schema::Result::Item;
use Moose;
extends qw( DBIx::Class );

# load the KiokuDB component:
__PACKAGE__->load_components(qw(Core KiokuDB));

# do the normal stuff
__PACKAGE__->table('items');


__PACKAGE__->add_columns(
	id => {
		data_type			=> 'bigint',
		size				=> 20,
		is_nullable			=> 0,
		default_value		=> undef,
		is_auto_increment	=> 1,
		is_foreign_key		=> 0,
		extra				=> { unsigned => 1 }
	},
	metadata => {
        data_type           => 'varchar',
        is_nullable         => 1,
    },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->kiokudb_column('metadata');

=head1 METHODS

=head2 B<average_rating()>

Retrieve the average user rating for this item.

B<Arguments>: [none]

B<Returns>: A float representing the raw aggregate average rating for this item.

=cut

sub average_rating {
    my $self = shift;
    my $data = $self->result_source->schema->resultset('Rating')->search(
        { item_id => $self->id },
        {
            '+select' => [ { avg => 'rating', -as => 'average_rating' } ],
            '+as' => qw/average_rating/,
        }
    )->single;

    return $data->get_column('average_rating') || '0';
}

1;

