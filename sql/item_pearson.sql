select sf.item_id_one,
       sf.item_id_two,
         (sf.sum / (select count(*) from users )
          - stats1.mean * stats2.mean
         )
         / (stats1.stddev * stats2.stddev) pearson
from (
select r1.item_id item_id_one,
       r2.item_id item_id_two,
       sum( r1.rating * r2.rating ) sum
from ratings r1
join ratings r2 on r1.user_id = r2.user_id
group by item_id_one, item_id_two
) sf
join item_statistics stats1
on stats1.item_id = sf.item_id_one
join item_statistics stats2
on stats2.item_id = sf.item_id_two
order by pearson;