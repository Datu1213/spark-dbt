-- models/stg_user_events.sql

-- Hive will not genarate table
-- It will store the view definition in the metastore
-- that points to the data location
-- which means there is no data duplication

-- 'even_minute' is not user in dbt logic layer
-- it will be used in physical layer(Spark) 
-- for partitioning optimization

select
    user_id,
    event_type,
    page,
    value as purchase_value,
    event_timestamp as ts -- Rename for clarity
from delta.`s3a://prod-data/data/user_events_delta`