package Gonzo::Database;
use Moose;
with qw( Gonzo::Common );
use KiokuDB;

use Data::Dumper;
use Gonzo::Exception;
use Check::ISA;
use Carp;
BEGIN { $SIG{__DIE__} = sub { Carp::confess(@_) } }

has kioku_dir => (
    is          => 'ro',
    isa         => 'KiokuDB',
    lazy_build  => 1,
);

has _kioku_scope => (
    is          => 'rw',
    isa         => 'KiokuDB::LiveObjects::Scope',
);

has dsn => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has username => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has password => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has bootstrap => (
    is          => 'ro',
    isa         => 'Bool',
    default     => sub { 0 },
);

sub _build_kioku_dir {
    my $self = shift;
    my $kioku = KiokuDB->connect(
        $self->dsn,
        user => $self->username,
        password => $self->password,
        schema => 'Gonzo::Schema',
        RaiseError => 1,
        sqlite_use_immediate_transaction => 1,
        debug => 1,
        create => $self->bootstrap ? 1 : undef,
        columns => [
            external_id => {
                data_type => 'int',
                is_nullable => 1,
                extract => sub {
                    my $obj = shift;
                    return $obj->external_id if $obj and $obj->can('external_id');
                }
            }
        ],
    );

    $self->log->debug('Database connection inititalized.');
    $self->_kioku_scope( $kioku->new_scope );
    return $kioku;
}

=head1 METHODS

=head2 B<get_schema()>

Access to the underlying schema object.

B<Arguments>: [none]

B<Returns>: The DBIx::Class::Schema object at the heart of Gonzo's data storage.

=cut

sub get_schema {
    return shift->kioku_dir->backend->schema;
}

=head2 B<create_rating( $hash_ref )>

Internal low level method for adding a new rating to the data store. B<Do not> use this directly; use the C<rate_item> method instead.

B<Arguments>:

This method accepts a single hash reference containing the the following key/value pairs.

=over 4

=item B<user_id)>
Required. The Metadata::User object (or DBIC Row ID) representing the user for whom we are recommending items.

=item B<item_id)>
Required. The Metadata::Item object (or DBIC Row ID) representing the item being rated.

=item B<rating>

Required. The rating value the specified user is giving to the specified item.

=back

B<Returns>:

Returns the newly created rating metadata object.

=cut

sub create_rating {
    my $self = shift;
    my $args = shift;
    return $self->get_schema->resultset('Rating')->create( $args );
}


=head2 B<create_user( $hash_ref )>

Public method for adding a new user to the data store.

B<Arguments>:

This method accepts a single hash reference containing the data that will be used to create the metadata entry for this user. See L<Gonzo::Metadata::User> (the default user metadata class) for an example.

B<Returns>: The newly created user metadata object.

=cut

sub create_user {
    my $self = shift;
    my $args = shift;
    return $self->create_object({
        source_name     => 'User',
        metadata_class  => $self->user_metadata_class,
        metadata        => $args,
    });
}

=head2 B<create_item( $hash_ref )>

Public method for adding a new item to the data store.

B<Arguments>:

This method accepts a single hash reference containing the data that will be used to create the metadata entry for this item. See L<Gonzo::Metadata::Item> (the default item metadata class) for an example.

B<Returns>: The newly created item metadata object.

=cut

sub create_item {
    my $self = shift;
    my $args = shift;
    return $self->create_object({
        source_name     => 'Item',
        metadata_class  => $self->item_metadata_class,
        metadata        => $args,
    });
}

=head2 B<create_object( $hash_ref )>

Factory method for adding a new hybrid schema objects the data store.

B<Arguments>:

This method accepts a single hash reference containing the the following key/value pairs.

=over 4

=item B<metadata_class>

Required. The DBIx::Class resultsource name for the DBIC side of the hybrid object.

=item B<metadata>

Required. The hash referece of arguments that will be passed duitng the creation of the metadata side of the hybrid object.

=back

B<Returns>: The newly created metadata object.


NOTE: Use this factory method (or the create_(item|user) methods which calls it) instead of creating DBIC Row object directly, as this method will initialize the two-way relationship between tht Row object and its associated metadata.

=cut

sub create_object {
    my $self = shift;
    my $args = shift;

    unless ( defined($args->{metadata_class}) && defined $args->{metadata} ) {
        Gonzo::Exception->throw("You must pass 'metadata' and 'metadata_class' keys to create_object.");
    }

    my $meta = undef;

    $self->kioku_dir->txn_do(scope => 1, body => sub {
            Class::MOP::load_class( $args->{metadata_class} );
            $meta = $args->{metadata_class}->new( %{$args->{metadata}} );

            my $dbix_row = $self->get_schema->resultset($args->{source_name})->create({
                metadata => $meta,
            });

            $meta->dbix_row( $dbix_row );
            $dbix_row->store;
    });

    return $meta;
}

=head2 B<lookup_metadata( $hash_ref )>

Convenience method for by-ID object lookups in the KiokuDB-stored metadata. See L<KiokuDB> for full details.

=cut

