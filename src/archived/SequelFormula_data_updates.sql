INSERT INTO positionText (positionTextID,positionText,positionCode)
VALUES
(1,'1','1'),
(2,'2','2'),
(3,'3','3'),
(4,'4','4'),
(5,'5','5'),
(6,'6','6'),
(7,'7','7'),
(8,'8','8'),
(9,'9','9'),
(10,'10','10'),
(11,'11','11'),
(12,'12','12'),
(13,'13','13'),
(14,'14','14'),
(15,'15','15'),
(16,'16','16'),
(17,'17','17'),
(18,'18','18'),
(19,'19','19'),
(20,'20','20'),
(21,'21','21'),
(22,'22','22'),
(23,'23','23'),
(24,'24','24'),
(25,'25','25'),
(26,'26','26'),
(27,'27','27'),
(28,'28','28'),
(29,'29','29'),
(30,'30','30'),
(31,'31','31'),
(32,'32','32'),
(33,'33','33'),
(600,'Disqualified','D'),
(601,'Excluded','E'),
(602,'Failed To Qualify','F'),
(603,'Not Classified','N'),
(604,'Retired','R'),
(605,'Withdrew','W')

GO

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

GO

UPDATE ds

SET 
	ds.positionTextID = pt.positionTextID

FROM 
	[dbo].[driverStandings] ds

INNER JOIN [dbo].[positionText] pt 
	ON ds.[positionText] = pt.[positionText]

GO

UPDATE cs

SET 
	cs.positionTextID = pt.positionTextID

FROM 
	[dbo].[constructorStandings] cs

INNER JOIN [dbo].[positionText] pt 
	ON cs.[positionText] = pt.[positionText]

GO

;WITH LeadingResults AS
(
	SELECT 

	raceID,
	positionOrder,
	dateadd(ms, milliseconds, '19800101') as LeadTime

	FROM 
		[dbo].[results]	
	WHERE 
		positionOrder = 1
),
DataOutput AS 
(
	SELECT 
		resultID,
		r.raceID,
		r.positionOrder,
		milliseconds,
		time,
		dateadd(ms, r.milliseconds, '19800101') - CASE 
													WHEN r.positionOrder = 1 THEN LAG(dateadd(ms, r.milliseconds, '19800101')) OVER( ORDER BY r.raceID,r.positionOrder) 
													WHEN r.positionOrder != 1 THEN lr.LeadTime 
												END AS Diff
	FROM							
		[dbo].[results]	r
		
		INNER JOIN LeadingResults lr 
			ON r.raceId = lr.raceId
)

UPDATE r
	SET 
		r.TimeDifference = do.Diff
	FROM 
		[dbo].[results] r

		INNER JOIN DataOutput DO 
			ON r.resultId = do.resultId

GO

UPDATE [dbo].[results]
	SET
		fastestLapTime_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(fastestLapTime, ':', '')), 10), 5, 0, ':'), 3, 0, ':')) 

/*sprintResults*/

;WITH LeadingResults AS
(
SELECT 

raceID,
positionOrder,
dateadd(ms, milliseconds, '19800101') as LeadTime

FROM 
	[dbo].[sprintResults]	
WHERE 
	positionOrder = 1
),
DataOutput AS 
(
SELECT 
	resultID,
	r.raceID,
	r.positionOrder,
	milliseconds,
	time,
	dateadd(ms, r.milliseconds, '19800101') - CASE 
												WHEN r.positionOrder = 1 THEN LAG(dateadd(ms, r.milliseconds, '19800101')) OVER( ORDER BY r.raceID,r.positionOrder) 
												WHEN r.positionOrder != 1 THEN lr.LeadTime 
											END AS Diff
FROM							
	[dbo].[sprintResults]	r
	
	INNER JOIN LeadingResults lr 
		ON r.raceId = lr.raceId
)

UPDATE r
	SET 
		r.TimeDifference = do.Diff

	FROM 
		[dbo].[sprintResults] r

		INNER JOIN DataOutput DO ON r.resultId = do.resultId
GO

UPDATE [dbo].[sprintResults]
	SET
		fastestLapTime_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(fastestLapTime, ':', '')), 10), 5, 0, ':'), 3, 0, ':')) 

GO

UPDATE [dbo].[results]
	SET
		fastestLapTime_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(fastestLapTime, ':', '')), 10), 5, 0, ':'), 3, 0, ':')) 

GO

UPDATE [dbo].[results]
	SET 
		fastestLapSpeed_Decimal = TRY_CONVERT(decimal(18,3),fastestLapSpeed) 

GO

UPDATE [dbo].[pitStops] 
	SET
		duration_converted = TRY_CONVERT(decimal(18,3),duration)

