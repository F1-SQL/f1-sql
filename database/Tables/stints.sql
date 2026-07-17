/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001 at 04/02/2024 07:18:10
	See https://dbatools.io/Export-DbaScript for more information
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stints](
	[driver_key] [int] NOT NULL,
	[lap_end] [int] NULL,
	[lap_start] [int] NULL,
	[meeting_key] [int] NOT NULL,
	[session_key] [int] NOT NULL,
	[stint_number] [int] NOT NULL,
	[tyre_age_at_start] [int] NULL,
	[compound_key] [int] NULL
) ON [PRIMARY]
GO
