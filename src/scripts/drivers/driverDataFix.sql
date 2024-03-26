;WITH HeadShotURL AS (

SELECT [broadcast_name]
      ,[country_code]
      ,[driver_number]
      ,[first_name]
      ,[full_name]
      ,[headshot_url]  
      ,[last_name]
      ,[meeting_key]
      ,[name_acronym]
      ,[session_key]
      ,[team_colour]
      ,[team_name]
	  ,ROW_NUMBER() OVER(PARTITION BY driver_number ORDER BY driver_number) as RowNumber
  FROM [SequelFormulaNew].[dbo].[drivers]
  WHERE headshot_url IS NOT NULL

)

UPDATE d

SET d.headshot_url = h.headshot_url

FROM drivers d 

INNER JOIN HeadShotURL h ON d.driver_number = h.driver_number

WHERE d.headshot_url IS NULL


;WITH LastNames AS (

SELECT [broadcast_name]
      ,[country_code]
      ,[driver_number]
      ,[first_name]
      ,[full_name]
      ,[headshot_url]  
      ,[last_name]
      ,[meeting_key]
      ,[name_acronym]
      ,[session_key]
      ,[team_colour]
      ,[team_name]
	  ,ROW_NUMBER() OVER(PARTITION BY driver_number ORDER BY driver_number) as RowNumber
  FROM [SequelFormulaNew].[dbo].[drivers]
  WHERE last_name IS NOT NULL

)

UPDATE d

SET d.last_name = l.last_name

FROM drivers d 

INNER JOIN LastNames l ON d.driver_number = l.driver_number

WHERE d.last_name IS NULL


;WITH FirstNames AS (

SELECT [broadcast_name]
      ,[country_code]
      ,[driver_number]
      ,[first_name]
      ,[full_name]
      ,[headshot_url]  
      ,[last_name]
      ,[meeting_key]
      ,[name_acronym]
      ,[session_key]
      ,[team_colour]
      ,[team_name]
	  ,ROW_NUMBER() OVER(PARTITION BY driver_number ORDER BY driver_number) as RowNumber
  FROM [SequelFormulaNew].[dbo].[drivers]
  WHERE first_name IS NOT NULL

)

UPDATE d

SET d.first_name = f.first_name

FROM drivers d 

INNER JOIN FirstNames f ON d.driver_number = f.driver_number

WHERE d.first_name IS NULL


;WITH CountryCodes AS (

SELECT [broadcast_name]
      ,[country_code]
      ,[driver_number]
      ,[first_name]
      ,[full_name]
      ,[headshot_url]  
      ,[last_name]
      ,[meeting_key]
      ,[name_acronym]
      ,[session_key]
      ,[team_colour]
      ,[team_name]
	  ,ROW_NUMBER() OVER(PARTITION BY driver_number ORDER BY driver_number) as RowNumber
  FROM [SequelFormulaNew].[dbo].[drivers]
  WHERE country_code IS NOT NULL

)

UPDATE d

SET d.country_code = c.country_code

FROM drivers d 

INNER JOIN CountryCodes c ON d.driver_number = c.driver_number

WHERE d.country_code IS NULL

