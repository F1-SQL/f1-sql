ALTER TABLE dbo.results ADD [resultTypeId] [int];
ALTER TABLE [dbo].[results] ADD positionTextID INT;
ALTER TABLE [dbo].[results] ADD [timeDifference] DATETIME NULL; 
ALTER TABLE [dbo].[results] ADD [fastestLapTime_Converted] TIME(3) NULL; 
ALTER TABLE [dbo].[results] ADD [fastestLapSpeed_Decimal] DECIMAL(18,3) NULL; 
ALTER TABLE [dbo].[results] ADD time_converted time(3);

GO

UPDATE r
SET
    r.positionTextID = pt.positionTextID
FROM
    dbo.results r
    INNER JOIN dbo.positionText pt ON r.positionText = pt.positioncode 
    
GO

WITH
    LeadingResults AS (
        SELECT
            raceID,
            positionOrder,
            dateadd (ms, milliseconds, '19800101') AS LeadTime
        FROM
            dbo.results
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
            dbo.results r
            INNER JOIN LeadingResults lr ON r.raceId = lr.raceId
    )
UPDATE r
SET
    r.TimeDifference = do.Diff
FROM
    dbo.results r
    INNER JOIN DataOutput DO ON r.resultId = do.resultId 
    
GO

UPDATE dbo.results
SET
    fastestLapTime_converted = TRY_CONVERT (
        TIME,
        STUFF (
            STUFF (
                RIGHT (
                    CONCAT ('000000', REPLACE (fastestLapTime, ':', '')),
                    10
                ),
                5,
                0,
                ':'
            ),
            3,
            0,
            ':'
        )
    ) 
    
GO


UPDATE dbo.results
SET
    fastestLapSpeed_Decimal = TRY_CONVERT (DECIMAL(18, 3), fastestLapSpeed);

GO
UPDATE dbo.results
SET
    time_converted = TRY_CONVERT (TIME(3), TIME)
WHERE
    POSITION = 1;

GO
UPDATE dbo.results
SET
    time_converted = TRY_CONVERT (TIME(3), TimeDifference)
WHERE
    POSITION != 1;

GO

ALTER TABLE [dbo].[results] DROP COLUMN [positionText];
ALTER TABLE [dbo].[results] DROP COLUMN [fastestLapTime];
ALTER TABLE [dbo].[results] DROP COLUMN [fastestLapSpeed];
ALTER TABLE [dbo].[results] DROP COLUMN [time];
ALTER TABLE [dbo].[results] DROP COLUMN [timeDifference];

GO

EXEC sp_rename 'dbo.results.fastestLapTime_converted', 'fastestLapTime', 'COLUMN';
EXEC sp_rename 'dbo.results.fastestLapSpeed_Decimal', 'fastestLapSpeed', 'COLUMN';
EXEC sp_rename 'dbo.results.time_converted', 'time', 'COLUMN';