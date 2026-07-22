WITH stg_dim_product AS (
    SELECT *
    FROM {{ ref('stg_dim_product') }}
)
SELECT
    product_key,
    product_id,
    product_name,
    product_category_name,
    product_min_price,
    product_max_price,
    product_collection_name,
    product_attribute,
    product_gold_weight,
    product_silver_weight,
    product_non_metal_weight,
    product_gender
FROM stg_dim_product