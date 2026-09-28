
with data as (
    select
        query_date,
        user_id,
        lead(query_date) over (partition by user_id order by query_date) as next_query_date
    from
        `dbt_assessment`.`staging`.`stg_user_queries`
), clean as (
    select
        query_date,
        user_id,
        next_query_date
    from
        data
    group by all
)
select
    query_date,
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
        (query_date)
    )