sub lookup_metadata {
    my $self = shift;
    my $id = shift;
    my $obj = $self->kioku_dir->lookup( $id );
}

=head2 B<search_metadata( $hash_ref )>

Convenience method for searching data in the KiokuDB-stored metadata. See L<KiokuDB> for full details.

=cut

sub search_metadata {
    my $self = shift;
    my $args = shift;
    return $self->kioku_dir->search( $args );
}

=head2 B<recommend_by_item( $hash_ref )>

Recommends items based on a [TBD]

B<Arguments>:

This method accepts a single hash reference containing the the following key/value pairs.

=over 4

=item B<item (or item_id)>

Required. The Metadata::Item object (or DBIC Row ID) representing the item we will use for aggregate rating comparisons.

=item B<limit>

Optional. Return only X number of items (default: 10)

=item B<threshold>

Optional. The minimum number of times a given item must have been rated for it to be considered for comparision. (default: 2)

=back

=cut

sub recommend_by_item {
    my $self = shift;
    my $args = shift;

    my $item_id = undef;
    my $schema = $self->get_schema;

    if (defined( $args->{item} )) {
        $item_id = $args->{item}->dbix_row->id;
    }
    elsif ( defined( $args->{item_id} )) {
        $item_id = $args->{item_id};
    }

    my %bind = (
        item_id     => $item_id,
        threshold   => $args->{threshold} || 2,
        limit       => $args->{limit} || 10
    );

    my $rows = $schema->storage->dbh_do( sub {
            my ($storage, $dbh, %args) = @_;
            my $sql = qq|
                select item_id_two, ( sum / count ) as average
                from rating_aggregates
                where count > ? and
                      item_id_one = ?
                order by ( sum /count ) desc
                limit ?
            |;
            my @rows = ();

            my $sth = $dbh->prepare( $sql ) || die $dbh->errstr;
            $sth->execute( $args{threshold}, $args{item_id}, $args{limit} ) || die $sth->errstr;
            while ( my $row = $sth->fetchrow_hashref ) {
                push @rows, $row
            }
            return \@rows
        },
        %bind,
    );

    my @items = ();
    my $items_rs = $schema->resultset('Item');

    foreach my $row ( @$rows ) {
        my $item = $items_rs->find( $row->{item_id_two} );
        push @items, $item;
    }

    return @items;
}

=head2 B<recommend_for_user( $hash_ref )>

Recommends items for a given user. Items are returned in the form of a [TBD]

B<Arguments>:

This method accepts a single hash reference containing the the following key/value pairs.

=over 4

=item B<user (or user_id)>
Required. The Metadata::User object (or DBIC Row ID) representing the user for whom we are recommending items.

=item B<limit>

Optional. Return only X number of items (default: 10)

=back

=cut

sub recommend_for_user {
    my $self = shift;
    my $args = shift;

    my $user_id = undef;
    my $schema = $self->get_schema;

    if (defined( $args->{user} )) {
        $user_id = $args->{user}->dbix_row->id;
    }
    elsif ( defined( $args->{user_id} )) {
        $user_id = $args->{user_id};
    }

    my %bind = (
        user_id     => $user_id,
        limit       => $args->{limit} || 10
    );

    my $rows = $schema->storage->dbh_do( sub {
            my ($storage, $dbh, %args) = @_;
            my $sql = qq|
                select ra.item_id_one as 'item_id',
                sum(ra.sum + ra.count * r.rating)/sum(ra.count) as 'average_rating'
                from items i, ratings r, rating_aggregates ra
                where r.user_id= ? AND
                ra.item_id_one <> r.item_id AND
                ra.item_id_two = r.item_id
                group by ra.item_id_one
                order by average_rating desc
                limit ?;
            |;
            my @rows = ();

            my $sth = $dbh->prepare( $sql ) || die $dbh->errstr;
            $sth->execute( $args{user_id}, $args{limit} ) || die $sth->errstr;
            while ( my $row = $sth->fetchrow_hashref ) {
                push @rows, $row
            }
            return \@rows
        },
        %bind,
    );

    my @items = ();
    my $items_rs = $schema->resultset('Item');

    foreach my $row ( @$rows ) {
        my $item = $items_rs->find( $row->{item_id} );
        push @items, $item;
    }

    return @items;
}

=head2 B<rate_item( $hash_ref )>

Public method for adding a new rating to the data store.

B<Arguments>:

This method accepts a single hash reference containing the the following key/value pairs.

=over 4

=item B<user (or user_id)>
Required. The Metadata::User object (or DBIC Row ID) representing the user for who is rting the item.

=item B<item (or item_id)>
Required. The Metadata::Item object (or DBIC Row ID) representing the item being rated.

=item B<rating_value>

Required. The rating value the specified user is giving to the specified item.

=back

B<Returns>:

Returns the newly created rating object (DBIC row).

=cut

