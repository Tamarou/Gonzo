package Gonzo::Schema;
use Moose;
extends qw(DBIx::Class::Schema);
use Carp;

__PACKAGE__->load_components(qw(Core Schema::KiokuDB));
#__PACKAGE__->define_kiokudb_schema();
__PACKAGE__->load_namespaces;

1;