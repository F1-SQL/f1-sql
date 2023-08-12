--database documentation queries for current database, outputs markdown format
--outputs:
-- * for each database table, a table with column name, type, description
-- * for each view, the first 3,000 characters of the view definition
-- * for functions and stored procedures, the name and the description
--tested with SQL Server 2019
--run this query with "Results to Text"
--can be copy/pasted to app that supports markdown e.g. static site/blog, GitHub, Confluence etc.
--adapted from https://gist.github.com/mwinckler/2577364, https://www.red-gate.com/hub/product-learning/flyway/managing-database-documentation-during-flyway-based-development, https://gist.github.com/aplocher/fa86d16d3dd94ab4e42cc22b6b2fafa0

SET NOCOUNT, XACT_ABORT ON
SET CONCAT_NULL_YIELDS_NULL OFF

--temp table for lines to output, returned at end of process
DECLARE @temp_lines TABLE (
   --internal identifier used for ordering
   [id] INT IDENTITY (1, 1) PRIMARY KEY,
   --line of SQL code
   [line] NVARCHAR(4000)
)
--temp table for list of tables from INFORMATION_SCHEMA.TABLES
DECLARE @temp_all_tables TABLE (
   [id] INT IDENTITY (1, 1) PRIMARY KEY,
   [TABLE_SCHEMA] SYSNAME NOT NULL,
   [TABLE_NAME] SYSNAME NOT NULL
)
--temp table for just primary keys
DECLARE @temp_primary_keys TABLE (
   [TABLE_SCHEMA] SYSNAME NOT NULL,
   [TABLE_NAME] SYSNAME NOT NULL,
   [COLUMN_NAME] SYSNAME NOT NULL
)
--temp table for just foreign keys
DECLARE @temp_foreign_keys TABLE (
	[TABLE_SCHEMA] SYSNAME NOT NULL,
	[FKTableName] SYSNAME NOT NULL,
	[NameOfForeignKey] SYSNAME NOT NULL,
	[FKColumn] SYSNAME NOT NULL,
	[ReferencedTable] SYSNAME NOT NULL,
	[ReferencedColumn] SYSNAME NOT NULL
)
--temp table for just default constraints
DECLARE @temp_constraints_keys TABLE (
	[TABLE_SCHEMA] SYSNAME NOT NULL,
	[TABLE_NAME] SYSNAME NOT NULL,
	[COLUMN_NAME] SYSNAME NOT NULL,
	[ValueOfConstraint] SYSNAME NOT NULL
)

--get tables into temp table (will not include system tables)
INSERT INTO @temp_all_tables
SELECT  [TABLE_SCHEMA], [TABLE_NAME]
FROM    INFORMATION_SCHEMA.TABLES
WHERE   TABLE_TYPE = 'BASE TABLE'
ORDER BY 1, 2

--get just primary keys into temp table for easier retrieval & comparison later
--need table schema, table name, primary key column(s)
INSERT INTO @temp_primary_keys
SELECT  [TABLE_SCHEMA] = CONVERT(SYSNAME, SCHEMA_NAME(o.[schema_id])),
       [TABLE_NAME] = o.[name],
       --column name
       [COLUMN_NAME] = c.[name]
FROM    sys.objects o INNER JOIN
           --only objects with indexes
           sys.indexes i ON
               o.object_id = i.object_id INNER JOIN
           sys.index_columns ic ON
               i.object_id = ic.object_id AND
               i.index_id = ic.index_id INNER JOIN
           sys.columns c ON
               ic.object_id = c.object_id AND
               ic.column_id = c.column_id
WHERE   --user (not system) tables only
       o.[type] = 'U' AND
       --ignore system tables
       o.[is_ms_shipped] = 0 AND
       --ignore heaps
       i.[index_id] > 0 AND
       --ignore indexes that "...cannot be used directly as a data access path. Hypothetical indexes hold column-level statistics..."
       i.[is_hypothetical] = 0 AND
       --primary keys only
       i.[is_primary_key] = 1

--gets foreign keys
INSERT INTO @temp_foreign_keys
SELECT
	s.name,
	t.name,
	fk.name,
	pc.name,
	rt.name,
	c.name
FROM sys.foreign_key_columns AS fkc
INNER JOIN sys.foreign_keys AS fk 
	ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.tables AS t 
	ON fkc.parent_object_id = t.object_id
INNER JOIN sys.schemas AS s 
	ON s.schema_id = t.schema_id
INNER JOIN sys.tables AS rt 
	ON fkc.referenced_object_id = rt.object_id
