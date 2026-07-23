WITH stg_sale AS (
    SELECT *
    FROM {{ ref('stg_sale') }}
),
dim_product AS (
    SELECT product_key, product_id
    FROM {{ ref('dim_product') }}
),
dim_location AS (
    SELECT location_key, country_name
    FROM {{ ref('dim_location') }}
),
dim_location_by_country AS (
    SELECT
        LOWER(country_name) AS country_name,
        ANY_VALUE(location_key) AS location_key
    FROM dim_location
    GROUP BY 1
),
dim_currency AS (
    SELECT currency_key, currency_code
    FROM {{ ref('dim_currency') }}
),
dim_customer AS (
    SELECT customer_key, customer_db_id
    FROM {{ ref('dim_customer') }}
),
dim_date AS (
    SELECT date_key, time_stamp AS time_stamp
    FROM {{ ref('dim_date') }}
),
dim_store AS (
    SELECT store_key, store_id
    FROM {{ ref('dim_store') }}
),
fact_sale__join_dimentions AS (
    SELECT
        s.sale_key,
        dp.product_key,
        dl.location_key,
        dc.currency_key,
        dcu.customer_key,
        dd.date_key,
        ds.store_key,
        s.current_url,
        s.local_time,
        s.time_stamp,
        s.amount,
        s.price
    FROM stg_sale s
     JOIN dim_product dp ON dp.product_id = s.product_id
     JOIN dim_location_by_country dl ON dl.country_name = LOWER(s.country_name)
     JOIN dim_currency dc ON dc.currency_code = s.currency_code
     JOIN dim_customer dcu ON dcu.customer_db_id = s.user_id_db
     JOIN dim_date dd ON dd.time_stamp = s.time_stamp
     JOIN dim_store ds ON ds.store_id = s.store_id

),
fact_sale__dedup AS (
    SELECT DISTINCT *
    FROM fact_sale__join_dimentions
)

SELECT * FROM fact_sale__dedup