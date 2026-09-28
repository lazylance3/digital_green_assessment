with data as (
    select
        a.query_date,
        a.user_id,
        b.col as gender
    from    
        {{ref("stg_user_queries")}} a
        lateral view explode_outer(a.gender) b 
)
select
    coalesce(gender, 'Unavailable') as gender,
    count(distinct user_id) as vus
from    
    data
group by 1
order by 1;