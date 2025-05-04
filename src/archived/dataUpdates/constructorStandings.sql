UPDATE cs

SET 
	cs.positionTextID = pt.positionTextID

FROM 
	[dbo].[constructorStandings] cs

INNER JOIN [dbo].[positionText] pt 
	ON cs.[positionText] = pt.[positionText]