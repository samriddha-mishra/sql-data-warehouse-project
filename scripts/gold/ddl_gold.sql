CREATE VIEW Gold.dim_customers AS
SELECT
ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
la.cntry AS country,
ci.cst_material_status AS marital_status,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
	 ELSE COALESCE(ca.gen, 'n/a')
END AS gender,
ca.bdate AS birthday,
ci.cst_created_date AS create_date
FROM Silver.crm_cust_info ci
LEFT JOIN Silver.CUST_AZ12 ca 
ON ci.cst_key = ca.cid
LEFT JOIN Silver.LOC_A101 la
ON ci.cst_key = REPLACE(la.cid, ' ', '');



CREATE VIEW Gold.dim_products AS
SELECT 
ROW_NUMBER() OVER(ORDER BY pn.prd_end_dt, pn.prd_key) AS product_key,
pn.prd_id AS product_id,
pn.prd_key AS product_number,
pn.prd_nm AS product_name,
REPLACE(pn.cst_id, '-', '_') AS category_id,
pc.cat AS category,
pc.subcat AS subcategory,
pc.maintenance,
pn.prd_cost AS cost,
pn.prd_line AS product_line,
pn.prd_start_dt AS start_date
FROM Silver.prd_info pn
LEFT JOIN Silver.PX_CAT_G1V2 pc
ON REPLACE(pn.cst_id, '-', '_') = pc.id
WHERE pn.prd_end_dt is NULL;


CREATE VIEW Gold.fact_sales AS
SELECT
sd.sls_ord_num AS order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shipping_date,
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales_amount, 
sd.sls_quantity AS quantity,
sd.sls_price
FROM Silver.sales_details sd
LEFT JOIN Gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN Gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id;
