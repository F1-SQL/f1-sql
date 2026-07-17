DECLARE @position INT = 2;

UPDATE [dbo].[drivers] SET last_name = JSON_VALUE('["' + REPLACE(full_name,' ','","') + '"]',CONCAT('$[',@position-1,']')) 
WHERE last_name IS NULL