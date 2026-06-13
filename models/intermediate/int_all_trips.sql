WITH yellow_taxi_data AS (
    SELECT * FROM {{ ref('stg_taxi_trips__yellow') }}
),
green_taxi_data AS (
    SELECT * FROM {{ ref('stg_taxi_trips__green') }}
),
all_trips AS (
    SELECT * FROM yellow_taxi_data
    UNION ALL
    SELECT 
        *,
        NULL  AS airport_fee
    FROM green_taxi_data
),
zone_lookup AS (
    SELECT * FROM {{ ref('taxi_zone_lookup') }}
),


enriched AS (
    SELECT
    --  core trip columns from staging
        t.taxi_type,
        t.vendor_id,
        t.pickup_datetime,
        t.dropoff_datetime,
        t.trip_duration_minutes,
        t.passenger_count,
        t.trip_distance,
        t.store_and_fwd_flag,
        t.payment_type,
        t.fare_amount,
        t.tip_amount,
        t.total_amount,
        t.rate_code_id,
        t.extra,
        t.mta_tax,
        t.tolls_amount,
        t.improvement_surcharge,
        t.congestion_surcharge,
        t.airport_fee,
        t.cbd_congestion_fee,

    --  decoded columns
        CASE t.vendor_id
            WHEN 1 THEN 'Creative Mobile Technologies, LLC'
            WHEN 2 THEN 'Curb Mobility, LLC'
            WHEN 6 THEN 'Myle Technologies Inc'
            WHEN 7 THEN 'Helix'
        END                                 AS vendor_name,
        CASE t.rate_code_id
            WHEN 1 THEN 'Standard rate'
            WHEN 2 THEN 'JFK'
            WHEN 3 THEN 'Newark'
            WHEN 4 THEN 'Nassau or Westchester'
            WHEN 5 THEN 'Negotiated fare'
            WHEN 6 THEN 'Group ride'
            WHEN 99 THEN  'Null/unknown'
        END                                 AS rate_type,
        CASE t.payment_type
            WHEN 0 THEN 'Flex Fare trip'
            WHEN 1 THEN 'Credit Card'
            WHEN 2 THEN 'Cash'
            WHEN 3 THEN 'No Charge'
            WHEN 4 THEN 'Dispute'
            WHEN 6 THEN 'Voided trip'
            ELSE 'Unknown'
        END                                 AS payment_type_disc,
    --  time dimensions
        DATE(t.pickup_datetime)            AS pickup_date,
        YEAR(t.pickup_datetime)            AS pickup_year,
        MONTH(t.pickup_datetime)            AS pickup_month,
        HOUR(t.pickup_datetime)            AS pickup_hour,
        CASE
            WHEN DAYOFWEEK(t.pickup_datetime) IN (1, 7) THEN 'Weekend'
            ELSE 'Weekday'
        END                                AS day_type,
    --  zone enrichment
        p_up.zone                         AS pickup_zone,
        p_up.borough                      AS pickup_borough,
        d_off.zone                         AS dropoff_zone,
        d_off.borough                      AS dropoff_borough
    FROM all_trips t
    LEFT JOIN zone_lookup p_up ON t.pickup_location_id = p_up.LocationID
    LEFT JOIN zone_lookup d_off ON t.dropoff_location_id = d_off.LocationID
)

SELECT * FROM enriched