-- models/stg_user_events.sql

select
    user_id,
    event_type,
    page,
    value as purchase_value,
    event_timestamp as ts -- Rename for clarity
from delta.`/opt/spark/data/user_events_delta` -- <-- 重要：替换为 Spark Thrift Server 可以访问到的路径！