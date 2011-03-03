package Gonzo::Schema::Result::UserStatistics;
use Moose;
extends qw( DBIx::Class );

__PACKAGE__->load_components(qw(Core));

# do the normal stuff
__PACKAGE__->table('user_statistics');


__PACKAGE__->add_columns(
	user_id => {
		data_type			=> 'bigint',
		size				=> 20,
		is_nullable			=> 0,
		default_value		=> undef,
		is_foreign_key		=> 1,
		extra				=> { unsigned => 1 }
	},
	count => {
		data_type			=> 'int',
		size				=> 20,
		is_nullable			=> 1,
		default_value		=> 0,
		is_foreign_key		=> 0,
	},
	mean => {
		data_type			=> 'float',
		is_nullable			=> 1,
		default_value		=> 0,
		is_foreign_key		=> 0,
	},
	stddev => {
		data_type			=> 'float',
		is_nullable			=> 1,
		default_value		=> 0,
		is_foreign_key		=> 0,
	},

);

__PACKAGE__->set_primary_key(qw(user_id));
__PACKAGE__->belongs_to('item' => 'Gonzo::Schema::Result::User', 'user_id');

1;

