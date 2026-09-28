{% test variance(model, column_name)%}
with data as (
    select  
        {{column_name}},
        count(*) as records
    from    
        {{model}}
    where
        {{column_name}} > (select max({{column_name}}) - interval 8 day from {{model}})
    group by 1
), validation as (
    select 
        avg(case when {{column_name}} < (select max({{column_name}}) from {{model}}) then records end) as avg_,
        stddev(case when {{column_name}} < (select max({{column_name}}) from {{model}}) then records end) as stddev_,
        max(case when {{column_name}} = (select max({{column_name}}) from {{model}}) then records end) as records_,
        (records_ - avg_) / stddev_ as z_score
    from 
        data
)
select * from validation where abs(z_score) > 1.96

{% endtest %}