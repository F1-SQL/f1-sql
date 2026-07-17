ALTER TABLE [dbo].[meetings] ADD [location_key] INT; 

GO

UPDATE m

SET m.location_key = l.location_key

FROM [dbo].[meetings] m 

LEFT JOIN [dbo].[locations] l  ON m.location = l.[locationName]