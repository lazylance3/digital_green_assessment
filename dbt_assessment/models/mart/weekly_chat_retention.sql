{{config(schema="mart")}}
with data as (
    select
        a.query_date,
        a.user_id,
        lead(a.query_date) over (partition by a.user_id order by a.query_date) as next_query_date,
        coalesce(b.gender, 'NA') as gender,
        coalesce(b.country, 'NA') as country,
        coalesce(b.language_detected, 'NA') as language_detected
    from
        {{ref("stg_user_queries")}} a
        left join {{ref("stg_user_fact")}} b
        on a.user_id = b.user_id
), clean as (
    select
        query_date,
        user_id,
        next_query_date,
        gender,
        country,
        language_detected
    from
        data
    group by all
)
select
    trunc(query_date, 'week') as query_week,
    coalesce(country, '1. All') as country,
    coalesce(language_detected, '1. All') as language_detected,
    coalesce(gender, '1. All') as gender,
    count(distinct user_id) as users,
    count(distinct
        case when datediff(day, query_date, next_query_date) between 4 and 6 then user_id end
    ) as 3d_retained_users,
    count(distinct
        case when datediff(day, query_date, next_query_date) between 7 and 13 then user_id end
    ) as 7d_retained_users,
    count(distinct
        case when datediff(day, query_date, next_query_date) between 14 and 21 then user_id end
    ) as 14d_retained_users,
    3d_retained_users / users as per_3d_retained_users,
    7d_retained_users / users as per_7d_retained_users,
    14d_retained_users / users as per_14d_retained_users
from
    clean
group by 
    grouping sets (
        (trunc(query_date, 'week')),
        (trunc(query_date, 'week'), country, gender, language_detected),
        (trunc(query_date, 'week'), country),
        (trunc(query_date, 'week'), gender),
        (trunc(query_date, 'week'), language_detected)
    )