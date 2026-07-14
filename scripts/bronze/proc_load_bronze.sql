CREATE OR ALTER PROCEDURE Bronze.load_bronze AS
BEGIN
    BEGIN TRY
        TRUNCATE TABLE Bronze.crm_cust_info;
        BULK INSERT Bronze.crm_cust_info
        FROM '/var/opt/mssql/data/cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        TRUNCATE TABLE Bronze.CUST_AZ12;
        BULK INSERT Bronze.CUST_AZ12
        FROM '/var/opt/mssql/data/cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        TRUNCATE TABLE Bronze.LOC_A101;
        BULK INSERT Bronze.LOC_A101
        FROM '/var/opt/mssql/data/loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        TRUNCATE TABLE Bronze.prd_info;
        BULK INSERT Bronze.prd_info
        FROM '/var/opt/mssql/data/prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        TRUNCATE TABLE Bronze.PX_CAT_G1V2;
        BULK INSERT Bronze.PX_CAT_G1V2
        FROM '/var/opt/mssql/data/px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        TRUNCATE TABLE Bronze.sales_details;
        BULK INSERT Bronze.sales_details
        FROM '/var/opt/mssql/data/sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
    END TRY
    BEGIN CATCH
        PRINT '===============================';
        PRINT 'ERROR OCCURRED WHILE LOADING BRONZE TABLES';
        PRINT '===============================';
    END CATCH
END;
