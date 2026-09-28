
    
    

select
    event_date as unique_field,
    count(*) as n_records

from `dbt_assessment`.`mart`.`firebase_retention`
where event_date is not null
group by event_date
having count(*) > 1


