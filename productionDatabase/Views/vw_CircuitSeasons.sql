SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_CircuitSeasons]

AS

SELECT 

	cs.SeasonID,
	c.CircuitID,
	c.Circuit,
	c.GrandsPrix

FROM 
	[dbo].[CircuitSeasons] cs

	LEFT OUTER JOIN dbo.Circuits c
		ON c.CircuitID = cs.CircuitID
GO


