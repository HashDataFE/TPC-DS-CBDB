CREATE TABLE :DB_SCHEMA_NAME.catalog_sales (
    cs_sold_date_sk integer,
    cs_sold_time_sk integer,
    cs_ship_date_sk integer,
    cs_bill_customer_sk integer,
    cs_bill_cdemo_sk integer,
    cs_bill_hdemo_sk integer,
    cs_bill_addr_sk integer,
    cs_ship_customer_sk integer,
    cs_ship_cdemo_sk integer,
    cs_ship_hdemo_sk integer,
    cs_ship_addr_sk integer,
    cs_call_center_sk integer,
    cs_catalog_page_sk integer,
    cs_ship_mode_sk integer,
    cs_warehouse_sk integer,
    cs_item_sk integer NOT NULL,
    cs_promo_sk integer,
    cs_order_number bigint NOT NULL,
    cs_quantity integer,
    cs_wholesale_cost numeric(7,2),
    cs_list_price numeric(7,2),
    cs_sales_price numeric(7,2),
    cs_ext_discount_amt numeric(7,2),
    cs_ext_sales_price numeric(7,2),
    cs_ext_wholesale_cost numeric(7,2),
    cs_ext_list_price numeric(7,2),
    cs_ext_tax numeric(7,2),
    cs_coupon_amt numeric(7,2),
    cs_ext_ship_cost numeric(7,2),
    cs_net_paid numeric(7,2),
    cs_net_paid_inc_tax numeric(7,2),
    cs_net_paid_inc_ship numeric(7,2),
    cs_net_paid_inc_ship_tax numeric(7,2),
    cs_net_profit numeric(7,2)
)
:ACCESS_METHOD
:STORAGE_OPTIONS
:DISTRIBUTED_BY;
