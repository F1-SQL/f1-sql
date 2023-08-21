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

UPDATE cs

SET 
	cs.positionTextID = pt.positionTextID

FROM 
	[dbo].[constructorStandings] cs

INNER JOIN [dbo].[positionText] pt 
	ON cs.positionText = pt.positionCode

GO


UPDATE [dbo].[results]
SET 
	fastestLapSpeed_Decimal = TRY_CONVERT(decimal(18,3),fastestLapSpeed) 
FROM 
	[dbo].[results]


UPDATE [dbo].[pitStops] 
	SET
		duration_converted = TRY_CONVERT(decimal(18,3),duration)

UPDATE [dbo].[qualifying]
SET
	q1_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(q1, ':', '')), 10), 5, 0, ':'), 3, 0, ':')),
	q2_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(q2, ':', '')), 10), 5, 0, ':'), 3, 0, ':')),
	q3_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(q3, ':', '')), 10), 5, 0, ':'), 3, 0, ':'))


GO

ALTER TABLE [dbo].[constructors] DROP COLUMN [nationality]; 
ALTER TABLE [dbo].[circuits] DROP COLUMN [location]; 
ALTER TABLE [dbo].[circuits] DROP COLUMN [country]; 
ALTER TABLE [dbo].[results] DROP COLUMN [positionText];
ALTER TABLE [dbo].[drivers] DROP COLUMN [nationality]; 
ALTER TABLE [dbo].[sprintResults] DROP COLUMN [positionText];
ALTER TABLE [dbo].[positionText] DROP COLUMN [positionCode];
ALTER TABLE [dbo].[constructorResults] DROP COLUMN [status];
ALTER TABLE [dbo].[constructorStandings] DROP COLUMN [positionText];
ALTER TABLE [dbo].[constructorStandings] DROP COLUMN [positionText];
ALTER TABLE [dbo].[driverStandings] DROP COLUMN [positionText];

ALTER TABLE [dbo].[results] DROP COLUMN [fastestLapSpeed];

EXEC sp_rename 'dbo.results.fastestLapSpeed_Decimal', 'fastestLapSpeed', 'COLUMN';


ALTER TABLE [dbo].[pitStops] DROP COLUMN [duration];

EXEC sp_rename 'dbo.pitStops.duration_converted', 'duration', 'COLUMN';

ALTER TABLE [dbo].[results] DROP COLUMN q1;
ALTER TABLE [dbo].[results] DROP COLUMN q2;
ALTER TABLE [dbo].[results] DROP COLUMN q3;

EXEC sp_rename 'dbo.qualifying.q1_converted', 'q1', 'COLUMN';
EXEC sp_rename 'dbo.qualifying.q2_converted', 'q2', 'COLUMN';
EXEC sp_rename 'dbo.qualifying.q3_converted', 'q3', 'COLUMN';

