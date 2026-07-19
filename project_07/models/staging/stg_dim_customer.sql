WITH stg_dim_customer__source AS (
    SELECT *
    FROM {{ source('glamira_source', 'summary19') }}
),
stg_dim_customer__extract AS (
    SELECT
        user_id_db AS customer_db_id,
        resolution AS customer_resolution,
        email_address AS customer_email_address,
        user_agent
    FROM stg_dim_customer__source
), 
stg_dim_customer__process AS (
    SELECT
        COALESCE(SAFE_CAST(customer_db_id AS INT64), -1) AS customer_db_id,
        customer_resolution,
        CASE WHEN customer_email_address IS NULL OR customer_email_address = '' 
            THEN 'Unknown' ELSE customer_email_address 
            END AS customer_email_address,
        CASE 
            WHEN user_agent LIKE '%Windows%' THEN 'Personal Computer'
            WHEN user_agent LIKE '%Macintosh%' THEN 'Personal Computer'
            WHEN user_agent LIKE '%Linux%' THEN 'Personal Computer'
            WHEN user_agent LIKE '%Android%' THEN 'Mobile Device'
            WHEN user_agent LIKE '%iPhone%' THEN 'Mobile Device'
            WHEN user_agent LIKE '%iPad%' THEN 'Tablet Device'
            WHEN user_agent LIKE '%Tablet%' THEN 'Tablet Device'
            WHEN user_agent LIKE '%TV%' THEN 'Smart TV'
            WHEN user_agent LIKE '%Console%' THEN 'Gaming Console'
            WHEN user_agent LIKE '%Wearable%' THEN 'Wearable Device'
            WHEN user_agent LIKE '%IoT%' THEN 'IoT Device'
            ELSE 'Unknown'
        END AS customer_device_type
    FROM stg_dim_customer__extract
),
stg__dim_customer__dedup AS (
    SELECT DISTINCT *
    FROM stg_dim_customer__process
),
stg_dim_customer__cast_type AS (
    SELECT
        CAST(customer_db_id AS INT64) AS customer_db_id,
        CAST(customer_resolution AS STRING) AS customer_resolution,
        CAST(customer_email_address AS STRING) AS customer_email_address,
        CAST(customer_device_type AS STRING) AS customer_device_type
    FROM stg__dim_customer__dedup
),
stg_dim_customer__gen_key AS (
    SELECT
        customer_db_id,
        customer_resolution,
        customer_email_address,
        customer_device_type,
        FARM_FINGERPRINT(customer_resolution || customer_email_address || customer_device_type) AS customer_id
    FROM stg_dim_customer__cast_type
)
SELECT *
FROM stg_dim_customer__gen_key
