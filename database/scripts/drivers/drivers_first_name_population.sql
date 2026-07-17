;WITH FirstNames AS (

SELECT [broadcast_name]
      ,[country_code]
      ,[driver_key]
      ,[first_name]
      ,[full_name]
      ,[headshot_url]  
      ,[last_name]
      ,[meeting_key]
      ,[name_acronym]
      ,[session_key]
      ,[team_colour]
      ,[team_name]
	  ,ROW_NUMBER() OVER(PARTITION BY driver_key ORDER BY driver_key) as RowNumber
  FROM [dbo].[drivers]
  WHERE first_name IS NOT NULL

)

UPDATE d

SET d.first_name = f.first_name

FROM drivers d 

INNER JOIN FirstNames f ON d.driver_key = f.driver_key

WHERE d.first_name IS NULL