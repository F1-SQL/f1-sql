INSERT INTO [dbo].[resultDriverConstructor] (resultID,driverID,constructorID)
SELECT 
	[resultID],
	[driverID],
	[constructorID]
FROM	
	[dbo].[results]