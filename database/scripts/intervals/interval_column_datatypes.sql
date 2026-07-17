ALTER TABLE [dbo].[intervals] ALTER COLUMN [driver_key] INT NOT NULL;
ALTER TABLE [dbo].[intervals] ALTER COLUMN [meeting_key] INT NOT NULL;
ALTER TABLE [dbo].[intervals] ALTER COLUMN [session_key] INT NOT NULL;
ALTER TABLE [dbo].[intervals] ALTER COLUMN [gap_to_leader] decimal(7,3);
ALTER TABLE [dbo].[intervals] ALTER COLUMN [interval] decimal(7,3);
ALTER TABLE [dbo].[intervals] ALTER COLUMN [date] DATETIME2(6) NOT NULL;