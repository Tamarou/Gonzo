package Gonzo::Common;
use Moose::Role;
with qw(MooseX::Log::Log4perl);

use Log::Log4perl qw(:easy);
use Config::Path;
use Data::Dumper;

BEGIN {
    Log::Log4perl->easy_init();
}

has config => (
    isa         => 'Config::Path',
    is          => 'ro',
    lazy        => 1,
    builder     => '_build_config',
);

has config_file => (
    isa         => 'Str',
    is          => 'ro',
    predicate   => 'has_config_file',
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

sub _build_config {
    my $self = shift;
    return undef unless $self->has_config_file;
    return Config::Path->new( files => [ $self->config_file ] );
}

1;

