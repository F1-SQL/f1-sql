SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_Circuits_Fact]

AS

SELECT
	CircuitID,
	Circuit,
	GrandsPrix,
	ct.CircuitType,
	cd.Direction,
	LastLengthUsed,
	GrandsPrixHeld
FROM [dbo].[Circuits] c

LEFT OUTER JOIN [Ref].[CircuitDirections] cd
	ON c.DirectionRefID = cd.DirectionRefID

LEFT OUTER JOIN [Ref].[CircuitType] ct
	ON c.TypeRefID = ct.TypeRefID
	
GO


