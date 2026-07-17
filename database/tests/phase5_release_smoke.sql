/* Generic smoke assertions for a restored v2 release database. */
SET NOCOUNT ON;

IF NOT EXISTS (SELECT 1 FROM f1sql.Meeting)
    THROW 51200, 'release has no meetings', 1;
IF NOT EXISTS (SELECT 1 FROM f1sql.Session)
    THROW 51201, 'release has no sessions', 1;
IF NOT EXISTS (SELECT 1 FROM f1sql.Participant)
    THROW 51202, 'release has no participants', 1;
IF NOT EXISTS (SELECT 1 FROM f1sql.Result)
    THROW 51203, 'release has no results', 1;

IF EXISTS (
    SELECT 1
    FROM f1sql.Result AS r
    LEFT JOIN f1sql.Participant AS p
        ON p.SessionKey = r.SessionKey AND p.DriverKey = r.DriverKey
    WHERE p.SessionKey IS NULL
)
    THROW 51204, 'release has an orphan result', 1;

SELECT
    (SELECT COUNT(*) FROM f1sql.Meeting) AS MeetingCount,
    (SELECT COUNT(*) FROM f1sql.Session) AS SessionCount,
    (SELECT COUNT(*) FROM f1sql.Participant) AS ParticipantCount,
    (SELECT COUNT(*) FROM f1sql.Result) AS ResultCount;

SELECT N'release smoke passed' AS Result;
