/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001 at 04/02/2024 07:18:09
	See https://dbatools.io/Export-DbaScript for more information
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[circuits](
	[circuit_key] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[circuit_short_name] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[name] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[location_key] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[country_key] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[direction_key] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[type_key] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[alt] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[url] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
