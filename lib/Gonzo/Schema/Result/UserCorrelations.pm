package Gonzo::Schema::Result::UserCorrelations;
use Moose;
extends qw( DBIx::Class );

__PACKAGE__->load_components(qw(Core));

# do the normal stuff
__PACKAGE__->table('user_correlations');


__PACKAGE__->add_columns(
	user_id_one => {
		data_type			=> 'bigint',
		size				=> 20,
		is_nullable			=> 0,
		default_value		=> undef,
		is_foreign_key		=> 1,
		extra				=> { unsigned => 1 }
	},
	user_id_two => {
		data_type			=> 'bigint',
		size				=> 20,
		is_nullable			=> 0,
		default_value		=> undef,
		is_foreign_key		=> 1,
		extra				=> { unsigned => 1 }
	},
);


__PACKAGE__->belongs_to('user_one' => 'Gonzo::Schema::Result::User', 'user_id_one');

__PACKAGE__->belongs_to('user_two' => 'Gonzo::Schema::Result::User', 'user_id_two');

__PACKAGE__->add_unique_constraints([ qw/user_id_one user_id_two/ ]);

__PACKAGE__->resultset_class('Gonzo::Schema::ResultSet::UserCorrelations');

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
#         name => 'idx_user_correlations_user_id_one',
#         fields => ['user_id_one']
#     );
#     $sqlt_table->add_index(
#         name => 'idx_user_correlations_user_id_two',
#         fields => ['user_id_two']
#     );
}


1;

