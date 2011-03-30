package Gonzo::Common;
use Moose::Role;
with qw(MooseX::Log::Log4perl Gonzo::Types);

use Log::Log4perl qw(:easy);
use Config::Path;
use Data::Dumper;

BEGIN {
    Log::Log4perl->easy_init();
}

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

1;

