package Gonzo::TestTemplate;
use Moose;
use FindBin;
use Gonzo;
use Gonzo::Database;
use Gonzo::SimilarityFactory;
use Test::TempDir;
use Data::Dumper::Concise;

has database => (
    is          => 'ro',
    isa         => 'Gonzo::Database',
    lazy        => 1,
    builder     => '_build_database',
);

has new_gonzo => (
    is          => 'ro',
    isa         => 'Gonzo',
    lazy        => 1,
    builder     => '_build_default_gonzo',
);

has persistent_data => (
    traits  => ['Bool'],
    is          => 'ro',
    isa         => 'Bool',
    default     => 0,
    required    => 1,
    handles     => {
        not_persistent => 'not',
    },
);

has data_dir => (
    is          => 'ro',
    lazy_build  => 1,
);

has db_args => (
    is          => 'ro',
    isa         => 'HashRef',
    default     => sub { {} },
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

has similarity_pearson => (
    is          => 'ro',
    isa         => 'Gonzo::SimilarityFactory',
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

    my $args = $self->db_args;

    my $boostrap = undef;

    #my $bootstrap = delete $args->{bootstrap} if exists $args->{bootstrap};

    unless (defined( $args->{dsn} )) {
        if ($self->persistent_data) {
            $args->{dsn} = $self->db_dsn_persistent;
        }
        else {
            $args->{dsn} = $self->db_dsn_memory;
            $args->{bootstrap} = 1;
        }
    }

    $args->{similarity_factory} = $self->similarity_pearson;

    #warn "Passing arguments " . Dumper( $args );

    my $db = Gonzo::Database->new( %{$args} );

#     if ( $bootstrap ) {
#         $db->get_schema->deploy({ add_drop_table => 1 });
#     }
    return $db;
}

sub _build_similarity_pearson {
    return Gonzo::SimilarityFactory->new(
        classmap => { pearson => 'Gonzo::Similarity::Pearson' },
    );
}

sub _build_default_gonzo {
    my $self = shift;
    return Gonzo->new(
        database => $self->database,
        similarity_factory => $self->similarity_pearson,
    );
}
1;