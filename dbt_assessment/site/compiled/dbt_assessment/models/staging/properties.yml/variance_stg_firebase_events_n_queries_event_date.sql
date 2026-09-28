
with data as (
    select  
        event_date,
        count(*) as records
    from    
        `dbt_assessment`.`staging`.`stg_firebase_events_n_queries`
    where
        event_date > (select max(event_date) - interval 8 day from `dbt_assessment`.`staging`.`stg_firebase_events_n_queries`)
    group by 1
), validation as (
    select 
        avg(case when event_date < (select max(event_date) from `dbt_assessment`.`staging`.`stg_firebase_events_n_queries`) then records end) as avg_,
        stddev(case when event_date < (select max(event_date) from `dbt_assessment`.`staging`.`stg_firebase_events_n_queries`) then records end) as stddev_,
        max(case when event_date = (select max(event_date) from `dbt_assessment`.`staging`.`stg_firebase_events_n_queries`) then records end) as records_,
        (records_ - avg_) / stddev_ as z_score
    from 
        data
)
select * from validation where abs(z_score) > 1.96

