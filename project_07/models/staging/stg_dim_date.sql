WITH stg_dim_date__source AS (
    SELECT *
    FROM {{ source('glamira_source', 'summary19') }}
),
stg_dim_date__extract AS (
    SELECT
        time_stamp,
        EXTRACT(year FROM time_stamp) AS year,
        EXTRACT(month FROM time_stamp) AS month,
        EXTRACT(day FROM time_stamp) AS day,
        EXTRACT(hour FROM time_stamp) AS hour,
        EXTRACT(minute FROM time_stamp) AS minute,
        EXTRACT(second FROM time_stamp) AS second,
        FORMAT_DATE('%A', DATE(time_stamp)) AS week_day,
        CASE 
            WHEN EXTRACT(DAYOFWEEK FROM time_stamp) IN (1, 7) THEN 'TRUE'
            ELSE 'FALSE'
        END AS is_weekend,
        CASE 
            WHEN EXTRACT(DAYOFYEAR FROM DATE(time_stamp)) IN (1, 2, 3, 4, 5, 6, 7) THEN 'TRUE'
            ELSE 'FALSE'
        END AS is_holiday
    FROM stg_dim_date__source
),
stg_dim_date__process AS (
    SELECT
        time_stamp,
        year,
        month,
        day,
        CONCAT(hour, ':', minute, ':', second) AS time,
        week_day,
        is_weekend,
        is_holiday,
    FROM stg_dim_date__extract
),
stg_dim_date__cast_type AS (
    SELECT
        time_stamp,
        CAST(year AS INT64) AS year,
        CAST(month AS INT64) AS month,
        CAST(day AS INT64) AS day,
        CAST(time AS STRING) AS time,
        CAST(week_day AS STRING) AS week_day,
        CAST(is_weekend AS BOOLEAN) AS is_weekend,
        CAST(is_holiday AS BOOLEAN) AS is_holiday
    FROM stg_dim_date__process
),
stg_dim_date__gen_key AS (
    SELECT
        time_stamp,
        year,
        month,
        day,
        time,
        week_day,
        is_weekend,
        is_holiday,
        FARM_FINGERPRINT(year || month || day || time) AS date_key
    FROM stg_dim_date__cast_type
)
SELECT *
FROM stg_dim_date__gen_key