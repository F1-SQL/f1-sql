ALTER TABLE [dbo].[meetings] ADD season_key INT 

GO

UPDATE m

SET m.season_key = s.[season_key]

FROM [dbo].[meetings] m INNER JOIN [dbo].[seasons] s ON m.year = s.[year]