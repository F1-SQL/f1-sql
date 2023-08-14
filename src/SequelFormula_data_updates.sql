ALTER TABLE [dbo].[drivers] ADD nationalityID INT 

GO

UPDATE d 

 SET d.nationalityID = n.nationalityID 

FROM [dbo].[drivers] d

INNER JOIN dbo.nationality n ON d.nationality = n.nationality

GO

ALTER TABLE [dbo].[drivers] DROP COLUMN nationality 

GO

ALTER TABLE [dbo].[constructors] ADD nationalityID INT 

GO

UPDATE c 

 SET c.nationalityID = n.nationalityID 

FROM [dbo].[constructors] c

INNER JOIN dbo.nationality n ON c.nationality = n.nationality

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

GO

UPDATE cir

 SET cir.countryID = c.countryID 

FROM [dbo].[circuits] cir

INNER JOIN [dbo].[countries] c ON cir.[country] = c.[country]

GO

ALTER TABLE [dbo].[circuits] DROP COLUMN countryID; 
GO
ALTER TABLE [dbo].[circuits] DROP COLUMN country; 