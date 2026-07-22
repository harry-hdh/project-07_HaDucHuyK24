With stg_dim_date AS (
    SELECT * FROM {{ ref('stg_dim_date') }}
)
SELECT
    date_id,
    year,
    month,
    day,
    time,
    week_day,
    is_weekend,
    is_holiday
FROM stg_dim_date