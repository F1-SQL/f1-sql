UPDATE i

SET i.driver_key = 33

FROM 
	drivers d

INNER JOIN intervals i ON i.driver_key = d.driver_key


WHERE d.broadcast_name = 'M VERSTAPPEN'

GO

UPDATE l

SET l.driver_key = 33

FROM 
	drivers d


INNER JOIN laps l ON l.driver_key = d.driver_key


WHERE d.broadcast_name = 'M VERSTAPPEN'

GO

UPDATE ps 

SET ps.driver_key = 33

FROM 
	drivers d


INNER JOIN pitStops ps ON ps.driver_key = d.driver_key


WHERE d.broadcast_name = 'M VERSTAPPEN'

GO

UPDATE p 

SET p.driver_key = 33

FROM 
	drivers d


INNER JOIN position p ON p.driver_key = d.driver_key


WHERE d.broadcast_name = 'M VERSTAPPEN'

GO

UPDATE s

SET s.driver_key = 33

FROM 
	drivers d

INNER JOIN stints s ON s.driver_key = d.driver_key


WHERE d.broadcast_name = 'M VERSTAPPEN'

GO

UPDATE tr

SET tr.driver_key = 33


FROM 
	drivers d

INNER JOIN teamRadio tr ON tr.driver_key = d.driver_key

WHERE d.broadcast_name = 'M VERSTAPPEN'

GO

UPDATE dm 

SET dm.driver_key = 33

FROM 
	drivers d

INNER JOIN driverMeeting dm ON dm.driver_key = d.driver_key

WHERE d.broadcast_name = 'M VERSTAPPEN'

GO

UPDATE ds 

SET ds.driver_key = 33


FROM 
	drivers d

INNER JOIN driverSession ds ON ds.driver_key = d.driver_key

WHERE d.broadcast_name = 'M VERSTAPPEN'

GO

UPDATE dt 

SET dt.driver_key = 33

FROM 
	drivers d

INNER JOIN driverTeam dt  ON dt.driver_key = d.driver_key

WHERE d.broadcast_name = 'M VERSTAPPEN'

GO

UPDATE d

SET d.driver_key = 33


FROM 
	drivers d

WHERE d.broadcast_name = 'M VERSTAPPEN'

GO