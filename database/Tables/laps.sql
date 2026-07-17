/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001 at 04/02/2024 07:18:09
	See https://dbatools.io/Export-DbaScript for more information
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[laps](
	[date_start] [datetime2](6) NULL,
	[driver_key] [int] NOT NULL,
	[duration_sector_1] [decimal](10, 3) NULL,
	[duration_sector_2] [decimal](10, 3) NULL,
	[duration_sector_3] [decimal](10, 3) NULL,
	[first_intermediate_speed] [int] NULL,
	[second_intermediate_speed] [int] NULL,
	[is_pit_out_lap] [bit] NULL,
	[lap_duration] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[lap_number] [int] NULL,
	[meeting_key] [int] NOT NULL,
	[segments_sector_1] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[segments_sector_2] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[segments_sector_3] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[session_key] [int] NOT NULL,
	[st_speed] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
