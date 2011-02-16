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
	pearson => {
		data_type			=> 'float',
		is_nullable			=> 1,
		default_value		=> 0,
		is_foreign_key		=> 0,
	},
);

__PACKAGE__->set_primary_key(qw(item_id_one item_id_two));

__PACKAGE__->belongs_to('item_one' => 'Gonzo::Schema::Result::Item', 'item_id_one');

__PACKAGE__->belongs_to('item_two' => 'Gonzo::Schema::Result::Item', 'item_id_two');

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $sqlt_table->add_index(
        name => 'idx_item_correlations_item_id_one',
        fields => ['item_id_one']
    );
    $sqlt_table->add_index(
        name => 'idx_item_correlations_item_id_two',
        fields => ['item_id_two']
    );
}


1;

