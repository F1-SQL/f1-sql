UPDATE m

SET m.meeting_official_name = [dbo].[ToProperCase](meeting_official_name)

FROM 
	[dbo].[meetings] m