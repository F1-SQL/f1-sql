/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001 at 09/04/2022 08:08:00
	See https://dbatools.io/Export-DbaScript for more information
*/
USE [f1db]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[circuits](
	[circuitId] [int] NOT NULL,
	[circuitRef] [varchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[name] [varchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[location] [varchar](255) COLLATE Latin1_General_CI_AS NULL,
	[country] [varchar](255) COLLATE Latin1_General_CI_AS NULL,
	[lat] [float] NULL,
	[lng] [float] NULL,
	[alt] [int] NULL,
	[url] [varchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
 CONSTRAINT [PK_circuits_circuitId] PRIMARY KEY CLUSTERED 
(
	[circuitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_circuits_url] UNIQUE NONCLUSTERED 
(
	[url] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[circuits] ADD  DEFAULT ('') FOR [circuitRef]
GO
ALTER TABLE [dbo].[circuits] ADD  DEFAULT ('') FOR [name]
GO
ALTER TABLE [dbo].[circuits] ADD  DEFAULT (NULL) FOR [location]
GO
ALTER TABLE [dbo].[circuits] ADD  DEFAULT (NULL) FOR [country]
GO
ALTER TABLE [dbo].[circuits] ADD  DEFAULT (NULL) FOR [lat]
GO
ALTER TABLE [dbo].[circuits] ADD  DEFAULT (NULL) FOR [lng]
GO
ALTER TABLE [dbo].[circuits] ADD  DEFAULT (NULL) FOR [alt]
GO
ALTER TABLE [dbo].[circuits] ADD  DEFAULT ('') FOR [url]
GO
