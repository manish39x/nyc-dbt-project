SELECT
    vendor_id
FROM {{ ref('stg_taxi_trips__green') }}
WHERE dropoff_datetime < pickup_datetime
UNION ALL
SELECT
    vendor_id
FROM {{ ref('stg_taxi_trips__yellow') }}
WHERE dropoff_datetime < pickup_datetime