ALTER TABLE [dbo].[weather] ADD [Date_new] DATE
ALTER TABLE [dbo].[weather] ADD [Time] Time

GO

ALTER TABLE [dbo].[weather] ALTER COLUMN date nvarchar(50) NULL

GO

UPDATE [dbo].[weather] SET [Date_new] = CAST([date] as DATE)
UPDATE [dbo].[weather] SET Time = CAST([date] as TIME)

GO

UPDATE [dbo].[weather] SET [date] = NULL

GO

ALTER TABLE [dbo].[weather] ALTER COLUMN [date] DATETIME2(6)

GO

UPDATE  [dbo].[weather] SET [date] = CONVERT(DATETIME2(6), CONVERT(CHAR(10), [Date_new], 121) + ' ' + CONVERT(CHAR(12), [Time], 121))

GO

ALTER TABLE [dbo].[weather] DROP COLUMN [Date_new]
ALTER TABLE [dbo].[weather] DROP COLUMN [Time]