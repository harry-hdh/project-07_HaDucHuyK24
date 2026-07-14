{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is not none -%}
        {# # Forces dbt to use EXACTLY 'staging' or 'marts' as the dataset name #}
        {{ custom_schema_name | trim | lower }}
    {%- else -%}
        {{ target.schema }}
    {%- endif -%}
{%- endmacro %}