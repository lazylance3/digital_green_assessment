{{config(schema='mart')}}
with data as (
    select 
        event_date, 
        firebase_activity, 
        coalesce(n_queries,0) as n_queries,
        user_id
    from 
        {{ref("stg_firebase_events_n_queries")}}
)
select
    event_date,
    count(distinct case when firebase_activity = 1 then user_id end) as firebase_active,
    count(distinct case when n_queries > 0 then user_id end) as chat_activity,
    chat_activity / firebase_active as activation_rate
from    
    data
group by 1
;