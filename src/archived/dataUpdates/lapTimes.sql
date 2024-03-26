UPDATE [dbo].[lapTimes]
	SET
		time_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(time, ':', '')), 10), 5, 0, ':'), 3, 0, ':')); 
