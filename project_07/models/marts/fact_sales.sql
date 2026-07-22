WITH stg_sale AS (
    SELECT *
    FROM {{ ref('stg_sale') }}
),
fact_sale__join_dimentions AS (
    SELECT
        sale_id,
        current_url,
        local_time,
        time_stamp,
        ip_address,
        amount,
    FROM stg_sale s
    JOIN dim_product dp ON dp.product_id
)