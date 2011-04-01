package Gonzo::Schema::Result::ItemCorrelations;
use Moose;
extends qw( DBIx::Class );

__PACKAGE__->load_components(qw(Core));

# do the normal stuff
__PACKAGE__->table('item_correlations');


__PACKAGE__->add_columns(
	item_id_one => {
		data_type			=> 'bigint',
		size				=> 20,
		is_nullable			=> 0,
		default_value		=> undef,
		is_foreign_key		=> 1,
		extra				=> { unsigned => 1 }
	},
	item_id_two => {
		data_type			=> 'bigint',
		size				=> 20,
		is_nullable			=> 0,
		default_value		=> undef,
		is_foreign_key		=> 1,
		extra				=> { unsigned => 1 }
	},
);

__PACKAGE__->add_unique_constraints([ qw/item_id_one item_id_two/ ]);

__PACKAGE__->belongs_to('item_one' => 'Gonzo::Schema::Result::Item', 'item_id_one');

__PACKAGE__->belongs_to('item_two' => 'Gonzo::Schema::Result::Item', 'item_id_two');

=head1 METHODS

=head2 B<sqlt_deploy_hook>

Internal use only. Deployment hook for adding similarity engine columns during deployment.

=cut


sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    my $factory = $self->schema->similarity_factory;
    my $map = $factory->similarity_classes;
    foreach my $key ( keys ( %{$map} )) {
        my $sim = $map->{$key};
        $self->add_column( $sim->column_name => $sim->column_info );
        my $column_info = $sim->column_info;
        $column_info->{name} = $sim->column_name;
        $sqlt_table->add_field( %$column_info );
    }

#     $sqlt_table->add_index(
#         name => 'idx_item_correlations_item_id_one',
#         fields => ['item_id_one']
#     );
#     $sqlt_table->add_index(
#         name => 'idx_item_correlations_item_id_two',
#         fields => ['item_id_two']
#     );
}


1;

