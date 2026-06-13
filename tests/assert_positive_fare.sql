SELECT
    vendor_id
FROM {{ ref('stg_taxi_trips__green') }}
WHERE fare_amount < 0
UNION ALL
SELECT
    vendor_id
FROM {{ ref('stg_taxi_trips__yellow') }}
WHERE fare_amount < 0