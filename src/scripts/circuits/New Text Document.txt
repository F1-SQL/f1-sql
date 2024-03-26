ALTER TABLE [SequelFormulaNew].[dbo].[circuits] ADD circuit_key int

WITH CircuitData AS (

SELECT  [circuitId]
      ,[circuitRef]
      ,[name]
      ,c.[location]
      ,[country]
      ,[lat]
      ,[lng]
      ,[alt]
      ,[url]
      ,m.circuit_key
	  ,m.circuit_short_name
	  ,m.country_code
	  ,m.meeting_official_name
	  ,ROW_NUMBER() OVER(PARTITION BY m.circuit_short_name ORDER BY m.circuit_short_name) as [Row]

  FROM [dbo].[meetings] m

  LEFT JOIN [SequelFormulaNew].[dbo].[circuits] c on m.[circuit_short_name] = c.[circuitRef]

  WHERE m.year IS NOT NULL

) 

UPDATE c

SET c.circuit_key = cd.circuit_key

FROM CircuitData cd 

INNER JOIN [SequelFormulaNew].[dbo].[circuits] c ON c.circuitId = cd.circuitId


SELECT * FROM [dbo].[meetings] m

INNER JOIN [dbo].[circuits] c ON m.circuit_key = c.circuit_key