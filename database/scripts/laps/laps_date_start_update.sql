ALTER TABLE [dbo].[laps] ADD [Date] DATE;
ALTER TABLE [dbo].[laps] ADD [Time] Time;

GO

UPDATE [dbo].[laps] SET Date = CAST([date_start] as DATE);
UPDATE [dbo].[laps] SET Time = CAST([date_start] as TIME);

GO

ALTER TABLE [dbo].[laps] ALTER COLUMN date_start DATETIME2(6) NULL;

GO

UPDATE [dbo].[laps] SET date_start = NULL;

GO

UPDATE  [dbo].[laps] SET date_start = CONVERT(DATETIME2(6), CONVERT(CHAR(10), [Date], 121) + ' ' + CONVERT(CHAR(12), [Time], 121));

GO

ALTER TABLE [dbo].[laps] DROP COLUMN [Date];
ALTER TABLE [dbo].[laps] DROP COLUMN [Time];