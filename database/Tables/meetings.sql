/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001 at 04/02/2024 07:18:09
	See https://dbatools.io/Export-DbaScript for more information
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[meetings](
	[circuit_key] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[country_key] [int] NULL,
	[date_start] [datetime2](6) NOT NULL,
	[meeting_code] [varchar](3) COLLATE Latin1_General_CI_AS NULL,
	[meeting_key] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[meeting_name] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[meeting_official_name] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[gmt_offset] [int] NULL,
	[location_key] [int] NULL,
	[type_key] [int] NULL,
	[season_key] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
