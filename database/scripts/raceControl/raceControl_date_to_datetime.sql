ALTER TABLE [dbo].[raceControl] ADD [Date2] DATE
ALTER TABLE [dbo].[raceControl] ADD [Time] Time

GO

UPDATE [dbo].[raceControl] SET [Date2] = CAST([date] as DATE)
UPDATE [dbo].[raceControl] SET Time = CAST([date] as TIME)

GO

UPDATE [dbo].[raceControl] SET [date] = NULL

GO

ALTER TABLE [dbo].[raceControl] ALTER COLUMN date DATETIME2(6) 

GO

UPDATE  [dbo].[raceControl] SET date = CONVERT(DATETIME2(6), CONVERT(CHAR(10), [Date2], 121) + ' ' + CONVERT(CHAR(12), [Time], 121))

GO

ALTER TABLE [dbo].[raceControl] DROP COLUMN [Date2]
ALTER TABLE [dbo].[raceControl] DROP COLUMN [Time]

GO

ALTER TABLE [dbo].[raceControl] ALTER COLUMN date DATETIME2(6) NOT NULL
