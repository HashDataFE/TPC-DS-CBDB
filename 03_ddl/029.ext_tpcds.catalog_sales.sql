CREATE EXTERNAL TABLE ext_tpcds.catalog_sales (like :DB_SCHEMA_NAME.catalog_sales)
LOCATION (:LOCATION)
FORMAT 'TEXT' (DELIMITER '|' NULL AS '' ESCAPE AS E'\\');
