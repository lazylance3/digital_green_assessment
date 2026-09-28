{{config(schema="staging")}}
select
    a.event_date,
    a.user_id,
    a.session_start_time,
    a.session_end_time,
    a.firebase_activity,
    a.user_engagement,
    a.onboarding_initiated,
    a.onboarding_completed,
    a.permissions_flow,
    a.content_viewership,
    a.chat_interaction,
    a.response_interaction,
    b.query_date,
    b.gender,
    b.country,
    b.query_type,
    b.language_detected,
    b.n_queries,
    b.query_start_time,
    b.query_end_time,
    b.payload
from
    {{ref("stg_firebase_events")}} a
    left join {{ref("stg_user_queries")}} b
    on a.event_date = b.query_date
    and a.user_id = b.user_id
    and a.chat_interaction = 1
    and b.query_start_time between a.session_start_time and a.session_end_time