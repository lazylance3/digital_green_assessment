
with data as (
    select  
        query_date,
        count(*) as records
    from    
        `dbt_assessment`.`staging`.`stg_user_queries`
    where
        query_date > (select max(query_date) - interval 8 day from `dbt_assessment`.`staging`.`stg_user_queries`)
    group by 1
), validation as (
    select 
        avg(case when query_date < (select max(query_date) from `dbt_assessment`.`staging`.`stg_user_queries`) then records end) as avg_,
        stddev(case when query_date < (select max(query_date) from `dbt_assessment`.`staging`.`stg_user_queries`) then records end) as stddev_,
        max(case when query_date = (select max(query_date) from `dbt_assessment`.`staging`.`stg_user_queries`) then records end) as records_,
        (records_ - avg_) / stddev_ as z_score
    from 
        data
)
select * from validation where abs(z_score) > 1.96

