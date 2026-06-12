WITH source AS (
    SELECT * FROM {{ source('src_nyc_taxi', 'green_taxi_trips') }}
),

renamed AS (
    SELECT
    --  identifiers
        'green'                                                                 as taxi_type
        raw_data['VendorID']::INT                                               as vendor_id,
        raw_data['RatecodeID']::INT                                             as rate_code_id,
        raw_data['PULocationID']::INT                                           as pickup_location_id,
        raw_data['DOLocationID']::INT                                           as dropoff_location_id,
    --  timestamps
        TO_TIMESTAMP(raw_data['lpep_pickup_datetime']::NUMBER / 1000000, 0)        as pickup_datetime,
        TO_TIMESTAMP(raw_data['lpep_dropoff_datetime']::NUMBER / 1000000, 0)       as dropoff_datetime,
    --  trip info
        raw_data['passenger_count']::INT                                           as passenger_count,
        raw_data['trip_distance']::FLOAT                                           as trip_distance,
        raw_data['store_and_fwd_flag']::VARCHAR                                    as store_and_fwd_flag,
        raw_data['payment_type']::INT                                              as payment_type,
        DATEDIFF('minute', pickup_datetime, dropoff_datetime)                      as trip_duration,
    --  financials
        raw_data['fare_amount']::FLOAT                                             as fare_amount,
        raw_data['extra']::FLOAT                                                   as extra,
        raw_data['mta_tax']::FLOAT                                                 as mta_tax,
        raw_data['tip_amount']::FLOAT                                              as tip_amount,
        raw_data['tolls_amount']::FLOAT                                            as tolls_amount,
        raw_data['improvement_surcharge']::FLOAT                                   as improvement_surcharge,
        raw_data['total_amount']::FLOAT                                            as total_amount,
        raw_data['congestion_surcharge']::FLOAT                                    as congestion_surcharge,
    FROM source
    WHERE raw_data:trip_distance::FLOAT > 0
    AND raw_data:total_amount::FLOAT > 0
    AND raw_data:passenger_count::INT > 0
    AND YEAR(TO_TIMESTAMP(raw_data:lpep_pickup_datetime::NUMBER / 1000000, 0)) BETWEEN 2014 AND 2026
)

SELECT * FROM renamed