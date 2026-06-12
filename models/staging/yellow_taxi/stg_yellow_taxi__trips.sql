with 

source as (

    select * from {{ source('yellow_taxi', 'yellow_taxi_trips') }}

),

renamed as (

    select
        raw_data

    from source

)

select * from renamed