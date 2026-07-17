ALTER TABLE [dbo].[position] ADD [Date2] DATE
ALTER TABLE [dbo].[position] ADD [Time] Time

GO

UPDATE [dbo].[position] SET [Date2] = CAST([date] as DATE)
UPDATE [dbo].[position] SET Time = CAST([date] as TIME)

GO

UPDATE [dbo].[position] SET [date] = NULL

GO

ALTER TABLE [dbo].[position] ALTER COLUMN date DATETIME2(6) 

GO

UPDATE  [dbo].[position] SET date = CONVERT(DATETIME2(6), CONVERT(CHAR(10), [Date2], 121) + ' ' + CONVERT(CHAR(12), [Time], 121))

GO

ALTER TABLE [dbo].[position] DROP COLUMN [Date2]
ALTER TABLE [dbo].[position] DROP COLUMN [Time]

GO

ALTER TABLE [dbo].[position] ALTER COLUMN date DATETIME2(6) NOT NULL
