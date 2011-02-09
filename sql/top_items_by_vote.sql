/*
select i.id as 'item_id', ag.votes, ag.average_rating
from    items i,
        (select item_id, count(item_id) as 'votes', avg(rating) as 'average_rating' from ratings group by item_id) as ag
where   i.id = ag.item_id
order by ag.votes desc
limit 10;
*/

/* pretty-print top 10 */
select e.external_id, r.item_id, avg(r.rating) as 'average_rating',
       sum(1) as 'votes'
from ratings r,
     entries e,
     items i
where e.id = i.metadata and
      i.id = r.item_id
group by r.item_id
order by votes desc
limit 10;


/*
top 10, the simple implementation
select item_id,
       sum(1) as 'votes'
from ratings
group by item_id
order by votes desc
limit 10;
*/