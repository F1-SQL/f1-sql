 ;WITH DuplicateDrivers AS ( 

 SELECT 
     driver_key, 
	 team_key,
     ROW_NUMBER() OVER(PARTITION BY driver_key ORDER BY driver_key) as RowNumber  
 FROM 
     [dbo].[drivers] 
 )

DELETE FROM DuplicateDrivers WHERE RowNumber > 1 