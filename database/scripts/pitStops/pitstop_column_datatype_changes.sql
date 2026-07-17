ALTER TABLE [dbo].[pitStops] ALTER COLUMN [driver_key] INT NOT NULL;
ALTER TABLE [dbo].[pitStops] ALTER COLUMN [lap_number] INT NOT NULL;
ALTER TABLE [dbo].[pitStops] ALTER COLUMN [meeting_key] INT NOT NULL;
ALTER TABLE [dbo].[pitStops] ALTER COLUMN [session_key] INT NOT NULL;
ALTER TABLE [dbo].[pitStops] ALTER COLUMN [session_key] INT;
ALTER TABLE [dbo].[pitStops] ALTER COLUMN [meeting_key] INT;
ALTER TABLE [dbo].[pitStops] ALTER COLUMN [lap_number] INT;
ALTER TABLE [dbo].[pitStops] ALTER COLUMN [driver_key] INT;
ALTER TABLE [dbo].[pitStops] ALTER COLUMN [pit_duration] DECIMAL(10, 3);