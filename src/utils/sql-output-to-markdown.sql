USE [SequelFormula]
GO
/****** Object:  StoredProcedure [dbo].[Select2MD]    Script Date: 02/09/2023 08:34:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Select statement
ALTER PROCEDURE [dbo].[Select2MD]
/*
Author: Tomaz Kastrun
Source: https://www.sqlservercentral.com/articles/creating-markdown-formatted-text-for-results-from-sql-server-tables
Date: 08.Nov.2021
Description: Turns result set of selected table into Markdown
Usage:
        EXEC dbo.select2MD
                @table_name = 'TestForMD'
               ,@schema_name = 'dbo'
ToDO:
*/    @table_name VARCHAR(200)
    ,@schema_name VARCHAR(20)
AS 
BEGIN
        SET NOCOUNT ON;
    -- get the columns of the table
        SELECT 
            c.Column_name
            ,c.Ordinal_position
            ,c.is_nullable
            ,c.Data_Type
        
        INTO  #temp
        
        FROM INFORMATION_SCHEMA.TABLES AS  t
        JOIN INFORMATION_SCHEMA.COLUMNS AS c 
        ON t.table_name = c.table_name
        AND t.table_schema = c.table_schema
        AND t.table_Catalog = c.table_Catalog
        WHERE
        t.table_type = 'BASE TABLE'
        AND t.Table_name = @table_name
        AND t.table_schema = @schema_name

        DECLARE @MD NVARCHAR(MAX)
        -- header |name |name2 |name3 |name4 |name5 |name6 
        DECLARE @header VARCHAR(MAX)
        SELECT @header = COALESCE(@header + '**|**', '') + column_name 
        FROM #temp
        ORDER BY Ordinal_position ASC
        SELECT @header = '|**' + @header + '**|'

        -- delimiter |-- |-- |-- |-- |-- |-- 
        DECLARE @nof_columns INT = (SELECT MAX(Ordinal_position) FROM #temp)
        DECLARE @firstLine NVARCHAR(MAX) = (SELECT  REPLICATE('|---',@nof_columns) + '|')  

        SET @MD = CHAR(10) + @header + CHAR(13) + CHAR(10) + @firstLine  + CHAR(10)

        -- body
        DECLARE @body NVARCHAR(MAX)
        SET @body = 'SELECT TOP 2
        ''|'' + CAST(' 
        DECLARE @i INT = 1
        WHILE @i <= @nof_columns
        BEGIN
            DECLARE @w VARCHAR(1000) =  (SELECT column_name FROM #temp WHERE Ordinal_position = @i)
                SET @body = @body + 'ISNULL (' + @w + ','''')' + ' AS VARCHAR(MAX))+ ''|'' + CAST('
            SET @i = @i + 1
        END
        SET @body  = (SELECT SUBSTRING(@body,1, LEN(@body)-8))
        SET @body = @body + ' FROM ' + @table_name

        DECLARE @bodyTable TABLE(MD VARCHAR(MAX))
        INSERT INTO @BodyTable
        EXEC sp_executesql @body

        DECLARE @body2 NVARCHAR(MAX)
        SELECT @body2 = COALESCE(@body2 + ' ', ' ') + ISNULL(MD,' ') + CHAR(10)
        FROM @bodyTable

        SET @MD = @MD + @body2
            
		SELECT @MD
END;
