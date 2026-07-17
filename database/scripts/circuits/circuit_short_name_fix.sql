UPDATE c

SET c.[circuit_short_name] = m.[circuit_short_name]
  
FROM 
    [dbo].[meetings] m 

INNER JOIN [dbo].[circuits] c 
    ON m.[circuit_key] = c.[circuit_key]