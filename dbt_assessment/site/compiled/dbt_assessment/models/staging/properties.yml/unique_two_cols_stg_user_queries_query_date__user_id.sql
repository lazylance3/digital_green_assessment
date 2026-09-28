

    with validation (
        select
            query_date,
            user_id,
            count(*)
        from
            `dbt_assessment`.`staging`.`stg_user_queries`
        group by 1,2
        having count(*)>1
    )
    select * from validation

