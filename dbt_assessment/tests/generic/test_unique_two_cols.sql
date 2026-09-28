{% test unique_two_cols(model, column_name, column_name2)%}

    with validation (
        select
            {{column_name}},
            {{column_name2}},
            count(*)
        from
            {{model}}
        group by 1,2
        having count(*)>1
    )
    select * from validation

{% endtest %}