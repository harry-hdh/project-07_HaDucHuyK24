WITH stg_dim_customer AS (
    SELECT *
    FROM {{ ref('stg_dim_customer') }}
)
SELECT
    customer_id,
    customer_resolution,
    customer_email_address,
    customer_device_type,
    customer_db_id
FROM stg_dim_customer