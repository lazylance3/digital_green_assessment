with data as (
    select
        a.query_date,
        a.user_id,
        b.col as country
    from
        {{ ref("stg_user_queries")}} a
        lateral view explode_outer(a.country) b 
)
select
    coalesce(country, 'Unavailable') as country,
    count(distinct user_id) as vus
from    
    data
group by 1
order by 2 desc;