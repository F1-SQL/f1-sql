INSERT INTO [dbo].[circuitMap] 
(
	[circuitId],
	[latitude],
	[longitudes]
)
SELECT 
	[circuitId],
	[lat],
	[lng] 
FROM 
	[dbo].[circuits]

GO

UPDATE [dbo].[circuitMap] 
	SET url = 'https://www.openstreetmap.org/#map=15/'+CAST([latitude] AS varchar)+'/'+CAST([longitudes] AS varchar)