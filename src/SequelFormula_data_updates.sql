ALTER TABLE [dbo].[drivers] ADD nationalityID INT 

GO

UPDATE d 

SET d.nationalityID = n.nationalityID 

FROM [dbo].[drivers] d

INNER JOIN [dbo].[nationalities] n ON d.nationality = n.nationality


GO

ALTER TABLE [dbo].[drivers] DROP COLUMN nationality 

GO

ALTER TABLE [dbo].[constructors] ADD nationalityID INT 

GO

UPDATE c 

 SET c.nationalityID = n.nationalityID 

FROM [dbo].[constructors] c

INNER JOIN dbo.nationalities n ON c.nationality = n.nationality

GO

ALTER TABLE [dbo].[constructors] DROP COLUMN nationality 

GO

ALTER TABLE dbo.Results ADD positionTextID INT;

GO

UPDATE r 

 SET r.positionTextID = pt.positionTextID 

FROM [dbo].[results] r

INNER JOIN [dbo].[positionText] pt ON r.[positionText] = pt.[positioncode]

GO

ALTER TABLE [dbo].[results] DROP COLUMN postitionText 

GO

ALTER TABLE [dbo].[sprintResults] ADD positionTextID INT;

GO

UPDATE sr 

 SET sr.positionTextID = pt.positionTextID 

FROM [dbo].[sprintResults] sr

INNER JOIN dbo.positionText pt ON sr.positionText = pt.positioncode

GO

ALTER TABLE [dbo].[sprintResults] DROP COLUMN postitionText 
GO
ALTER TABLE [dbo].[positionText] DROP COLUMN postitionCode

GO

ALTER TABLE [dbo].[circuits] ADD countryID INT;
ALTER TABLE [dbo].[circuits] ADD circuitDirectionID INT;
ALTER TABLE [dbo].[circuits] ADD circuitTypeID INT;

GO

UPDATE cir

 SET cir.countryID = c.countryID 

FROM [dbo].[circuits] cir

INNER JOIN [dbo].[countries] c ON cir.[country] = c.[country]

GO
ALTER TABLE [dbo].[circuits] DROP CONSTRAINT DF_circuits_country; 
GO
ALTER TABLE [dbo].[circuits] DROP COLUMN country; 

GO

ALTER TABLE [dbo].[circuits] ADD locationID INT;

GO

UPDATE cir

 SET cir.locationID = l.locationID 

FROM [dbo].[circuits] cir

INNER JOIN [dbo].[locations] l ON cir.[location] = l.[locationName]
 
GO
ALTER TABLE [dbo].[circuits] DROP COLUMN location; 

GO

UPDATE c SET 


c.circuitDirectionID = tc.circuitDirectionID,
c.circuitTypeID = tc.circuitTypeID

FROM 
	[RichInF1].[dbo].[tempCircuits] tc

INNER JOIN [dbo].[circuits] c ON c.name = tc.circuit

GO

DROP TABLE [dbo].[tempCircuits]