INNER JOIN sys.columns AS pc 
	ON fkc.parent_object_id = pc.object_id
	AND fkc.parent_column_id = pc.column_id
INNER JOIN sys.columns AS c 
	ON fkc.referenced_object_id = c.object_id
	AND fkc.referenced_column_id = c.column_id

INSERT INTO @temp_constraints_keys
-- returns name of a column's default value constraint 
SELECT
	schemas.name,
	tables.name,
	all_columns.name,
	REPLACE(REPLACE(REPLACE(default_constraints.definition,'(',''),')',''),'''','')
FROM 
    sys.all_columns

        INNER JOIN
    sys.tables
        ON all_columns.object_id = tables.object_id

        INNER JOIN 
    sys.schemas
        ON tables.schema_id = schemas.schema_id

        INNER JOIN
    sys.default_constraints
        ON all_columns.default_object_id = default_constraints.object_id
WHERE 
	LEN(REPLACE(REPLACE(REPLACE(default_constraints.definition,'(',''),')',''),'''','')) > 0 
	AND REPLACE(REPLACE(REPLACE(default_constraints.definition,'(',''),')',''),'''','') <> 'NULL'

--current table loop index (start at 1, unless there's no tables)
DECLARE @current_loop_table_index INT = (SELECT MIN([id]) FROM @temp_all_tables)

--loop through each table
WHILE @current_loop_table_index IS NOT NULL BEGIN
   --current loop schema and table name
   DECLARE @current_loop_table_schema SYSNAME = (SELECT MIN([TABLE_SCHEMA]) FROM @temp_all_tables WHERE [id] = @current_loop_table_index)
   DECLARE @current_loop_table_name SYSNAME = (SELECT MIN([TABLE_NAME]) FROM @temp_all_tables WHERE [id] = @current_loop_table_index)

   --output schema & table name as heading 3, make into an anchor
   INSERT INTO @temp_lines ([line])
   SELECT  N'### [' + @current_loop_table_schema + N'.' + @current_loop_table_name + N']'

   --output extended property for table, allow up to 2,000 characters
   --adapted from https://gist.github.com/mwinckler/2577364
   INSERT INTO @temp_lines ([line])
   SELECT  --if there's no trailing full stop, add one
           LTRIM(RTRIM(CONVERT(NVARCHAR(2000), [value]))) +
           CASE
               WHEN RIGHT(LTRIM(RTRIM(CONVERT(NVARCHAR(2000), [value]))), 1) != N'.' THEN N'.'
               ELSE N''
           END
   FROM    sys.extended_properties
   WHERE   --MS_Description metadata only
           [name] = N'MS_Description' AND
           --should be zero for table and column metadata
           [minor_id] = 0 AND
           --match object ID of current loop table
           [major_id] = OBJECT_ID(QUOTENAME(@current_loop_table_schema) + N'.' + QUOTENAME(@current_loop_table_name))

   --output markdown table header for columns
   INSERT INTO @temp_lines ([line])
   SELECT  N'| Column name | Key | Data type | Allow NULLs | Default | Description |'
   UNION ALL
   SELECT  N'| ------- | ------- | ------- | ------- | ------- | ------- |'

   --output columns from INFORMATION_SCHEMA.COLUMNS
   --as markdown table rows
   --roughly match SSMS designers
   --data types in uppercase, because that's the way I like 'em
   INSERT INTO @temp_lines ([line])
   SELECT  --column name as bold text
           N'| **' + COLUMNS.[COLUMN_NAME] + N'**' +
		   /*Sort out the primary key here */
           N' | ' +  CASE
               WHEN EXISTS (
                     SELECT  1
                     FROM    @temp_primary_keys p
                     WHERE   COLUMNS.[TABLE_SCHEMA] = p.[TABLE_SCHEMA] AND
                             COLUMNS.[TABLE_NAME] = p.[TABLE_NAME] AND
                             COLUMNS.[COLUMN_NAME] = p.[COLUMN_NAME]
                    ) THEN N' Primary Key'
				WHEN EXISTS (
                     SELECT  1
                     FROM    @temp_foreign_keys f
                     WHERE   
							COLUMNS.[TABLE_SCHEMA] = f.[TABLE_SCHEMA] AND
							COLUMNS.[TABLE_NAME] = f.FKTableName AND
                            COLUMNS.[COLUMN_NAME] = f.FKColumn
                    ) THEN (SELECT f.NameOfForeignKey + ' (' + CONCAT(f.TABLE_SCHEMA,'.',f.ReferencedTable, ' ', f.ReferencedColumn) + ')'
                     FROM    @temp_foreign_keys f
                     WHERE   
							COLUMNS.[TABLE_SCHEMA] = f.[TABLE_SCHEMA] AND
							COLUMNS.[TABLE_NAME] = f.FKTableName AND
                            COLUMNS.[COLUMN_NAME] = f.FKColumn)
               ELSE N''
           END +      
           --put together data type
           N' | ' + UPPER(COLUMNS.[DATA_TYPE]) +
           --append precision in brackets, for certain data types only
           CASE
               --add precision for datetime offset
               WHEN UPPER(COLUMNS.[DATA_TYPE]) IN (N'DATETIMEOFFSET') THEN N'(' + CONVERT(NVARCHAR(25), COLUMNS.[DATETIME_PRECISION]) + N')'
               --for numeric columns, add precision
               WHEN UPPER(COLUMNS.[DATA_TYPE]) IN (N'NUMERIC') THEN N'(' + CONVERT(NVARCHAR(25), COLUMNS.[NUMERIC_PRECISION]) + N',' + CONVERT(NVARCHAR(25), COLUMNS.[NUMERIC_SCALE]) + N')'
               --for character columns, add length (replace length of -1 with MAX)
               WHEN UPPER(COLUMNS.[DATA_TYPE]) IN (N'CHAR', N'NCHAR', N'VARCHAR', N'NVARCHAR') THEN
                   REPLACE(N'(' + CONVERT(NVARCHAR(25), COLUMNS.CHARACTER_MAXIMUM_LENGTH) + N')', N'(-1)', N'(MAX)')
               ELSE N''
           END +
           --special case - if an IDENTITY column, append word "identity"
           CASE
               WHEN c.[is_identity] = 1 THEN N' IDENTITY'
               ELSE N''
           END +
           --custom NULL column, ticked check box if is nullable
           N' | ' + CASE
               WHEN COLUMNS.[IS_NULLABLE] = N'YES' THEN N'☑'
               --empty check box if not nullable
               ELSE N'☐'
           END +
		   N' | ' +  CASE
               WHEN EXISTS (
                     SELECT  1
                     FROM    @temp_constraints_keys c
                     WHERE   COLUMNS.[TABLE_SCHEMA] = c.[TABLE_SCHEMA] AND
                             COLUMNS.[TABLE_NAME] = c.[TABLE_NAME] AND
                             COLUMNS.[COLUMN_NAME] = c.[COLUMN_NAME]
                    ) THEN (SELECT c.ValueOfConstraint FROM @temp_constraints_keys c  WHERE   COLUMNS.[TABLE_SCHEMA] = c.[TABLE_SCHEMA] AND
                             COLUMNS.[TABLE_NAME] = c.[TABLE_NAME] AND
                             COLUMNS.[COLUMN_NAME] = c.[COLUMN_NAME])                 
               ELSE N'' END +
				--get description for extended properties
           --if there's no trailing full stop, add one
           N' | ' + LTRIM(RTRIM(CONVERT(NVARCHAR(2000), ep.[value]))) +
           CASE
               WHEN RIGHT(LTRIM(RTRIM(CONVERT(NVARCHAR(2000), ep.[value]))), 1) != N'.' THEN N'.'
               ELSE N''
           END +  N' | '
   FROM    INFORMATION_SCHEMA.COLUMNS LEFT OUTER JOIN
               sys.extended_properties ep ON
                   ep.[name] = N'MS_Description' AND
                   --table is "major_id"
                   ep.[major_id] = OBJECT_ID(QUOTENAME(@current_loop_table_schema) + N'.' + QUOTENAME(@current_loop_table_name)) AND
                   --column number is "minor_id"
                   ep.[minor_id] = COLUMNS.[ORDINAL_POSITION] LEFT OUTER JOIN
               --sys.columns, needed for identity columns
               sys.columns C ON
                   C.[object_id] = OBJECT_ID(QUOTENAME(@current_loop_table_schema) + N'.' + QUOTENAME(@current_loop_table_name)) AND
                   C.[name] = COLUMNS.[COLUMN_NAME]
   WHERE   COLUMNS.[TABLE_SCHEMA] = @current_loop_table_schema AND
           COLUMNS.[TABLE_NAME] = @current_loop_table_name
   ORDER BY
           --order the same as SSMS designers
           COLUMNS.[ORDINAL_POSITION]

   --increment table loop index
   SET @current_loop_table_index = (SELECT MIN([id]) FROM @temp_all_tables WHERE [id] > @current_loop_table_index)
END


SET NOCOUNT OFF

--return output in order of line number, but without line number in output
SELECT  [line]
FROM    @temp_lines