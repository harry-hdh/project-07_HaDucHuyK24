WITH stg_dim_product__source AS (
    SELECT *
    FROM {{ source('glamira_source', 'product_info') }}
),
stg_dim_product__rename AS (
    SELECT
        product_id AS product_id,
        name AS product_name,
        category_name AS product_category_name,
        min_price AS product_min_price,
        max_price AS product_max_price,
        collection AS product_collection_name,
        attribute_set AS product_attribute,
        gold_weight AS product_gold_weight,
        fixed_silver_weight AS product_silver_weight,
        none_metal_weight AS product_non_metal_weight,
        gender AS product_gender

    FROM stg_dim_product__source
),
stg_dim_product__cast_type AS (
    SELECT
        CAST(product_id AS INT64) AS product_id,
        CAST(product_name AS STRING) AS product_name,
        CAST(product_category_name AS STRING) AS product_category_name,
        CAST(product_min_price AS FLOAT64) AS product_min_price,
        CAST(product_max_price AS FLOAT64) AS product_max_price,
        CAST(product_collection_name AS STRING) AS product_collection_name,
        CAST(product_attribute AS STRING) AS product_attribute,
        CAST(product_gold_weight AS FLOAT64) AS product_gold_weight,
        CAST(product_silver_weight AS FLOAT64) AS product_silver_weight,
        CAST(product_non_metal_weight AS FLOAT64) AS product_non_metal_weight,
        CAST(product_gender AS STRING) AS product_gender
    FROM stg_dim_product__rename
),
stg_dim_product__dedup AS (
    SELECT DISTINCT *
    FROM stg_dim_product__cast_type
)

SELECT *
FROM stg_dim_product__dedup