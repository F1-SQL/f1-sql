/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001 at 04/02/2024 07:18:10
	See https://dbatools.io/Export-DbaScript for more information
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[weather](
	[air_temperature] [decimal](3, 1) NULL,
	[date] [datetime2](6) NULL,
	[humidity] [decimal](3, 1) NULL,
	[meeting_key] [int] NOT NULL,
	[pressure] [decimal](5, 1) NULL,
	[rainfall] [bit] NULL,
	[session_key] [int] NOT NULL,
	[track_temperature] [decimal](3, 1) NULL,
	[wind_direction] [int] NULL,
	[wind_speed] [decimal](3, 1) NULL
) ON [PRIMARY]
GO
