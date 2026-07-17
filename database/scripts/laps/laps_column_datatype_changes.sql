ALTER TABLE [dbo].[laps] ALTER COLUMN [driver_key] INT NOT NULL;
ALTER TABLE [dbo].[laps] ALTER COLUMN [is_pit_out_lap] BIT;
ALTER TABLE [dbo].[laps] ALTER COLUMN [lap_number] INT;
ALTER TABLE [dbo].[laps] ALTER COLUMN [meeting_key] INT NOT NULL;
ALTER TABLE [dbo].[laps] ALTER COLUMN [session_key] INT NOT NULL;
ALTER TABLE [dbo].[laps] ALTER COLUMN [st_speed] INT;
ALTER TABLE [dbo].[laps] ALTER COLUMN [first_intermediate_speed] INT;
ALTER TABLE [dbo].[laps] ALTER COLUMN [second_intermediate_speed] INT;