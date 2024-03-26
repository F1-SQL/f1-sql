UPDATE
	[dbo].[constructorResults]

	SET positionTextID = 600

WHERE 
	status = 'D'

GO

UPDATE cr

SET 
	cr.positionTextID = pt.positionTextID

FROM 
	[dbo].[constructorResults] cr

INNER JOIN [dbo].[positionText] pt 
	ON cr.[status] = pt.[positionText]