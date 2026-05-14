{{ config(materialized='incremental', incremental_strategy='append', unique_key='HASH_KEY') }}

with flattened_outputs AS (

select
tx.hash_key,
tx.block_number,
tx.block_timestamp,
tx.is_coinbase,
f.value:address::STRING as output_address,
f.value:value::FLOAT as output_value

from {{ ref('stg_btc') }} tx,

LATERAL FLATTEN( input => outputs) f

WHERE f.value:address IS NOT NULL

{% if is_incremental() %}

AND tx.block_timestamp >= (select max(BLOCK_TIMESTAMP) from {{ this }})

{% endif %}
)

SELECT
hash_key,
block_number,
block_timestamp,
is_coinbase,
output_address,
output_value
FROM flattened_outputs