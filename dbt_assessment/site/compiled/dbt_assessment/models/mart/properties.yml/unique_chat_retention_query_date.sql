
    
    

select
    query_date as unique_field,
    count(*) as n_records

from `dbt_assessment`.`mart`.`chat_retention`
where query_date is not null
group by query_date
having count(*) > 1


