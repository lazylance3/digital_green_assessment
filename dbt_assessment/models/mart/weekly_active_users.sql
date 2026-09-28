{{config(schema='mart')}}
select
    trunc(event_date, 'week') as week_,
    count(distinct user_id) as active_users
from
    {{ref("stg_firebase_events")}}
group by 
    trunc(event_date, 'week')