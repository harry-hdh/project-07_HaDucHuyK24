WITH stg_dim_sale__source AS (
    SELECT *
    FROM {{ source('glamira_source', 'summary19') }}
    WHERE collection = 'checkout_success'
)
SELECT * FROM stg_dim_sale__source