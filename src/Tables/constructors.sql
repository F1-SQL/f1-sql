/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001 at 09/04/2022 08:08:01
	See https://dbatools.io/Export-DbaScript for more information
*/
USE [f1db]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[constructors](
	[constructorId] [int] NOT NULL,
	[constructorRef] [varchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[name] [varchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[nationality] [varchar](255) COLLATE Latin1_General_CI_AS NULL,
	[url] [varchar](2048) COLLATE Latin1_General_CI_AS NOT NULL,
 CONSTRAINT [PK_constructors_constructorId] PRIMARY KEY CLUSTERED 
(
	[constructorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_constructors_name] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[constructors] ADD  DEFAULT ('') FOR [constructorRef]
GO
ALTER TABLE [dbo].[constructors] ADD  DEFAULT ('') FOR [name]
GO
ALTER TABLE [dbo].[constructors] ADD  DEFAULT (NULL) FOR [nationality]
GO
ALTER TABLE [dbo].[constructors] ADD  DEFAULT ('') FOR [url]
GO
