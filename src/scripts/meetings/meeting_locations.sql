ALTER TABLE [SequelFormulaNew].[dbo].[meetings] ADD location_key INT 

UPDATE m

SET m.location_key = l.location_key

FROM [SequelFormulaNew].[dbo].[meetings] m 

LEFT JOIN [dbo].[locations] l  ON m.location = l.[locationName]