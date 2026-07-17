/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001 at 04/02/2024 07:18:09
	See https://dbatools.io/Export-DbaScript for more information
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[drivers](
	[broadcast_name] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[country_code] [varchar](3) COLLATE Latin1_General_CI_AS NULL,
	[driver_key] [int] NOT NULL,
	[first_name] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[full_name] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[headshot_url] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[last_name] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[name_acronym] [varchar](3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
