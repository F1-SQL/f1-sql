;WITH CountryCodes AS (

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
  WHERE country_code IS NOT NULL

)

UPDATE d

SET d.[country_code] = c.[country_code]

FROM drivers d 

INNER JOIN CountryCodes c 
  ON d.[driver_key] = c.[driver_key]

WHERE d.[country_code] IS NULL