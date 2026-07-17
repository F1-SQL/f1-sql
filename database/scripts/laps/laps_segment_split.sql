DECLARE @Delimiter NVARCHAR(10) = ', '

DECLARE @TempTable TABLE ([lap_number] INT, [meeting_key] INT, [driver_key] INT, [session_key] INT, Item NVARCHAR(MAX))

INSERT INTO @TempTable ([lap_number],[meeting_key],[driver_key],[session_key], Item)
SELECT 
[lap_number],[meeting_key],[driver_key],[session_key], Item
FROM [dbo].[laps] 
CROSS APPLY dbo.SplitString(SUBSTRING([segments_sector_1], 2, LEN([segments_sector_1]) - 2), @Delimiter)
