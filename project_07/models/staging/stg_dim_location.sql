WITH stg_dim_location__source AS (
    SELECT *
    FROM {{ source('glamira_source', 'ip_location') }}
),

stg_dim_location__rename AS (
    SELECT
        ip AS location_ip,
        country AS country_name,
        region AS region_name,
        city AS city_name

    FROM stg_dim_location__source
),

stg_dim_location__cast_type AS (
    SELECT
        CAST(location_ip AS STRING) AS location_ip,
        CAST(country_name AS STRING) AS country_name,
        CAST(region_name AS STRING) AS region_name,
        CAST(city_name AS STRING) AS city_name
    FROM stg_dim_location__rename
),

stg_dim_location__dedup AS (
    SELECT DISTINCT *
    FROM stg_dim_location__cast_type
),

stg_dim_location__gen_key AS (
    SELECT
        location_ip,
        country_name,
        region_name,
        city_name,
        FARM_FINGERPRINT(country_name || region_name || city_name) AS location_id
    FROM stg_dim_location__dedup
)

SELECT *
FROM stg_dim_location__gen_key
