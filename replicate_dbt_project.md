### Instructions to replicate the transformation layer

1. Clone this github repository: [digital green assessment](https://github.com/lazylance3/digital_green_assessment.git)
2. Open cmd from the repository directory and `run pip install -r requirements.txt`
3. This will install `dbt-core` and `dbt-databricks` adapter into your system
4. Next, change directory to `dbt_assessment` folder within the repository.
5. Now, rename `profilesPS.yml` file to `profiles.yml` and add your databricks configuration, i.e., 
    1. databricks host
    2. http_path and 
    3. token (`databricks settings -> developer -> manage access tokens`)
6. You can fetch the 1st two of these details from `databricks -> compute -> sql warehouses -> serverless warehouse -> connection details`

    ![connection details](/artifacts/connection_details.png)

7. Also, go to catalog from the menu page and create a new catalog named `dbt_assessment`

    ![create catalog](/artifacts/databricks_create_catalog.png)    
6. Once the setup is complete, execute `dbt seed` in the command line. 
    > Note that you should be inside the `dbt_assessment` directory where `models` and `dbt_project.yml` files are present.
7. `dbt seed` will use the csv files inside the seeds directory to create tables in databricks. This should be within `dbt_assessment` catalog and `raw` schema (you can cross check in `profiles.yml` file). The csv files provided for the assessment are `firebase_events.csv` and `user_queries.csv`. 
8. You should see `Finished running 2 seeds in x hours x minutes`

    ![atl text](/artifacts/seed.png)
9. Now execute `dbt run` and wait. You should now see a "Completed Successfully" message. Dbt should now have created `8 tables and 1 view` within `dbt_assessment` catalog in databricks

    ![alt text](/artifacts/run.png)
10. Finally, execute `dbt test` to run the data validation tests defined within `dbt_assessment` project. 

    ![test](/artifacts/test.png)

11. Note that documentation for this project has been generated through `dbt docs generate --target-path site`. You can view the documentation within VSCode under `site/index.html`
