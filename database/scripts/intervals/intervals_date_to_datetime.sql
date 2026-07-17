ALTER TABLE [dbo].[intervals] ADD [Date_new] DATE
ALTER TABLE [dbo].[intervals] ADD [Time] Time

GO

ALTER TABLE [dbo].[intervals] ALTER COLUMN [Date] nvarchar(50) NULL

GO

UPDATE [dbo].[intervals] SET [Date_new] = CAST([date] as DATE)
UPDATE [dbo].[intervals] SET [Time] = CAST([date] as TIME)

GO

UPDATE [dbo].[intervals] SET [date] = NULL

GO

ALTER TABLE [dbo].[intervals] ALTER COLUMN [date] DATETIME2(6)

GO

UPDATE [dbo].[intervals] 
SET [date] = CONVERT(DATETIME2(6), CONVERT(CHAR(10), [Date_new], 121) + ' ' + CONVERT(CHAR(12), [Time], 121))
