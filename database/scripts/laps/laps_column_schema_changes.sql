ALTER TABLE [dbo].[laps] ALTER COLUMN driver_key INT NOT NULL;
ALTER TABLE [dbo].[laps] ALTER COLUMN lap_number INT NOT NULL;
ALTER TABLE [dbo].[laps] ALTER COLUMN meeting_key INT NOT NULL;
ALTER TABLE [dbo].[laps] ALTER COLUMN session_key INT NOT NULL;
ALTER TABLE [dbo].[laps] ALTER COLUMN [duration_sector_1] DECIMAL(10, 3)
ALTER TABLE [dbo].[laps] ALTER COLUMN [duration_sector_2] DECIMAL(10, 3)
ALTER TABLE [dbo].[laps] ALTER COLUMN [duration_sector_3] DECIMAL(10, 3)