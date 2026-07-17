ALTER TABLE [dbo].[meetings] ADD [Date_new] DATE
ALTER TABLE [dbo].[meetings] ADD [Time] Time

GO

ALTER TABLE [dbo].[meetings] ALTER COLUMN [date_start] nvarchar(50) NULL

GO

UPDATE [dbo].[meetings] SET [Date_new] = CAST([date_start] as DATE)
UPDATE [dbo].[meetings] SET [Time] = CAST([date_start] as TIME)

GO

UPDATE [dbo].[meetings] SET [date_start] = NULL

GO

ALTER TABLE [dbo].[meetings] ALTER COLUMN [date_start] DATETIME2(6)

GO

UPDATE [dbo].[meetings] 
SET [date_start] = CONVERT(DATETIME2(6), CONVERT(CHAR(10), [Date_new], 121) + ' ' + CONVERT(CHAR(12), [Time], 121))

GO

ALTER TABLE [dbo].[meetings] DROP COLUMN [Date_new]
ALTER TABLE [dbo].[meetings] DROP COLUMN [Time]

GO

ALTER TABLE [dbo].[meetings] ALTER COLUMN [date_start] DATETIME2(6) NOT NULL;