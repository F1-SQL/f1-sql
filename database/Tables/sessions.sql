/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001 at 04/02/2024 07:18:10
	See https://dbatools.io/Export-DbaScript for more information
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sessions](
	[circuit_key] [int] NULL,
	[date_end] [datetime2](6) NULL,
	[date_start] [datetime2](6) NULL,
	[meeting_key] [int] NULL,
	[session_key] [int] NULL,
	[session_name] [varchar](15) COLLATE Latin1_General_CI_AS NULL,
	[type_key] [int] NULL
) ON [PRIMARY]
GO
