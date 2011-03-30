#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Gonzo;
use Getopt::Long qw(GetOptions);
use Config::Any;

my %conf            = ();
my $do_help         = undef;

GetOptions(
    'file=s'        => \$conf{config_file},
    'help'          => \$do_help,
);

usage() if $do_help;

die "Pass an appropriate Gonzo config file" unless $conf{config_file} and -f $conf{config_file};

my $gonzo = Gonzo->new(
    config_file     => $conf{config_file},
);

$gonzo->database->get_schema->deploy({ add_drop_table => 1 });
warn "Gonzo DB deployed\n";
exit(0);