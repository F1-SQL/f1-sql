UPDATE d 

SET d.nationalityID = n.nationalityID 

FROM [dbo].[drivers] d

INNER JOIN [dbo].[nationalities] n ON d.nationality = n.nationality

GO

UPDATE c 

 SET c.nationalityID = n.nationalityID 

FROM [dbo].[constructors] c

INNER JOIN dbo.nationalities n ON c.nationality = n.nationality

GO

UPDATE r 

 SET r.positionTextID = pt.positionTextID 

FROM [dbo].[results] r

INNER JOIN [dbo].[positionText] pt ON r.[positionText] = pt.[positioncode]

GO

UPDATE sr 

 SET sr.positionTextID = pt.positionTextID 

FROM [dbo].[sprintResults] sr

INNER JOIN dbo.positionText pt ON sr.positionText = pt.positionText

GO

UPDATE cir

 SET cir.countryID = c.countryID 

FROM [dbo].[circuits] cir

INNER JOIN [dbo].[countries] c ON cir.[country] = c.[country]

GO

UPDATE cir

 SET cir.locationID = l.locationID 

FROM [dbo].[circuits] cir

INNER JOIN [dbo].[locations] l ON cir.[location] = l.[locationName]
 
GO

UPDATE c SET 

c.circuitDirectionID = tc.circuitDirectionID,
c.circuitTypeID = tc.circuitTypeID

FROM 
	[dbo].[tempCircuits] tc

INNER JOIN [dbo].[circuits] c ON c.name = tc.circuit

GO

DROP TABLE [dbo].[tempCircuits]

GO

UPDATE cr

SET 
	cr.positionTextID = pt.positionTextID

FROM 
	[dbo].[constructorResults] cr

INNER JOIN [dbo].[positionText] pt 
	ON cr.status = pt.positionCode

GO

ALTER TABLE [dbo].[constructors] DROP COLUMN [nationality]; 
ALTER TABLE [dbo].[circuits] DROP COLUMN [location]; 
ALTER TABLE [dbo].[circuits] DROP COLUMN [country]; 
ALTER TABLE [dbo].[results] DROP COLUMN [positionText];
ALTER TABLE [dbo].[drivers] DROP COLUMN [nationality]; 
ALTER TABLE [dbo].[sprintResults] DROP COLUMN [positionText];
ALTER TABLE [dbo].[positionText] DROP COLUMN [positionCode];
ALTER TABLE [dbo].[constructorResults] DROP COLUMN [status];