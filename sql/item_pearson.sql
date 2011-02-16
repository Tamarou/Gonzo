/*
create or replace table 'user_similairty_pearson' (
user_id_one bigint(20),
user_id_one bigint(20),

);
*/

/*
drop table item_statistics;
drop table item_correlations;

create table item_statistics (
    item_id bigint(20) primary key references items(id),
    mean float,
    stddev float,
    count int
);


insert into item_statistics (item_id, mean, count)
select item_id, sum(rating) / (select count(*) from items) mean, sum(1) count
from ratings r
group by r.item_id;


update item_statistics
set stddev = (
    select sqrt(
        sum(ratings.rating * ratings.rating) / (select count(*) from users)
        - mean * mean
       ) stddev
    from ratings
    where ratings.item_id = item_statistics.item_id
    group by ratings.item_id
);

create table item_correlations(
    item_id_one bigint(20) references items(id),
    item_id_two bigint(20) references items(id),
    rho float,
    unique key (item_id_one, item_id_two),
    key (item_id_one),
    key (item_id_two)
);

insert into item_correlations (
    item_id_one,
    item_id_two,
    rho
)
select sf.item_id_one,
     sf.item_id_two,
     (sf.sum / (select count(*) from users) - stats1.mean * stats2.mean) / (stats1.stddev * stats2.stddev) as 'wibble'
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

*/
/*
me: 4243
hobbit: 6038
*/

/*explain extended */

select ic.item_id_two, ic.rho as 'wtf'
from item_correlations ic,
     item_statistics stats
where stats.count > 10 and
      ic.item_id_one = 16848 and
      ic.item_id_two = stats.item_id
order by ic.rho desc
limit 10;

/* SAVE THIS */
/*
select e.*, ic.item_id_one as 'item_id', ic.rho as 'distance'
from    ratings r,
        item_correlations ic,
        items i,
        entries e
where r.user_id= 6038 AND
ic.item_id_one <> r.item_id AND
ic.item_id_two = r.item_id and
i.id = ic.item_id_one AND
e.id = i.metadata
group by ic.item_id_one
order by average_rating desc
limit 10;
*/

/*
select * from item_statistics order by mean desc limit 10;

*/
/*


select count(*) as 'overlap', r.user_id, ( sum(r.rating*r2.rating) - ( sum(r.rating)  * sum(r2.rating)  / count(*) )) as 'numerator', ( sqrt( sum(pow(r.rating, 2)) - pow(sum(r.rating), 2)/count(*)) * (sum(pow(r.rating, 2)) - pow(sum(r.rating), 2)/count(*)) ) as 'denominator'
from    users u,
        entries e,
        ratings r
join ratings r2 on (r.item_id = r2.item_id)
where
r2.user_id = 4243 and
r.user_id <> r2.user_id and
u.id = r.user_id and
e.id = u.metadata
group by r.user_id
order by overlap desc
limit 10;
*/
/*
select sum(r.rating) as 'set_one_sum', sum(r2.rating) as 'set_two_sum', sum(pow(r.rating, 2)) as 'set_one_square', sum(pow(r2.rating, 2)) as 'set_two_square', sum(r.rating*r2.rating) as 'product_sum', count(*) as 'overlap', r.user_id, ( product_sum - ( set_one_sum * set_two_sum / overlap )) as 'denom'
from    users u,
        entries e,
        ratings r
join ratings r2 on (r.item_id = r2.item_id)
where
r2.user_id = 4243 and
r.user_id <> r2.user_id and
u.id = r.user_id and
e.id = u.metadata
group by r.user_id
order by overlap desc
limit 10;
*/

/*
select e.external_id, sum(r.rating) as 'sum', count(*) as 'overlap', r.user_id
from    users u,
        entries e,
        ratings r
join ratings r2 on (r.item_id = r2.item_id)
where
r2.user_id = 4243 and
r.user_id <> r2.user_id and
u.id = r.user_id and
e.id = u.metadata
group by r.user_id
order by overlap desc
limit 10;
*/