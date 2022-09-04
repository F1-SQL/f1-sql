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
CREATE TABLE [dbo].[qualifying](
	[qualifyId] [int] NOT NULL,
	[raceId] [int] NOT NULL,
	[driverId] [int] NOT NULL,
	[constructorId] [int] NOT NULL,
	[number] [int] NOT NULL,
	[position] [int] NULL,
	[q1] [varchar](255) COLLATE Latin1_General_CI_AS NULL,
	[q2] [varchar](255) COLLATE Latin1_General_CI_AS NULL,
	[q3] [varchar](255) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_qualifying_qualifyId] PRIMARY KEY CLUSTERED 
(
	[qualifyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qualifying] ADD  DEFAULT ((0)) FOR [raceId]
GO
ALTER TABLE [dbo].[qualifying] ADD  DEFAULT ((0)) FOR [driverId]
GO
ALTER TABLE [dbo].[qualifying] ADD  DEFAULT ((0)) FOR [constructorId]
GO
ALTER TABLE [dbo].[qualifying] ADD  DEFAULT ((0)) FOR [number]
GO
ALTER TABLE [dbo].[qualifying] ADD  DEFAULT (NULL) FOR [position]
GO
ALTER TABLE [dbo].[qualifying] ADD  DEFAULT (NULL) FOR [q1]
GO
ALTER TABLE [dbo].[qualifying] ADD  DEFAULT (NULL) FOR [q2]
GO
ALTER TABLE [dbo].[qualifying] ADD  DEFAULT (NULL) FOR [q3]
GO
ALTER TABLE [dbo].[qualifying]  WITH CHECK ADD  CONSTRAINT [FK_qualifying_constructorId] FOREIGN KEY([constructorId])
REFERENCES [dbo].[constructors] ([constructorId])
GO
ALTER TABLE [dbo].[qualifying] CHECK CONSTRAINT [FK_qualifying_constructorId]
GO
ALTER TABLE [dbo].[qualifying]  WITH CHECK ADD  CONSTRAINT [FK_qualifying_driverid] FOREIGN KEY([driverId])
REFERENCES [dbo].[drivers] ([driverId])
GO
ALTER TABLE [dbo].[qualifying] CHECK CONSTRAINT [FK_qualifying_driverid]
GO
ALTER TABLE [dbo].[qualifying]  WITH CHECK ADD  CONSTRAINT [FK_qualifying_raceId] FOREIGN KEY([raceId])
REFERENCES [dbo].[races] ([raceId])
GO
ALTER TABLE [dbo].[qualifying] CHECK CONSTRAINT [FK_qualifying_raceId]
GO
