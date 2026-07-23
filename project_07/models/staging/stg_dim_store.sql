WITH stg_dim_store__source AS (
    SELECT *
    FROM {{ source('glamira_source', 'summary19') }}
), 
stg_dim_store__process_url AS (
    SELECT
        store_id,
        concat('https://', net.host(current_url), '/') AS store_url

    FROM stg_dim_store__source
),
stg_dim_store__filtered AS (
    SELECT *
    FROM stg_dim_store__process_url
    WHERE store_url IS NOT NULL
    AND store_url like '%glamira.%'
),
stg_dim_store__extract AS (
    SELECT
        store_id,
        store_url,
        regexp_extract(net.host(store_url), r'\.([a-zA-Z]+)$') as store_extension

    FROM stg_dim_store__filtered
),

stg_dim_store__transform_extension AS (
    SELECT 
        store_id,
        store_url,
        case lower(store_extension)
            when 'com' then 'Global'
            when 'au' then 'Australia'
            when 'hk' then 'Hong Kong'
            when 'cn' then 'China'
            when 'ca' then 'Canada'
            when 'pl' then 'Poland'
            when 'cz' then 'Czech Republic'
            when 'sk' then 'Slovakia'
            when 'hu' then 'Hungary'
            when 'ro' then 'Romania'
            when 'br' then 'Brazil'
            when 'ch' then 'Switzerland'
            when 'de' then 'Germany'
            when 'fr' then 'France'
            when 'es' then 'Spain'
            when 'pt' then 'Portugal'
            when 'nl' then 'Netherlands'
            when 'be' then 'Belgium'
            when 'at' then 'Austria'
            when 'se' then 'Sweden'
            when 'no' then 'Norway'
            when 'fi' then 'Finland'
            when 'dk' then 'Denmark'
            when 'si' then 'Slovenia'
            when 'rs' then 'Serbia'
            when 'ba' then 'Bosnia and Herzegovina'
            when 'me' then 'Montenegro'
            when 'hn' then 'Honduras'
            when 'it' then 'Italy'
            when 'gt' then 'Guatemala'
            when 'sg' then 'Singapore'
            when 'mx' then 'Mexico'
            when 'local' then 'Local'
            else 'Unknown'
        end as store_extension
    FROM stg_dim_store__extract
),

stg_dim_store__store_name AS (
    SELECT
        store_id,
        store_url,
        concat('Glamira', ' ', store_extension) as store_name
    FROM stg_dim_store__transform_extension
),
stg_dim_store__cast_type AS (
    SELECT
        COALESCE(CAST(store_id AS INT64), -1) AS store_id,
        CAST(store_url AS STRING) AS store_url,
        CAST(store_name AS STRING) AS store_name
    FROM stg_dim_store__store_name
),
stg_dim_store__dedup AS (
    SELECT DISTINCT *
    FROM stg_dim_store__cast_type
),
stg_dim_store__gen_key AS (
    SELECT
        store_id,
        store_url,
        store_name,
        FARM_FINGERPRINT(store_url || store_name) AS store_key
    FROM stg_dim_store__dedup
)
SELECT *
FROM stg_dim_store__gen_key