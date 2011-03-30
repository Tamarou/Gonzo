package Gonzo::Similarity::Pearson;
use Moose;
with qw( Gonzo::Common );
use Gonzo::Exception;
use Data::Dumper::Concise;

has column_name => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    default     => 'pearson',
);

has column_info => (
    traits      => ['Hash'],
    is          => 'ro',
    isa         => 'HashRef[Str]',
    default     => sub {{
        data_type			=> 'float',
		is_nullable			=> 1,
		default_value		=> 0,
		is_foreign_key		=> 0,
    }},
);

=head1 METHODS

=head2 B<update_item_correlations( $schema )>

Run insert/update queries required to populate tables for item-based correlations.

B<Arguments>: A Gonzo::Schema instance.

B<Returns>: 1 on success.

=cut

sub update_item_correlations {
    my $self = shift;
    my $schema = shift;

    $schema->resultset('ItemCorrelations')->delete;

    $self->log->debug('Updating Item correlations.');

    my $column_name = $self->column_name;

    my $insert_result = $schema->storage->dbh_do( sub {
            my ($storage, $dbh, %args) = @_;

            #$self->log->debug('store ' . Dumper( $feh ) );
            my $sql = qq|
                insert into item_correlations (
                    item_id_one,
                    item_id_two,
                    $column_name
                )
                select sf.item_id_one,
                    sf.item_id_two,
                    (sf.sum / (select count(*) from users) - stats1.mean * stats2.mean) / (stats1.stddev * stats2.stddev)
                from (
                    select  r1.item_id item_id_one,
                        r2.item_id item_id_two,
                        sum(r1.rating * r2.rating) sum
                    from ratings r1
                    join ratings r2
                    on r1.user_id = r2.user_id
                    group by item_id_one, item_id_two
                ) sf
                join item_statistics stats1
                on stats1.item_id = sf.item_id_one
                join item_statistics stats2
                on stats2.item_id = sf.item_id_two
                where stats1.item_id <> stats2.item_id;
            |;

            $dbh->do( $sql ) || Gonzo::Exception->throw( $dbh->errstr );
        },
    );
    return 1;
}

=head2 B<update_user_correlations( $schema )>

Run insert/update queries required to populate tables for user-based correlations.

B<Arguments>: A Gonzo::Schema instance.

B<Returns>: 1 on success.

=cut

sub update_user_correlations {
    my $self = shift;
    my $schema = shift;

    $schema->resultset('UserCorrelations')->delete;
    $self->log->debug('Updating User correlations.');

    my $column_name = $self->column_name;

    my $insert_result = $schema->storage->dbh_do( sub {
            my ($storage, $dbh, %args) = @_;
            $dbh->{RaiseError} = 1;
            my $sql = qq|
                insert into user_correlations (
                    user_id_one,
                    user_id_two,
                    $column_name
                )
                select sf.user_id_one, sf.user_id_two, (sf.sumsqr2 - ( sf.sum1 * sf.sum2 / sf.count) /
                sqrt(( sf.sumsqr1 - power(sf.sum1, 2) / sf.count ) * ( sf.sumsqr2 - power(sf.sum2, 2) / sf.count ))) pearson
                from (
                    select  r1.user_id user_id_one,
                            r2.user_id user_id_two,
                            sum(1) count,
                            sum(r1.rating) sum1,
                            sum(r2.rating) sum2,
                            sum(power(r1.rating,2)) sumsqr1,
                            sum(power(r2.rating,2)) sumsqr2,
                            sum(r1.rating * r2.rating) p_sum,
                            sum(r1.rating + r2.rating) sum
                    from ratings r1
                    join ratings r2 on r1.item_id = r2.item_id
                    where r1.user_id <> r2.user_id
                    group by user_id_one, user_id_two
                ) sf;
            |;

            $dbh->do( $sql ) || Gonzo::Exception->throw( $dbh->errstr );
        },
    );

    $self->log->debug('User correlations updated.');

    return 1;
}

1;