DECLARE @position INT = 1;

UPDATE [dbo].[drivers] SET first_name = JSON_VALUE('["' + REPLACE(full_name,' ','","') + '"]',CONCAT('$[',@position-1,']')) 
WHERE first_name IS NULL;