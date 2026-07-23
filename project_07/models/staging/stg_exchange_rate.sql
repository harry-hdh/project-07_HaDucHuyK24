WITH stg_exchange_rate__source AS (
    SELECT *
    FROM {{ source('glamira_source', 'raw_exchange_rates') }}
),
stg_exchange_rate__select AS (
    SELECT
        time_stamp,
        currency_code,
        exchange_rate,
        inserted_date,
        inserted_by
    FROM stg_exchange_rate__source
),
stg_exchange_rate__gen_id AS (
    SELECT
        TIMESTAMP_SECONDS(time_stamp) AS time_stamp,
        currency_code,
        exchange_rate,
        inserted_date,
        inserted_by,
        FARM_FINGERPRINT(currency_code ||CAST(exchange_rate AS STRING) || CAST(inserted_date AS STRING) || CAST(inserted_by AS STRING)) AS exchange_rate_key
    FROM stg_exchange_rate__select
)
SELECT * FROM stg_exchange_rate__gen_id