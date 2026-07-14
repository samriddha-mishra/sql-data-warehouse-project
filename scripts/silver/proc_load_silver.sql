CREATE OR ALTER PROCEDURE Silver.load_silver AS
BEGIN
    BEGIN TRY
        TRUNCATE TABLE Silver.crm_cust_info;
        INSERT INTO Silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_material_status,
            cst_gndr,
            cst_created_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS trimmed_name,
            TRIM(cst_lastname) AS trimmed_lastname,
            CASE 
                WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END cst_material_status,
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                ELSE 'n/a'
            END cst_gndr,
            cst_created_date
        FROM (
            SELECT 
                *,
                ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_created_date DESC) AS flag_last
            FROM Bronze.crm_cust_info
        ) t 
        WHERE flag_last = 1;

        TRUNCATE TABLE Silver.prd_info;
        INSERT INTO Silver.prd_info (
            prd_id,
            prd_key,
            cst_id,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            SUBSTRING(prd_key, 1, 5) AS cst_id,
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE 
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,
            CAST(prd_start_dt AS DATE) AS prd_start_dt,
            CAST(DATEADD(day, -1, LEAD(prd_end_dt) OVER (PARTITION BY SUBSTRING(prd_key, 7, LEN(prd_key)) ORDER BY prd_start_dt)) AS DATE) AS prd_end_dt
        FROM Bronze.prd_info;

        TRUNCATE TABLE Silver.sales_details;
        INSERT INTO Silver.sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE 
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END AS sls_order_dt,
            CASE 
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END AS sls_ship_dt,
            CASE 
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END AS sls_due_dt,
            CASE 
                WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,
            sls_quantity,
            CASE 
                WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price
        FROM Bronze.sales_details;

        TRUNCATE TABLE Silver.CUST_AZ12;
        INSERT INTO Silver.CUST_AZ12 (
            CID,
            BDATE,
            GEN
        )
        SELECT
            CASE 
                WHEN CID LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(CID))
                ELSE CID
            END CID,
            CASE 
                WHEN BDATE > GETDATE() THEN NULL
                ELSE BDATE
            END AS BDATE,
            CASE 
                WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'n/a'
            END AS GEN
        FROM Bronze.CUST_AZ12;

        TRUNCATE TABLE Silver.LOC_A101;
        INSERT INTO Silver.LOC_A101 (
            CID,
            cntry
        )
        SELECT 
            REPLACE(CID, '-', ' ') AS CID,
            CASE 
                WHEN UPPER(cntry) LIKE '%DE%' THEN 'Germany' 
                WHEN UPPER(cntry) LIKE '%US%' THEN 'United States'
                WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
                ELSE TRIM(cntry)
            END AS cntry
        FROM Bronze.LOC_A101;

        TRUNCATE TABLE Silver.PX_CAT_G1V2;
        INSERT INTO Silver.PX_CAT_G1V2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM Bronze.PX_CAT_G1V2;
    END TRY
    BEGIN CATCH
        PRINT '===============================';
        PRINT 'ERROR OCCURRED WHILE LOADING SILVER TABLES';
        PRINT '===============================';
    END CATCH
END;

