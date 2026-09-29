{{config(schema="staging")}}
with data as (
    select 
        user_id,
        query_timestamp,
        country,
        replace(gender, 'gender_all_', '') as gender,
        language_detected
    from
        {{ref("user_queries")}}
    {% if is_incremental() %}
      where query_timestamp >= coalesce((select max(updated_at) - interval 3 day from {{ this }}), '1900-01-01 00:00:00"')
    {% endif %}
), country_time as (
    select
        user_id,
        max(query_timestamp) as updated_at
    from
        data
    where
        country is not null
    group by 
        1
), gender_time as (
    select
        user_id,
        max(query_timestamp) as updated_at
    from
        data
    where
        nullif(gender, '-') is not null
    group by 1
), langugage_time as (
    select
        user_id,
        max(query_timestamp) as updated_at
    from
        data
    where
        language_detected is not null
    group by 1
), country as (
    select
        a.user_id,
        a.country,
        b.updated_at
    from
        data a
        inner join country_time b 
        on a.user_id = b.user_id 
        and a.query_timestamp = b.updated_at
), gender as (
    select
        a.user_id,
        a.gender,
        b.updated_at
    from
        data a
        inner join gender_time b 
        on a.user_id = b.user_id 
        and a.query_timestamp = b.updated_at
), language_ as (
    select
        a.user_id,
        a.language_detected,
        b.updated_at
    from
        data a
        inner join langugage_time b 
        on a.user_id = b.user_id 
        and a.query_timestamp = b.updated_at
)
select 
    coalesce(a.user_id, b.user_id, c.user_id) as user_id, 
    a.country, 
    b.gender, 
    c.language_detected, 
    greatest(a.updated_at, b.updated_at, c.updated_at) as updated_at 
from 
    country a 
    full outer join gender b on a.user_id = b.user_id 
    full outer join language_ c on a.user_id = c.user_id
group by all;