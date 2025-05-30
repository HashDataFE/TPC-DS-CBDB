CREATE TABLE :DB_SCHEMA_NAME.web_site (
    web_site_sk integer NOT NULL,
    web_site_id character varying(16) NOT NULL,
    web_rec_start_date date,
    web_rec_end_date date,
    web_name character varying(50),
    web_open_date_sk integer,
    web_close_date_sk integer,
    web_class character varying(50),
    web_manager character varying(40),
    web_mkt_id integer,
    web_mkt_class character varying(50),
    web_mkt_desc character varying(100),
    web_market_manager character varying(40),
    web_company_id integer,
    web_company_name character varying(50),
    web_street_number character varying(10),
    web_street_name character varying(60),
    web_street_type character varying(15),
    web_suite_number character varying(10),
    web_city character varying(60),
    web_county character varying(30),
    web_state character varying(2),
    web_zip character varying(10),
    web_country character varying(20),
    web_gmt_offset numeric(5,2),
    web_tax_percentage numeric(5,2)
)
:ACCESS_METHOD
:STORAGE_OPTIONS
:DISTRIBUTED_BY;
