ALTER TABLE [dbo].[drivers] ALTER COLUMN [country_code] varchar(3);
ALTER TABLE [dbo].[drivers] ALTER COLUMN [driver_key] INT NOT NULL;
ALTER TABLE [dbo].[drivers] ALTER COLUMN [meeting_key] INT NOT NULL;
ALTER TABLE [dbo].[drivers] ALTER COLUMN [session_key] INT NOT NULL;
ALTER TABLE [dbo].[drivers] ALTER COLUMN [name_acronym] varchar(3);
ALTER TABLE [dbo].[drivers] ALTER COLUMN [team_colour] varchar(6);