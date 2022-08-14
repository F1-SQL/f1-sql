SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_ConstructorsSeasons]

AS

SELECT 

	cs.SeasonID,
	c.ConstructorID,
	c.Constructor

FROM 
	[dbo].[ConstructorsSeasons] cs

	LEFT OUTER JOIN dbo.Constructors c
		ON c.ConstructorID = cs.ConstructorID
GO


