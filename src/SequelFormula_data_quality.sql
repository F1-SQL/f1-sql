/* DATA QUALITY FIX */

UPDATE [dbo].[circuits] SET country = 'USA' WHERE country = 'United States'