select e.external_id, count(*) as 'overlap', r.user_id
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