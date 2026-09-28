{{config(schema='staging')}}
select  
    date(query_timestamp) as query_date,
    user_id,
    collect_set(replace(gender, 'gender_all_', '')) as gender,
    collect_set(country) as country,
    collect_set(query_type) as query_type,
    collect_set(language_detected) as language_detected,
    count(distinct query_id) as n_queries,
    min(query_timestamp) as query_start_time,
    max(query_timestamp) as query_end_time,
    collect_list(
        named_struct(
            'chat_id', chat_id,
            'query_details', named_struct(
                'query_id', query_id,
                'query_timestamp', query_timestamp,
                'query_type', query_type,
                'language_detected', language_detected
            )
        )
    ) as payload
from
    {{ ref('user_queries') }}

{% if is_incremental() %}
  where date(query_timestamp) >= (select max(query_date) from {{ this }})
{% endif %}
group by 1,2;
    