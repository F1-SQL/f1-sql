UPDATE sr 

 SET sr.positionTextID = pt.positionTextID 

FROM [dbo].[sprintResults] sr

INNER JOIN dbo.positionText pt ON sr.positionText = pt.positionText

GO

UPDATE [dbo].[sprintResults]
	SET
		fastestLapTime_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(fastestLapTime, ':', '')), 10), 5, 0, ':'), 3, 0, ':')) 

GO

WITH
    LeadingResults AS (
        SELECT
            raceID,
            positionOrder,
            dateadd (ms, milliseconds, '19800101') AS LeadTime
        FROM
            dbo.sprintResults
        WHERE
            positionOrder = 1
    ),
    DataOutput AS (
        SELECT
            resultID,
            r.raceID,
            r.positionOrder,
            milliseconds,
            TIME,
            dateadd (ms, r.milliseconds, '19800101') - CASE
                WHEN r.positionOrder = 1 THEN LAG (dateadd (ms, r.milliseconds, '19800101')) OVER (
                    ORDER BY
                        r.raceID,
                        r.positionOrder
                )
                WHEN r.positionOrder != 1 THEN lr.LeadTime
            END AS Diff
        FROM
            dbo.sprintResults r
            INNER JOIN LeadingResults lr ON r.raceId = lr.raceId
    )
UPDATE r
SET
    r.TimeDifference = do.Diff
FROM
    dbo.sprintResults r
    INNER JOIN DataOutput DO ON r.resultId = do.resultId 

GO

UPDATE [dbo].[sprintResults] SET time_converted = TRY_CONVERT(time, STUFF(STUFF(RIGHT(CONCAT('000000', REPLACE(time, ':', '')), 10), 5, 0, ':'), 3, 0, ':'))  WHERE position = 1;

GO

UPDATE [dbo].[sprintResults] SET time_converted = TRY_CONVERT(time(3),[TimeDifference]) WHERE position != 1

GO

ALTER TABLE [dbo].[sprintResults] DROP COLUMN [fastestLapTime];
ALTER TABLE [dbo].[sprintResults] DROP COLUMN [positionText];
ALTER TABLE [dbo].[sprintResults] DROP COLUMN [timeDifference];
ALTER TABLE [dbo].[sprintResults] DROP COLUMN [time];

GO

EXEC sp_rename 'dbo.sprintResults.fastestLapTime_converted', 'fastestLapTime', 'COLUMN';
EXEC sp_rename 'dbo.sprintResults.time_converted', 'time', 'COLUMN';