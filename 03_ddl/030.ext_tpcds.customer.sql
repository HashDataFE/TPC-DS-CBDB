CREATE EXTERNAL TABLE ext_tpcds.customer (like :DB_SCHEMA_NAME.customer)
LOCATION (:LOCATION)
FORMAT 'TEXT' (DELIMITER '|' NULL AS '' ESCAPE AS E'\\') ENCODING 'LATIN1';
