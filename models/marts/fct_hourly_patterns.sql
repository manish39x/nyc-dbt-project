{{config(materialized='table')}}

SELECT
    pickup_hour,
    day_type,
    taxi_type,
    pickup_year,
    COUNT(*)            AS total_trips,
    AVG(total_amount)   AS avg_fare,
    AVG(trip_distance)  AS avg_distance
FROM {{ ref('int_all_trips') }}
GROUP BY 1,2,3,4