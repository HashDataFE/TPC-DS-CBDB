CREATE EXTERNAL TABLE ext_tpcds.customer_address (like :DB_SCHEMA_NAME.customer_address)  
LOCATION (:LOCATION)
FORMAT 'TEXT' (DELIMITER '|' NULL AS '' ESCAPE AS E'\\');
