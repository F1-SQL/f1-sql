SELECT 
	[resultId], 
	races.name,
	seasons.year as [season], 
	driver.forename,
	driver.surname,
	driver.code,
	constructors.name as [constructor], 
	results.[number], 
	[grid], 
	[position], 
	[positionText], 
	[positionOrder], 
	[points], 
	[laps], 
	results.[time], 
	[milliseconds], 
	[fastestLap], 
	[rank], 
	[fastestLapTime], 
	[fastestLapSpeed], 
	status.status

FROM 
	[dbo].[results] results

	INNER JOIN [dbo].[races] races ON results.raceId = races.raceId

	INNER JOIN [dbo].[drivers] driver ON results.driverId = driver.driverId

	INNER JOIN [dbo].[constructors] constructors ON results.constructorId = constructors.constructorId

	INNER JOIN [dbo].[status] [status] ON results.statusId = status.statusId

	INNER JOIN [dbo].[seasons] seasons ON races.year = seasons.year

ORDER BY 
	seasons.year DESC,
	races.date,
	[positionOrder] ASC