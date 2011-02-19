#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Gonzo::Database;
use Getopt::Long qw(GetOptions);
use Config::Any;

my %conf            = ();
my $do_help         = undef;

GetOptions(
    'file=s'        => \$conf{config_file},
    'username=s'    => \$conf{username},
    'password=s'    => \$conf{password},
    'dbname=s'      => \$conf{dbname},
    'host=s'        => \$conf{host},
    'help'          => \$do_help,
);

usage() if $do_help;

my $conf_path = delete $conf{config_file};

if ( $conf_path and -f $conf_path ) {
    my $db_conf = Config::Any->load_files({
        use_ext         => 1,
        files           => [ $conf_path ],
    })->[0]->{$conf_path}->{database};


    foreach my $key ( keys %{$db_conf} ) {
        next if defined $conf{$key};
        $conf{$key} = $db_conf->{$key};
    }
}

$conf{host} ||= 'localhost';

my $db = Gonzo::Database->new(
    %conf,
    bootstrap   => 1,
) || die "Error connecting to database: $!";

$db->get_schema->deploy({ add_drop_table => 1 });
warn "Gonzo DB deployed\n";
exit(0);