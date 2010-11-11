package Gonzo::TestTemplate;
use Moose;
use FindBin;

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

sub _build_db_dsn_memory {
    return "dbi:SQLite:dbname=:memory:",
}

sub _build_db_dsn_persistent {
    return "dbi:SQLite:dbname=$FindBin::Bin/data/gonzo_test.db",
}

1;