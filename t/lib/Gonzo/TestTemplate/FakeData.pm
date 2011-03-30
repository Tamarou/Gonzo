package Gonzo::TestTemplate::FakeData;
use Moose;
use Iterator::File::Line;
use Data::Dumper;
use Data::Random qw(:all);
use List::Util qw(shuffle);
use IO::File;
use Test::TempDir;

has database => (
    is          => 'ro',
    isa         => 'Gonzo::Database',
    lazy        => 1,
    builder     => '_build_database',
);

has data_dir => (
    is          => 'ro',
    lazy_build  => 1,
);

sub _build_data_dir {
    return Test::TempDir::temp_root();
}

sub generate_data {
    my $self = shift;
    my $args = shift || {};

    $args->{user_count}       ||= 50;
    $args->{item_count}       ||= 50;
    $args->{ratings_per_user} ||= 20;
    my $data_dir = $args->{data_dir} || $self->data_dir;

    die "Directory $data_dir doesn't exist\n" unless -d $data_dir;

    my $user_file   = $data_dir . '/users.dat';
    my $item_file   = $data_dir . '/items.dat';
    my $rating_file = $data_dir . '/ratings.dat';
    my @user_ids    = ();
    my @item_ids    = ();

    my $user_fh = IO::File->new("> $user_file") || die "Couldn't open $user_file for writing: $!\n";

    my $id_counter = 1;
    for (0...$args->{user_count}-1) {
        my $user_data = make_user();
        my $external_id = sprintf "%010d", $id_counter;
        my $line = sprintf "%010d\t%s\t%s\t%s\t%s\n", $external_id, $user_data->{gender}, $user_data->{age}, $user_data->{zip}, $user_data->{occupation};
        print $user_fh $line;
        push @user_ids, $external_id;
        $id_counter++;
    }
    $user_fh->close;

    my $item_fh = IO::File->new("> $item_file") || die "Couldn't open $item_file for writing: $!\n";

    $id_counter = 1;
    for (0...$args->{item_count}-1) {
        my $item_data = make_item();
        my $external_id = sprintf "%010d", $id_counter;
        my $line = sprintf "%010d\t%s\n", $external_id, $item_data->{title};
        print $item_fh $line;
        push @item_ids, $external_id;
        $id_counter++;
    }
    $item_fh->close;

    my $rating_fh = IO::File->new("> $rating_file") || die "Couldn't open $rating_file for writing: $!\n";

    foreach my $user_id ( @user_ids ) {
        my @items_to_rate = (shuffle(@item_ids))[0..$args->{ratings_per_user}-1];
        foreach my $item_id (@items_to_rate) {
            my $line = sprintf "%s\t%s\t%s\t%s\n", $user_id, $item_id, int(rand(5))+1, rand_datetime();
            print $rating_fh $line;
        }

    }
    $rating_fh->close;
}

sub import_data {
    my $self = shift;
    my $args = shift;

    my $stats = {};

    my $data_dir = $args->{data_dir} || $self->data_dir;
    my $user_file   = $data_dir . '/users.dat';
    my $item_file   = $data_dir . '/items.dat';
    my $rating_file = $data_dir . '/ratings.dat';

    my $db = $args->{database} || $self->database || die "Need a database to import test data to.";

    # XXX: update all of the following when the DataExtractor interface comes online

    my %seen_users = ();
    my %seen_items = ();

    my $user_iterator = Iterator::File::Line->new(
        filename => $user_file,
        filter   => sub {
            my @fields =  split(/\t/, $_[0]);

            # see the generate_data spec above
            return {
                external_id     => $fields[0],
                gender          => $fields[1],
                age             => $fields[2],
                zip_code        => $fields[3],
                occupation      => $fields[4],
            };
        },
    );

    while (my $data = $user_iterator->next) {
        my $user_meta = $db->create_user( $data );
        $seen_users{ $data->{external_id} } = $user_meta;
        $stats->{users}++;
    }



    my $item_iterator = Iterator::File::Line->new(
        filename => $item_file,
        filter   => sub {
            my @fields =  split(/\t/, $_[0]);

            # see the generate_data spec above
            return {
                external_id     => $fields[0],
                title           => $fields[1],
            };
        },
    );

    while (my $data = $item_iterator->next) {
        my $item_meta = $db->create_item( $data );
        $seen_items{ $data->{external_id} } = $item_meta;
        $stats->{items}++;
    }

###
    my $rating_iterator = Iterator::File::Line->new(
        filename => $rating_file,
        filter   => sub {
            my @fields =  split(/\t/, $_[0]);

            # see the generate_data spec above
            return {
                user_id      => $fields[0],
                item_id      => $fields[1],
                rating_value => $fields[2],
            };
        },
    );

    while (my $data = $rating_iterator->next) {
        my $rating = $db->rate_item({
            user         => $seen_users{ $data->{user_id} },
            item         => $seen_users{ $data->{item_id} },
            rating_value => $data->{rating_value}
        });

        $stats->{ratings}++;
    }

    $db->update_user_statistics;
    $db->update_user_correlations;
    $db->update_item_statistics;
    $db->update_item_correlations;
    return $stats;
}

sub make_user {
    return {
        zip         => sprintf("%05d", int( rand( 99999 ))),
        gender      => int(rand(2)) == 1 ? 'F' : 'M',
        occupation  => ucfirst( (rand_words( size => 1 ))[0] ),
        age         => int(rand(85)),
    };
}

sub make_item {
    return {
        title => join' ', map { ucfirst($_) } (rand_words( size => int(rand(4)) )),
    };
}

1;