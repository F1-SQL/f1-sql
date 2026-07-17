ALTER TABLE [dbo].[meetings] DROP COLUMN [gmt_offset];

GO

EXEC sp_rename 'dbo.meetings.gmt_offset_new', 'gmt_offset', 'COLUMN';
