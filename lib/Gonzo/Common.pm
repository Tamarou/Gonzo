package Gonzo::Common;
use Moose::Role;
with qw(MooseX::Log::Log4perl);

use Log::Log4perl qw(:easy);

BEGIN {
    Log::Log4perl->easy_init();
}

has config => (
    isa         => 'Config::Path',
    is          => 'ro',
);

has database => (
    is          => 'ro',
    isa         => 'Gonzo::Database',
    lazy        => 1,
    builder     => '_build_database',
);

has user_metadata_class => (
    isa         =>  'Str',
    is          =>  'ro',
    default     =>  sub { 'Gonzo::Metadata::User' },
);

has item_metadata_class => (
    isa         =>  'Str',
    is          =>  'ro',
    default     =>  sub { 'Gonzo::Metadata::Item' },
);

sub _build_database {
    my $self = shift;

    my $args = $self->config->fetch('/database');

    die "ARGS " . Dumper( $args );
    my $boostrap = undef;

    my $bootstrap = delete $args->{bootstrap} if exists $args->{bootstrap};

    unless (defined( $args->{dsn} )) {
        if ($self->is_persistent) {
            $args->{dsn} = $self->db_dsn_persistent;
        }
        else {
            $args->{dsn} = $self->db_dsn_memory;
            $bootstrap = 1;
        }
    }

    my $db = Gonzo::Database->new( %{$args} );

    if ( $bootstrap ) {
        $db->get_schema->deploy({ add_drop_table => 1 });
    }
    return $db;
}

1;
1;

