;WITH LastNames AS (

SELECT 
  [broadcast_name]
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
FROM 
  [dbo].[drivers]
WHERE 
  last_name IS NOT NULL

)

UPDATE d

SET d.last_name = l.last_name

FROM drivers d 

INNER JOIN LastNames l ON d.driver_key = l.driver_key

WHERE d.last_name IS NULL