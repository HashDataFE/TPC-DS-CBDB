CREATE TABLE tpcds.inventory (
    inv_date_sk integer NOT NULL,
    inv_item_sk integer NOT NULL,
    inv_warehouse_sk integer NOT NULL,
    inv_quantity_on_hand integer
)
:ACCESS_METHOD
:STORAGE_OPTIONS
:DISTRIBUTED_BY;
