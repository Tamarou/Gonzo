package Gonzo::Schema::Result::RatingAggregate;
use Moose;
extends qw( DBIx::Class );

__PACKAGE__->load_components(qw(Core));

__PACKAGE__->table('rating_aggregates');


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
	count => {
		data_type			=> 'bigint',
		size				=> 20,
		is_nullable			=> 1,
		default_value		=> 0,
		is_foreign_key		=> 0,
	},
	sum => {
		data_type			=> 'bigint',
		size				=> 20,
		is_nullable			=> 1,
		default_value		=> 0,
		is_foreign_key		=> 0,
	},
);

__PACKAGE__->set_primary_key(qw(item_id_one item_id_two));
__PACKAGE__->belongs_to('item_one' => 'Gonzo::Schema::Result::Item', 'item_id_one');
__PACKAGE__->belongs_to('item_two' => 'Gonzo::Schema::Result::Item', 'item_id_two');

1;