sub rate_item {
    my $self = shift;
    my $args = shift;

    my ($item_id, $user_id) = (undef, undef);

    if (defined( $args->{item} )) {
        $item_id = $args->{item}->dbix_row->id;
    }
    elsif ( defined( $args->{item_id} )) {
        $item_id = $args->{item_id};
    }

    if (defined( $args->{user} )) {
        $user_id = $args->{user}->dbix_row->id;
    }
    elsif ( defined( $args->{user_id} )) {
        $user_id = $args->{user_id};
    }

    my $rating = $self->get_schema->resultset('Rating')->find_or_create({ item_id => $item_id, user_id => $user_id, rating => $args->{rating_value} });

    # this probably shouldn't be here but having it here makes the
    # recommendations more-or-less realtime. XXX: Maybe a flag?
    $self->update_user_rating_aggregates({ rating => $rating });

    return $rating;
}

=head2 B<update_user_rating_aggregates( $hash_ref )>

Updates the precalculated ratings aggregates for a given user.

B<Arguments>:

This method accepts a single hash reference containing the the following key/value pairs. Note that either the user and item arguments are required I<or> a single rating object can be passed in, instead.

=over 4

=item B<user (or user_id)>
Required (see above). The Metadata::User object (or DBIC Row ID) representing the user for who is rting the item.

=item B<item (or item_id)>
Required (see above). The Metadata::Item object (or DBIC Row ID) representing the item being rated.

B<OR>

=item B<rating>

Required (see above). The rating object (DBIC Row) representing a given user's rating for a specific item.


=back

=cut

sub update_user_rating_aggregates {
    my $self = shift;
    my $args = shift;

    my ( $user, $item ) = (undef, undef);
    #$self->kioku_dir->txn_do(scope => 1, body => sub {
    my $schema = $self->get_schema;
    my $count = 0;


    if ( defined( $args->{rating} )) {
        $user = $args->{rating}->user;
        $item = $args->{rating}->item;
    }
    else {
        if (defined( $args->{user} )) {
            $user = $args->{user}->dbix_row->id;
        }
        elsif ( defined( $args->{user_id} )) {
            $user = $schema->resultset('User')->find( $args->{user_id} );
        }

        if (defined( $args->{item} )) {
            $item = $args->{item}->dbix_row->id;
        }
        elsif ( defined( $args->{item_id} )) {
            $item = $schema->resultset('Item')->find( $args->{item_id} );
        }
    }

    ## exception handling here

    my $rating_rs = $schema->resultset('Rating');

    my $rating_aggregates_rs = $schema->resultset('RatingAggregate');

    my %bind = (
        user_id => $user->id,
        item_id => $item->id,
    );

    my $rows = $schema->storage->dbh_do( sub {
            my ($storage, $dbh, %args) = @_;
            $dbh->{RaiseError} = 1;
            my $sql = qq|
                select distinct r.item_id, r2.rating - r.rating as rating_difference
                from ratings r, ratings r2
                where r.user_id = ? and
                    r2.item_id = ? and
                    r2.user_id = ?
            |;
            my @rows = ();

            my $sth = $dbh->prepare( $sql ) || die $dbh->errstr;
            $sth->execute( $args{user_id}, $args{item_id}, $args{user_id} ) || die $sth->errstr;
            while ( my $row = $sth->fetchrow_hashref ) {
                push @rows, $row
            }
            return \@rows
        },
        %bind,
    );

    foreach my $ratings_diff ( @$rows ) {
        my $rating_difference = $ratings_diff->{rating_difference} || 0;


        # each combination (X,Y and Y,X) gets its own row. If a given combo
        # doesn't exist, we create it.
        my $aggregate_one = undef;
        my $aggregate_two = undef;

        #XXXXXexperimental
        next if $ratings_diff->{item_id} == $item->id;

        if ( $aggregate_one = $rating_aggregates_rs->find({ item_id_one => $item->id, item_id_two => $ratings_diff->{item_id} }, { key => 'primary' } ) ) {

            my $count = $aggregate_one->count + 1;
            my $sum   = ( $aggregate_one->sum + $rating_difference );
            #printf "should be updatings agg for %s -> %s\n", $item->id, $ratings_diff->{item_id};
            $aggregate_one->update({ sum => $sum, count => $count });
        }
        else {
            $aggregate_one = $rating_aggregates_rs->create({ item_id_one => $item->id, item_id_two => $ratings_diff->{item_id}, count => 1, sum => $rating_difference });
             #printf "should be creating new agg for %s -> %s\n", $item->id, $ratings_diff->{item_id};
        }

        #next if $ratings_diff->{item_id} == $item->id;

        if ( $aggregate_two = $rating_aggregates_rs->find({ item_id_one => $ratings_diff->{item_id}, item_id_two => $item->id }, { key => 'primary' } ) ) {
            my $count = $aggregate_two->count + 1;
            my $sum   = $aggregate_two->sum - $rating_difference;
            # "should be updating\n";
            $aggregate_two->update({ sum => $sum, count => $count });
        }
        else {
            $aggregate_two = $rating_aggregates_rs->create({ item_id_one => $ratings_diff->{item_id}, item_id_two => $item->id, count => 1, sum => -$rating_difference });
            #warn "should be creating new agg\n";
        }
        $count++;
    }
    #});
    return 1; #$count;
}
1;