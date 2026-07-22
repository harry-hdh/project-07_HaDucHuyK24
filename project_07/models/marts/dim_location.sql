WITH stg_location AS (
    SELECT * FROM {{ ref('stg_dim_location') }}
)
SELECT
    location_key,
    country_name,
    region_name,
    city_name
FROM stg_location