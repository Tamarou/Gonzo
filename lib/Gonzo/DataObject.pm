package Gonzo::DataObject;
use Moose::Role;
use Gonzo::Database;
use Check::ISA;

has datastore => (
    is          => 'rw',
    isa         => 'Gonzo::Database',
);

has dbix_source_name => (
    is          => 'ro',
    isa         => 'Str',
    lazy_build  => 1,
);

has dbix_row => (
    is      => 'rw',
);

# sub _build_datastore {
#     return Gonzo::Database->new(
#         dsn => "dbi:SQLite:dbname=$FindBin::Bin/data/test.db",
#     );
# }

sub _build_dbix_source_name {
    die "Implement _build_dbix_source_name in the subclass";
}

# sub dbix_row {
#     my $self = shift;
#     my $kioku_dir = shift;
#     # this is hacky but there doesn't seem to be an easy way to get
#     # from a hybrid Kioku object to it's associated DBIC Row
#     my $db = $self->datastore;
#
#     #my ($source_name, $meta_id ) = (undef, undef);
#     $kioku_dir->txn_do(scope => 1, body => sub {
#         my $source_name = $self->dbix_source_name;
#         my $meta_id = $db->kioku_dir->object_to_id( $self );
#         warn "BLARG $source_name and ID $meta_id for "  . $self->id . "\n";
#     });
#
#     #return $db->get_schema->resultset( $source_name )->search({ metadata =>  $meta_id })->first;
# }

1;