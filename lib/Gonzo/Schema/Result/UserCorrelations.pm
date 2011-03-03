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
	pearson => {
		data_type			=> 'float',
		is_nullable			=> 1,
		default_value		=> 0,
		is_foreign_key		=> 0,
	},
);

__PACKAGE__->add_unique_constraints([ qw/user_id_one user_id_two/ ]);

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $sqlt_table->add_index(
        name => 'idx_user_correlations_user_id_one',
        fields => ['user_id_one']
    );
    $sqlt_table->add_index(
        name => 'idx_user_correlations_user_id_two',
        fields => ['user_id_two']
    );
}


1;

