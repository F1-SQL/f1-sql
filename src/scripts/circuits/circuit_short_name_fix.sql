UPDATE c

SET c.[circuitRef] = m.[circuit_short_name]
  
FROM [SequelFormulaNew].[dbo].[meetings] m 

INNER JOIN [dbo].[circuits] c ON m.circuit_key = c.circuit_key