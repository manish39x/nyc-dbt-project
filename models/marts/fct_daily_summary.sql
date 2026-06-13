{{ config(materialized='table') }}


SELECT
    pickup_date,
    pickup_year,
    pickup_month,
    day_type,
    taxi_type,
    COUNT(*)                                            AS total_trips,
    SUM(total_amount)                                   AS total_revenue,
    AVG(total_amount)                                   AS avg_fare,
    AVG(trip_distance)                                  AS avg_distance,
    AVG(trip_duration_minutes)                          AS avg_duration_minutes,
    SUM(tip_amount)                                     AS total_tips,
    AVG(tip_amount / NULLIF(fare_amount, 0)) * 100      AS avg_tip_percentage
FROM {{ ref('int_all_trips') }}
GROUP BY 1, 2, 3, 4, 5