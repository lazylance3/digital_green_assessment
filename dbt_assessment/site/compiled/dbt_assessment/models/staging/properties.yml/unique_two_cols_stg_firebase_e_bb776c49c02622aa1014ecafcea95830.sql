

    with validation (
        select
            event_date,
            user_id,
            count(*)
        from
            `dbt_assessment`.`staging`.`stg_firebase_events_n_queries`
        group by 1,2
        having count(*)>1
    )
    select * from validation

