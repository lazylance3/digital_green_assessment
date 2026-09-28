
    
    

select
    week_ as unique_field,
    count(*) as n_records

from `dbt_assessment`.`mart`.`weekly_active_users`
where week_ is not null
group by week_
having count(*) > 1