UPDATE [dbo].[qualifying]
	SET
		q1_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(q1, ':', '')), 10), 5, 0, ':'), 3, 0, ':')),
		q2_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(q2, ':', '')), 10), 5, 0, ':'), 3, 0, ':')),
		q3_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(q3, ':', '')), 10), 5, 0, ':'), 3, 0, ':'));

GO

UPDATE [dbo].[lapTimes]
	SET
		time_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(time, ':', '')), 10), 5, 0, ':'), 3, 0, ':')); 

GO

UPDATE [dbo].[results] 
	SET 
		time_converted = TRY_CONVERT(time(3),[time]) WHERE position = 1;

GO

UPDATE [dbo].[results] 
	SET 
		time_converted = TRY_CONVERT(time(3),[TimeDifference]) WHERE position != 1;

GO

UPDATE [dbo].[sprintResults] SET time_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(time, ':', '')), 10), 5, 0, ':'), 3, 0, ':'))  WHERE position = 1;

GO

UPDATE [dbo].[sprintResults] SET time_converted = TRY_CONVERT(time(3),[TimeDifference]) WHERE position != 1

GO








GO

INSERT INTO [dbo].[resultsNew]
(
	[raceId],
	[resultTypeId], 
	[driverId], 
	[constructorId], 
	[number], 
	[grid], 
	[position], 
	[positionOrder], 
	[points], 
	[laps], 
	[milliseconds], 
	[fastestLap], 
	[rank], 
	[statusId], 
	[positionTextID], 
	[fastestLapTime], 
	[fastestLapSpeed], 
	[time]
)
SELECT 
	[raceid],
	'1',
	[driverId], 
	[constructorId], 
	[number], 
	[grid], 
	[position], 
	[positionOrder], 
	[points], 
	[laps], 
	[milliseconds], 
	[fastestLap], 
	[rank], 
	[statusId], 
	[positionTextID], 
	[fastestLapTime], 
	[fastestLapSpeed],
	[time]
FROM 
	[dbo].[results]

GO

INSERT INTO [dbo].[resultsNew]
(
	[raceId],
	[resultTypeId], 
	[driverId],
	[constructorId], 
	[number], 
	[grid], 
	[position], 
	[positionOrder], 
	[points], 
	[laps], 
	[milliseconds], 
	[fastestLap],  
	[statusId], 
	[positionTextID], 
	[fastestLapTime],  
	[time]
)
SELECT 
	[raceid],
	'2',
	[driverId], 
	[constructorId], 
	[number], 
	[grid], 
	[position],
	[positionOrder], 
	[points], 
	[laps], 
	[milliseconds], 
	[fastestLap],  
	[statusId], 
	[positionTextID], 
	[fastestLapTime],  
	[time]
FROM 
	[dbo].[sprintResults]

GO

INSERT INTO [dbo].[resultDriverConstructor] (resultID,driverID,constructorID)
SELECT 
	[resultID],
	[driverID],
	[constructorID]
FROM	
	[dbo].[results]

GO

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

GO

ALTER TABLE [dbo].[constructors] DROP COLUMN [nationality]; 

ALTER TABLE [dbo].[circuits] DROP COLUMN [location]; 
ALTER TABLE [dbo].[circuits] DROP COLUMN [country]; 

ALTER TABLE [dbo].[qualifying] DROP COLUMN q1;
ALTER TABLE [dbo].[qualifying] DROP COLUMN q2;
ALTER TABLE [dbo].[qualifying] DROP COLUMN q3;

ALTER TABLE [dbo].[drivers] DROP COLUMN [nationality]; 

ALTER TABLE [dbo].[positionText] DROP COLUMN [positionCode];
ALTER TABLE [dbo].[constructorResults] DROP COLUMN [status];
ALTER TABLE [dbo].[constructorStandings] DROP COLUMN [positionText];
ALTER TABLE [dbo].[driverStandings] DROP COLUMN [positionText];
ALTER TABLE [dbo].[pitStops] DROP COLUMN [duration];
ALTER TABLE [dbo].[lapTimes] DROP COLUMN [time];

ALTER TABLE [dbo].[results] DROP COLUMN [driverId];
ALTER TABLE [dbo].[results] DROP COLUMN [constructorId];

ALTER TABLE [dbo].[circuits] DROP COLUMN lat;
ALTER TABLE [dbo].[circuits] DROP COLUMN lng;

DROP TABLE [dbo].[results];
DROP TABLE [dbo].[Sprintresults];

EXEC sp_rename 'resultsnew', 'results';
EXEC sp_rename 'dbo.pitStops.duration_converted', 'duration', 'COLUMN';
EXEC sp_rename 'dbo.qualifying.q1_converted', 'q1', 'COLUMN';
EXEC sp_rename 'dbo.qualifying.q2_converted', 'q2', 'COLUMN';
EXEC sp_rename 'dbo.qualifying.q3_converted', 'q3', 'COLUMN';
EXEC sp_rename 'dbo.lapTimes.time_converted', 'time', 'COLUMN';