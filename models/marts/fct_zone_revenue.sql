{{ config(materialized='table') }}

SELECT
    pickup_borough,
    pickup_zone,
    taxi_type,
    pickup_year,
    COUNT(*)                                                    AS total_trips,
    SUM(total_amount)                                           AS total_revenue,
    AVG(total_amount)                                           AS avg_fare,
    AVG(trip_distance)                                          AS avg_distance,
    ROUND(AVG(tip_amount/NULLIF(fare_amount, 0)) * 100, 2)      AS avg_tip_percentage
FROM {{ ref('int_all_trips') }}
GROUP BY 1,2,3,4