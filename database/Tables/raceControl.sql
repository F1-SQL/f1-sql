/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001 at 04/02/2024 07:18:10
	See https://dbatools.io/Export-DbaScript for more information
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[raceControl](
	[category] [varchar](10) COLLATE Latin1_General_CI_AS NULL,
	[date] [datetime2](6) NOT NULL,
	[driver_key] [int] NULL,
	[flag] [varchar](20) COLLATE Latin1_General_CI_AS NULL,
	[lap_number] [int] NULL,
	[meeting_key] [int] NULL,
	[message] [varchar](300) COLLATE Latin1_General_CI_AS NULL,
	[scope] [varchar](10) COLLATE Latin1_General_CI_AS NULL,
	[sector] [int] NULL,
	[session_key] [int] NULL
) ON [PRIMARY]
GO
