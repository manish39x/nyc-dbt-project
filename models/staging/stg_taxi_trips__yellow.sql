WITH source AS (
    SELECT * FROM {{ source('src_nyc_taxi', 'yellow_taxi_trips') }}
),

renamed AS (
    SELECT
    -- identifiers
        'yellow'                                                                as taxi_type,
        raw_data['VendorID']::INT                                               as vendor_id,
        raw_data['RatecodeID']::INT                                             as rate_code_id,
        raw_data['PULocationID']::INT                                           as pickup_location_id,
        raw_data['DOLocationID']::INT                                           as dropoff_location_id,
    -- timestamps
        TO_TIMESTAMP(raw_data['tpep_pickup_datetime']::NUMBER / 1000000, 0)        as pickup_datetime,
        TO_TIMESTAMP(raw_data['tpep_dropoff_datetime']::NUMBER / 1000000, 0)       as dropoff_datetime,
    -- trip info
        raw_data['passenger_count']::INT                                           as passenger_count,
        raw_data['trip_distance']::FLOAT                                           as trip_distance,
        raw_data['store_and_fwd_flag']::VARCHAR                                    as store_and_fwd_flag,
        raw_data['payment_type']::INT                                              as payment_type,
        DATEDIFF('minute', pickup_datetime, dropoff_datetime)                      as trip_duration_minutes,
    -- financials
        raw_data['fare_amount']::FLOAT                                             as fare_amount,
        raw_data['extra']::FLOAT                                                   as extra,
        raw_data['mta_tax']::FLOAT                                                 as mta_tax,
        raw_data['tip_amount']::FLOAT                                              as tip_amount,
        raw_data['tolls_amount']::FLOAT                                            as tolls_amount,
        raw_data['improvement_surcharge']::FLOAT                                   as improvement_surcharge,
        raw_data['total_amount']::FLOAT                                            as total_amount,
        raw_data['congestion_surcharge']::FLOAT                                    as congestion_surcharge,
        raw_data['Airport_fee']::FLOAT                                             as airport_fee,
        raw_data['cbd_congestion_fee']::FLOAT                                      as cbd_congestion_fee
    FROM source
    WHERE raw_data['trip_distance']::FLOAT > 0 AND raw_data['trip_distance'] < 200
    AND raw_data['total_amount']::FLOAT > 0.5 AND raw_data['total_amount'] < 1000
    AND raw_data['fare_amount']::FLOAT > 0.5 AND raw_data['fare_amount'] < 1000
    AND raw_data['passenger_count']::INT > 0 AND raw_data['passenger_count']::INT < 9
    AND raw_data['VendorID']::INT IN (1, 2, 6, 7)
    AND DATE(TO_TIMESTAMP(raw_data['tpep_pickup_datetime']::NUMBER / 1000000, 0)) BETWEEN DATE('2014-01-01') AND DATE('2026-03-01')
    AND TO_TIMESTAMP(raw_data['lpep_pickup_datetime']::NUMBER / 1000000, 0) < TO_TIMESTAMP(raw_data['lpep_dropoff_datetime']::NUMBER / 1000000, 0)
    AND DATEDIFF('minute', pickup_datetime, dropoff_datetime) > 0
)

SELECT * FROM renamed