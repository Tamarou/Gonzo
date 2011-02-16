package Gonzo::Schema::Result::ItemStatistics;
use Moose;
extends qw( DBIx::Class );

# load the KiokuDB component:
__PACKAGE__->load_components(qw(Core));

# do the normal stuff
__PACKAGE__->table('item_statistics');


__PACKAGE__->add_columns(
	item_id => {
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

__PACKAGE__->set_primary_key(qw(item_id));
__PACKAGE__->belongs_to('item' => 'Gonzo::Schema::Result::Item', 'item_id');

1;

