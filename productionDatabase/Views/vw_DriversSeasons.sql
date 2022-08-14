SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_DriversSeasons]

AS

SELECT 

	ds.SeasonRefID,
	d.DriverID,
	d.DriverName

FROM 
	[dbo].[DriversSeasons] ds

	LEFT OUTER JOIN dbo.Drivers d
		ON d.driverID = ds.driverid
GO


