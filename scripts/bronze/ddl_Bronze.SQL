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


