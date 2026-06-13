{{config(materialized='table')}}

SELECT * FROM {{ ref('int_all_trips') }}