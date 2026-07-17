ALTER TABLE [dbo].[sessions] ALTER COLUMN [session_key] INT NOT NULL;
ALTER TABLE [dbo].[sessions] ALTER COLUMN [meeting_key] INT;
ALTER TABLE [dbo].[sessions] ALTER COLUMN [session_key] INT;
ALTER TABLE [dbo].[sessions] ALTER COLUMN [circuit_key] INT;
ALTER TABLE [dbo].[sessions] ALTER COLUMN [session_name] varchar(15);