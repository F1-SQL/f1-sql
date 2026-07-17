/* Assertions after rendering and applying the checked-in fixture load plan. */
SET NOCOUNT ON;

IF (SELECT COUNT(*) FROM f1sql.Meeting) <> 1
    THROW 51100, 'fixture meeting count mismatch', 1;
IF (SELECT COUNT(*) FROM f1sql.Session) <> 1
    THROW 51101, 'fixture session count mismatch', 1;
IF (SELECT COUNT(*) FROM f1sql.Participant) <> 2
    THROW 51102, 'fixture participant count mismatch', 1;
IF (SELECT COUNT(*) FROM f1sql.Result) <> 2
    THROW 51103, 'fixture result count mismatch', 1;
IF (SELECT COUNT(*) FROM f1sql.Lap) <> 1
    THROW 51104, 'fixture lap count mismatch', 1;
IF (SELECT COUNT(*) FROM f1sql.Stint) <> 1
    THROW 51105, 'fixture stint count mismatch', 1;
IF (SELECT COUNT(*) FROM f1sql.Weather) <> 1
    THROW 51106, 'fixture weather count mismatch', 1;
IF (SELECT COUNT(*) FROM f1sql.RaceControl) <> 1
    THROW 51107, 'fixture race-control count mismatch', 1;

SELECT
    m.MeetingKey,
    s.SessionKey,
    COUNT(DISTINCT r.DriverKey) AS ClassifiedDrivers,
    COUNT(DISTINCT l.LapNumber) AS LapRows,
    COUNT(DISTINCT w.ObservedAtUtc) AS WeatherRows
FROM f1sql.Meeting AS m
JOIN f1sql.Session AS s ON s.MeetingKey = m.MeetingKey
LEFT JOIN f1sql.Result AS r ON r.SessionKey = s.SessionKey
LEFT JOIN f1sql.Lap AS l ON l.SessionKey = s.SessionKey
LEFT JOIN f1sql.Weather AS w ON w.SessionKey = s.SessionKey
GROUP BY m.MeetingKey, s.SessionKey;

SELECT N'fixture smoke passed' AS Result;
