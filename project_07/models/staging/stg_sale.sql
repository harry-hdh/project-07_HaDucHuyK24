WITH stg_sale__source AS (
    SELECT *
    FROM {{ source('glamira_source', 'summary19') }}
    WHERE collection = 'checkout_success'
),
location__source AS (
    SELECT *
    FROM {{ source('glamira_source', 'ip_location') }}
),
stg_sale__extract AS (
    SELECT
        _id AS sale_key,
        store_id,
        COALESCE(SAFE_CAST(user_id_db AS INT64), -1) AS user_id_db,
        current_url,
        local_time,
        time_stamp,
        country,
        loc.country AS country_name,
        cart_products
    FROM stg_sale__source
    JOIN location__source loc ON stg_sale__source.ip = loc.ip
),
stg_sale__flatten AS (
    SELECT
        sale_key,
        store_id,
        user_id_db,
        current_url,
        local_time,
        time_stamp,
        country_name,
        TRIM(currency) AS currency_code,
        cart_product.product_id AS product_id,
        cart_product.amount AS amount,
        cart_product.price AS price,
    FROM stg_sale__extract
    LEFT JOIN UNNEST(stg_sale__extract.cart_products) AS cart_product
),
stg_sale__clean_price AS (
    SELECT
        sale_key,
        COALESCE(CAST(store_id AS INT64), -1) AS store_id,
        COALESCE(user_id_db, -1) AS user_id_db,
        current_url,
        currency_code,
        local_time,
        time_stamp,
        country_name,
        COALESCE(product_id, -1) AS product_id,
        amount,
        SAFE_CAST(REGEXP_REPLACE(price, r'[^0-9.]', '.') AS FLOAT64) AS price
    FROM stg_sale__flatten
    WHERE price IS NOT NULL
)
SELECT * FROM stg_sale__clean_price