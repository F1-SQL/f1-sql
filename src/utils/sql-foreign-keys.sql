SET NOCOUNT, XACT_ABORT ON
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE @temp_lines TABLE (

   [id] INT IDENTITY (1, 1) PRIMARY KEY,
   [line] NVARCHAR(4000)
)

DECLARE @temp_all_tables TABLE (
   [id] INT IDENTITY (1, 1) PRIMARY KEY,
   [TABLE_SCHEMA] SYSNAME NOT NULL,
   [TABLE_NAME] SYSNAME NOT NULL
)
--temp table for just foreign keys
DECLARE @temp_foreign_keys TABLE (
	[id] INT IDENTITY (1, 1) PRIMARY KEY,
	[schemaName] SYSNAME NOT NULL,
	[tableName] SYSNAME NOT NULL,
	[columnName] SYSNAME NOT NULL,
	[Parent_Schema] SYSNAME NOT NULL,
	[Parent_table] SYSNAME NOT NULL,
	[Parent_column] SYSNAME NOT NULL,
	[constraint_name] SYSNAME NOT NULL
)

INSERT INTO @temp_foreign_keys
SELECT 
	KP.TABLE_SCHEMA 'schemaName'
	,KP.TABLE_NAME 'tableName'
	,KP.COLUMN_NAME 'columnName'
	,KF.TABLE_SCHEMA 'Parent_Schema'
	,KF.TABLE_NAME 'Parent_table'
	,KF.COLUMN_NAME 'Parent_column'
	,RC.CONSTRAINT_NAME 'constraint_name'

FROM 
	INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC

	LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KF 
		ON RC.CONSTRAINT_NAME = KF.CONSTRAINT_NAME

	LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KP 
		ON RC.UNIQUE_CONSTRAINT_NAME = KP.CONSTRAINT_NAME

INSERT INTO @temp_all_tables
SELECT  
	[TABLE_SCHEMA], 
	[TABLE_NAME]
FROM    
	INFORMATION_SCHEMA.TABLES INNER JOIN @temp_foreign_keys tfk 
		ON TABLES.TABLE_NAME = tfk.tableName
WHERE   
	TABLE_TYPE = 'BASE TABLE'
ORDER BY 
	1, 
	2

DECLARE @current_loop_table_index INT = (SELECT MIN([id]) FROM @temp_all_tables)

WHILE @current_loop_table_index IS NOT NULL 

BEGIN

   DECLARE @current_loop_table_schema SYSNAME = (SELECT MIN(TABLE_SCHEMA) FROM @temp_all_tables WHERE [id] = @current_loop_table_index)
   DECLARE @current_loop_table_name SYSNAME = (SELECT MIN(TABLE_NAME) FROM @temp_all_tables WHERE [id] = @current_loop_table_index)

   INSERT INTO @temp_lines ([line])
   SELECT  N'### [' + @current_loop_table_schema + N'.' + @current_loop_table_name + N']'

   --INSERT INTO @temp_lines ([line])
   --SELECT  
   --        LTRIM(RTRIM(CONVERT(NVARCHAR(2000), [value]))) +
   --        CASE
   --            WHEN RIGHT(LTRIM(RTRIM(CONVERT(NVARCHAR(2000), [value]))), 1) != N'.' THEN N'.'
   --            ELSE N''
   --        END
   --FROM    sys.extended_properties
   --WHERE   
   --        [name] = N'MS_Description' AND   
   --        [minor_id] = 0 AND
   --        [major_id] = OBJECT_ID(QUOTENAME(@current_loop_table_schema) + N'.' + QUOTENAME(@current_loop_table_name))

   --output markdown table header for columns
   INSERT INTO @temp_lines ([line])
   SELECT  N'|  Schema | table | column | constraint_name |'
   UNION ALL
   SELECT  N'|  ------- | ------- | ------- | ------- |'

   INSERT INTO @temp_lines ([line])
   SELECT          
		   N' | ' + tfk.Parent_Schema
           +
           N' | ' + tfk.Parent_table
           +
           N' | ' + tfk.Parent_column
           +
		    N' | ' + tfk.constraint_name
		   +
		   N' | ' 
	FROM
		INFORMATION_SCHEMA.COLUMNS  

		INNER JOIN @temp_foreign_keys tfk
			ON 
				tfk.tableName = COLUMNS.TABLE_NAME AND tfk.columnName = COLUMNS.COLUMN_NAME
               
		INNER JOIN sys.columns C 
			ON 
				C.[object_id] = OBJECT_ID(QUOTENAME(@current_loop_table_schema) + N'.' + QUOTENAME(@current_loop_table_name)) 
				AND C.[name] = COLUMNS.[COLUMN_NAME]
	WHERE   
		COLUMNS.[TABLE_SCHEMA] = @current_loop_table_schema 
		AND COLUMNS.[TABLE_NAME] = @current_loop_table_name

	ORDER BY
		COLUMNS.[ORDINAL_POSITION]

	SET @current_loop_table_index = (SELECT MIN([id]) FROM @temp_all_tables WHERE [id] > @current_loop_table_index)
END


SET NOCOUNT OFF

SELECT  
	[line]
FROM
	@temp_lines