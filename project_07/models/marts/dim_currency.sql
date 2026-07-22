WITH stg_dim_currency AS (
    SELECT *
    FROM {{ ref('stg_dim_currency') }}
)
SELECT
    currency_id,
    currency_code,
    currency_name,
    inserted_date,
    inserted_by
FROM stg_dim_currency