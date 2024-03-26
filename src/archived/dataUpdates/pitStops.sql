UPDATE [dbo].[pitStops] 
	SET
		duration_converted = TRY_CONVERT(decimal(18,3),duration)

UPDATE [dbo].[qualifying]
	SET
		q1_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(q1, ':', '')), 10), 5, 0, ':'), 3, 0, ':')),
		q2_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(q2, ':', '')), 10), 5, 0, ':'), 3, 0, ':')),
		q3_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(q3, ':', '')), 10), 5, 0, ':'), 3, 0, ':'));