
select
    trunc(event_date, 'week') as week_,
    count(distinct user_id) as active_users,
    count(distinct
        case when coalesce(n_queries,0) > 0 then user_id end
    ) / count(distinct user_id) as conversion_rate
from
    `dbt_assessment`.`staging`.`stg_firebase_events_n_queries`
group by 
    trunc(event_date, 'week')