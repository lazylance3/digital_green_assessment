{{config(schema="mart")}}
with data as (
    select
        event_date,
        user_id,
        lead(event_date) over (partition by user_id order by event_date) as next_event_date
    from
       {{ref("stg_firebase_events")}} 
), clean as (
    select
        event_date,
        user_id,
        next_event_date
    from
        data
    group by 1,2,3
)
select
    event_date,
    count(distinct user_id) as users,
    count(distinct 
        case when datediff(day, event_date, next_event_date) between 4 and 6 then user_id end
    ) as 3d_retained_users,
    `3d_retained_users` / users as per_3d_retained_users,
    count(distinct 
        case when datediff(day, event_date, next_event_date) between 7 and 13 then user_id end
    ) as 7d_retained_users,
    `7d_retained_users` / users as per_7d_retained_users,
    count(distinct 
        case when datediff(day, event_date, next_event_date) between 14 and 20 then user_id end
    ) as 14d_retained_users,
    `14d_retained_users` / users as per_14d_retained_users
from
    clean
group by 1
order by 1;