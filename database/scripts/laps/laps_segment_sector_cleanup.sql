UPDATE [dbo].[laps] SET segments_sector_1 = NULL
WHERE segments_sector_1 = '[]';

GO

UPDATE [dbo].[laps] SET segments_sector_2 = NULL
WHERE segments_sector_2 = '[]';

GO

UPDATE [dbo].[laps] SET segments_sector_3 = NULL
WHERE segments_sector_3 = '[]';