/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001$SQLEXPRESS14 at 08/15/2023 09:39:54
	See https://dbatools.io/Export-DbaScript for more information
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempCircuits](
	[Circuit] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[circuitTypeID] [tinyint] NOT NULL,
	[circuitDirectionID] [tinyint] NOT NULL,
	[Location] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[Country] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[LastLengthUsed] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[GrandsPrix] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[Season] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[GrandsPrixHeld] [tinyint] NOT NULL
) ON [PRIMARY]
GO
