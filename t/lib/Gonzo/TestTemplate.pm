package Gonzo::TestTemplate;
use Moose;
use FindBin;
use Gonzo::Database;
use Test::TempDir;

has database => (
    is          => 'ro',
    isa         => 'Gonzo::Database',
    lazy        => 1,
    builder     => '_build_database',
);

has persistent_data => (
    is          => 'ro',
    isa         => 'Bool',
    default     => sub { 0 },
    required    => 1,
    predicate   => 'is_persistent',
);

has data_dir => (
    is          => 'ro',
    lazy_build  => 1,
);

has db_dsn_memory => (
    is          => 'ro',
    isa         => 'Str',
    lazy_build  => 1,
);


has db_dsn_persistent => (
    is          => 'ro',
    isa         => 'Str',
    lazy_build  => 1,
);

sub _build_data_dir {
    return Test::TempDir::temp_root();
}

sub _build_db_dsn_memory {
    return "dbi:SQLite:dbname=:memory:",
}

sub _build_db_dsn_persistent {
    return "dbi:SQLite:dbname=" . shift->data_dir . "/gonzo_test.db",
}

sub _build_database {
    my $self = shift;

    my $db = undef;
    if ($self->is_persistent) {
        $db = Gonzo::Database->new( dsn => $self->db_dsn_persistent );
    }
    else {
        $db = Gonzo::Database->new( dsn => $self->db_dsn_memory );
    }

    # XXX: I'm sure I'll be revisiting this
    $db->get_schema->deploy({ add_drop_table => 1 });
    return $db;
}

1;