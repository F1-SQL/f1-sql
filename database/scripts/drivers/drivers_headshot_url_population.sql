;WITH HeadShotURL AS (

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
  headshot_url IS NOT NULL

)

UPDATE d

SET d.headshot_url = h.headshot_url

FROM drivers d 

INNER JOIN HeadShotURL h 
  ON d.driver_key = h.driver_key

WHERE d.headshot_url IS NULL
