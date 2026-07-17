ALTER TABLE [dbo].[weather] ALTER COLUMN [air_temperature] DECIMAL(3,1)
ALTER TABLE [dbo].[weather] ALTER COLUMN [humidity] DECIMAL(3,1)
ALTER TABLE [dbo].[weather] ALTER COLUMN [meeting_key] INT NOT NULL;
ALTER TABLE [dbo].[weather] ALTER COLUMN [pressure] DECIMAL(5,1)
ALTER TABLE [dbo].[weather] ALTER COLUMN [rainfall] BIT;
ALTER TABLE [dbo].[weather] ALTER COLUMN [session_key] INT NOT NULL;
ALTER TABLE [dbo].[weather] ALTER COLUMN [track_temperature] DECIMAL(3,1)
ALTER TABLE [dbo].[weather] ALTER COLUMN [wind_direction] INT
ALTER TABLE [dbo].[weather] ALTER COLUMN [wind_speed] DECIMAL(3,1)