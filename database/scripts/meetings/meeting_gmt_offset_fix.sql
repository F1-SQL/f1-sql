ALTER TABLE [dbo].[meetings] ADD [gmt_offset_new] INT

GO

UPDATE [dbo].[meetings] SET [gmt_offset_new] =
	CASE
		WHEN [gmt_offset] LIKE '-%' THEN 
			CONVERT(INT, LEFT(REPLACE(
							CONVERT(VARCHAR(8), [gmt_offset], 108),
							':',
							''
						),3)
					) 
		ELSE 
			CONVERT(INT, LEFT(REPLACE(
							CONVERT(VARCHAR(8), [gmt_offset], 108),
							':',
							''
						),2)
					) END

GO