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

1;

