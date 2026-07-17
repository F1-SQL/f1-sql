/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001 at 04/02/2024 07:18:09
	See https://dbatools.io/Export-DbaScript for more information
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[intervals](
	[driver_key] [int] NOT NULL,
	[gap_to_leader] [decimal](7, 3) NULL,
	[interval] [decimal](7, 3) NULL,
	[meeting_key] [int] NOT NULL,
	[session_key] [int] NOT NULL,
	[laps_to_leader] [int] NULL,
	[lapped_laps] [int] NULL
) ON [PRIMARY]
GO
