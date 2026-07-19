WITH stg_dim_currency__source AS (
    SELECT *
    FROM {{ source('glamira_source', 'summary19') }}
),
stg_dim_currency__flatten AS (
    SELECT
        TRIM(CAST(cart.currency AS STRING)) AS currency_code
    FROM stg_dim_currency__source
    LEFT JOIN UNNEST(stg_dim_currency__source.cart_products) AS cart
    WHERE collection = 'checkout_success'
),

stg_dim_currency__process_null AS (
    SELECT
        CASE 
            WHEN currency_code IS NULL OR currency_code = '' THEN 'Unknown' 
            ELSE currency_code 
        END AS currency_code
    FROM stg_dim_currency__flatten
),
stg_dim_currency__dedup AS (
    SELECT DISTINCT *
    FROM stg_dim_currency__process_null
),
stg_dim_currency__process_currency AS(
    SELECT
        currency_code,
        CASE 
            WHEN currency_code = 'R$' THEN 'Brazilian Real'
            WHEN currency_code = 'COP $' THEN 'Colombian Peso'
            WHEN currency_code = 'AU $' THEN 'Australian Dollar'
            WHEN currency_code = 'PEN S/.' THEN 'Peruvian Sol'
            WHEN currency_code = '￥' THEN 'Chinese Yuan'
            WHEN currency_code = 'kr' THEN 'Swedish Krona'
            WHEN currency_code = '$' THEN 'US Dollar'
            WHEN currency_code = '€' THEN 'Euro'
            WHEN currency_code = 'SGD $' THEN 'Singapore Dollar'
            WHEN currency_code = '₹' THEN 'Indian Rupee'
            WHEN currency_code = '£' THEN 'British Pound Sterling'
            WHEN currency_code = '₱' THEN 'Philippine Peso'
            WHEN currency_code = '₲' THEN 'Paraguayan Guarani'
            WHEN currency_code = 'лв.' THEN 'Bulgarian Lev'
            WHEN currency_code = 'CRC ₡' THEN 'Costa Rican Colón'
            WHEN currency_code = '1din.' THEN 'Serbian Dinar'
            WHEN currency_code = 'NZD $' THEN 'New Zealand Dollar'
            WHEN currency_code = 'Kč' THEN 'Czech Koruna'
            WHEN currency_code = '₫' THEN 'Vietnamese Dong'
            WHEN currency_code = '₺' THEN 'Turkish Lira'
            WHEN currency_code = 'BOB Bs' THEN 'Bolivian Boliviano'
            WHEN currency_code = 'GTQ Q' THEN 'Guatemalan Quetzal'
            WHEN currency_code = 'HKD $' THEN 'Hong Kong Dollar'
            WHEN currency_code = 'Lei' THEN 'Romanian Leu'
            WHEN currency_code = 'د.ك.‏' THEN 'Kuwaiti Dinar'
            WHEN currency_code = 'Ft' THEN 'Hungarian Forint'
            WHEN currency_code = 'CAD $' THEN 'Canadian Dollar'
            WHEN currency_code = 'USD $' THEN 'United States Dollar'
            WHEN currency_code = 'zł' THEN 'Polish Zloty'
            WHEN currency_code = 'CLP' THEN 'Chilean Peso'
            WHEN currency_code = 'kn' THEN 'Croatian Kuna'
            WHEN currency_code = 'MXN $' THEN 'Mexican Peso'
            WHEN currency_code = 'DOP $' THEN 'Dominican Peso'
            WHEN currency_code = 'UYU' THEN 'Uruguayan Peso'
            WHEN currency_code = 'CHF' THEN 'Swiss Franc'
            WHEN currency_code = 'din.' THEN 'Serbian Dinar'
            ELSE 'Unknown Currency'
        END AS currency_name,
    FROM stg_dim_currency__dedup
),
stg_dim_currency__process_inserted AS (
    SELECT
        currency_code,
        currency_name,
        DATETIME_ADD(
            DATETIME '2019-01-01 00:00:00',
            INTERVAL CAST(FLOOR(RAND() * TIMESTAMP_DIFF(TIMESTAMP '2019-12-31 23:59:59', TIMESTAMP '2019-01-01 00:00:00', SECOND)) AS INT64) SECOND
        ) AS inserted_date,
        CONCAT('st', SUBSTR(GENERATE_UUID(), 1, 8)) AS inserted_by
    FROM stg_dim_currency__process_currency
),
stg_dim_currency__gen_key AS (
    SELECT
        currency_code,
        currency_name,
        inserted_date,
        inserted_by,
        FARM_FINGERPRINT(currency_code || currency_name || inserted_by) AS currency_id
    FROM stg_dim_currency__process_inserted
)
SELECT *
FROM stg_dim_currency__gen_key