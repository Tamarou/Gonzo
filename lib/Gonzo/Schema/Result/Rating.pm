package Gonzo::Schema::Result::Rating;
use Moose;
extends qw( DBIx::Class );

__PACKAGE__->load_components(qw(TimeStamp Core ));

__PACKAGE__->table('ratings');


__PACKAGE__->add_columns(
	user_id => {
		data_type			=> 'bigint',
		size				=> 20,
		is_nullable			=> 0,
		default_value		=> undef,
		is_foreign_key		=> 1,
		extra				=> { unsigned => 1 }
	},
	item_id => {
		data_type			=> 'bigint',
		size				=> 20,
		is_nullable			=> 0,
		default_value		=> undef,
		is_foreign_key		=> 1,
		extra				=> { unsigned => 1 }
	},
	rating => {
		data_type			=> 'int',
		size				=> 1,
		is_nullable			=> 0,
		default_value		=> undef,
		is_foreign_key		=> 0,
	},
	timestamp => {
		data_type			=> 'datetime',
		size				=> 0,
		is_nullable			=> 0,
		default_value		=> undef,
		is_auto_increment	=> 0,
		is_foreign_key		=> 0,
		set_on_create       => 1,
	}
);

__PACKAGE__->set_primary_key(qw(user_id item_id));
__PACKAGE__->belongs_to('item' => 'Gonzo::Schema::Result::Item', 'item_id');
__PACKAGE__->belongs_to('user' => 'Gonzo::Schema::Result::User', 'user_id');

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $sqlt_table->add_index(
        name => 'idx_ratings_item_id',
        fields => ['item_id']
    );
    $sqlt_table->add_index(
        name => 'idx_ratings_user_id',
        fields => ['user_id']
    );
}

1;

