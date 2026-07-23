WITH stg_exchange_rate AS (
    SELECT *
    FROM {{ ref('stg_exchange_rate') }}
),
dim_currency AS (
    SELECT currency_key, currency_code
    FROM {{ ref('dim_currency') }}
),
dim_date AS (
    SELECT date_key, time_stamp AS time_stamp
    FROM {{ ref('dim_date') }}
),
fact_exchange_rate__join_dimentions AS (
    SELECT
        der.exchange_rate_key,
        dc.currency_key,
        dd.date_key,
        der.exchange_rate,
        der.inserted_date,
        der.inserted_by
    FROM stg_exchange_rate der
     JOIN dim_currency dc ON dc.currency_code = der.currency_code
     JOIN dim_date dd ON dd.time_stamp = der.time_stamp
),
fact_exchange_rate__dedup AS (
    SELECT DISTINCT *
    FROM fact_exchange_rate__join_dimentions
)
SELECT * FROM fact_exchange_rate__dedup