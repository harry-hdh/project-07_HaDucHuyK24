WITH stg_dim_store AS (
    SELECT *
    FROM {{ ref('stg_dim_store') }}
),
stg_dim_store_dedup AS (
    SELECT store_key,
    store_url,
    store_name,
    store_id,
    row_number() OVER (PARTITION BY store_id ORDER BY store_name) AS rn
    FROM stg_dim_store
)
SELECT
    store_key,
    store_id,
    store_url,
    store_name
FROM stg_dim_store_dedup
WHERE rn = 1