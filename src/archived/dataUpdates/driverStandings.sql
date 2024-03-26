UPDATE ds

SET 
	ds.positionTextID = pt.positionTextID

FROM 
	[dbo].[driverStandings] ds

INNER JOIN [dbo].[positionText] pt 
	ON ds.[positionText] = pt.[positionText]