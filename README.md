# Digital Green Assessment

#### Objective: 
The objective of the assessment is to clean and transform firebase_events and user_queries (two csv files provided as part of the assessment). Finally, to create an interactive dashboard clearly outlining metric definitions, etc

Listing down the objectives:
1. Data transformation
2. Data Validation
3. Analysis and Interactive Dashboard

## Data Transformation
I have used **dbt** as the framework of choice for the transformation layer. 

### Instructions to replicate the transformation layer

Detailed instructions are present [here](/replicate_dbt_project.md)

To summarize, you need to clone this git repository and open the `CMD` in the dbt_assessment directory and run the following commands:
```
dbt seed
dbt run
dbt test
dbt docs generate --target-path site
dbt docs serve
```

The last two commands `dbt docs generate --target-path site` generates the documentation using the yml files in the project while `dbt docs serve` hosts it on localhost for consumption

### The transformation
#### raw
We use the 2 seed files to ingest them into `dbt_assessment.raw.<table_name>`, i.e., our files are ingested as `dbt_assessment.raw.firebase_events` and `dbt_assessment.raw.user_queries`

#### staging
With the 2 raw tables that we have ingested, we build 3 staging tables. 
1. `stg_user_queries`: An **incremental** staging model that aggregates user chat queries on a daily basis. It collapses individual query events into a daily summary per user, capturing the array of distinct query types, languages detected, and countries. It also nests detailed query metadata (such as timestamps and chat IDs) into a structured payload for deeper analysis.
2. `stg_firebase_events`: An **incremental** staging model that aggregates daily raw Firebase events at the user level. It calculates daily session boundaries and utilizes conditional aggregates to pivot event names into boolean flags (1/0), tracking key user milestones like onboarding, permissions, content viewership, and chat interactions.
3. `stg_firebase_events_n_queries`: An enriched staging model that joins daily Firebase user sessions with their corresponding chat queries. It filters specifically for users who had chat interactions and aligns the query timestamps strictly within the boundaries of the user's daily app session, providing a unified view of demographic data, app milestones, and query metadata.  
4. `stg_user_fact`: A fact table which holds non-null attributes for each user. The attributes are updated as per the latest record received from user_queries and is updated using **incremental** merge strategy

#### mart
Here we store business metrics and KPIs like 
- weekly_active_users
- conversion_rate
- retention
- country split of users who queried
- gender split of users who queried

Below is the lineage of our pipeline:
    ![user_queries_lineage](/artifacts/user_queries_lineage.png)
    ![firebase_events_lineage](/artifacts/firebase_events_lineage.png)


## Data Validation
I have used `dbt test` feature to perform data validation tests. I have also created custom tests like `unique_two_cols` and `variance`. You can find these at [/tests/generic/test_unique_two_cols.sql](/dbt_assessment/tests/generic/test_unique_two_cols.sql) and [/tests/generic/test_variance.sql](/dbt_assessment/tests/generic/test_variance.sql). 

DBT is running **23** data validation tests in the backend everytime you run `dbt test`. 

Here is a list of all the tests performed:
- `not_null`: tests to see if column has any nulls. If nulls are present, the test will fail
- `unique`: tests to see if column has unique records. If more than one record for column is found, the test will fail
- `unique_two_cols`: tests to see if the table is unique at two columns (composite key). E.g. in our project, we test to see if stg_user_queries model is unique at query_date and user_id level
- `variance`: tests to see if no. of records for latest date vs last 7 days from latest date is within absolute 1.96 z-score. If variation is >1.96 then the test will fail.
- `relationships`: tests for referential integrity, i.e., all records from table should be present as foreign key in another table 

## Interactive dashboard
I have used powerbi to create an interactive dashboard showcasing the following metrics:
 - weekly firebase users
 - weekly conversion rate
 - country ratio of users who queried on FarmerChat
 - gender split of users who queried on FarmerChat
 - 3day, 7day and 14day retention

![dashboard](/artifacts/dashboard.png)
