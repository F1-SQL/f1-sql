/* SQL Server 2019 Phase 5 integration assertions. Run against an empty v2 database. */
SET NOCOUNT ON;

IF (SELECT COUNT(*) FROM sys.tables WHERE schema_id = SCHEMA_ID(N'f1sql')) <> 18
    THROW 51000, 'Phase 5 expected 18 v2 tables', 1;

IF OBJECT_ID(N'f1sql.legacy_teams', N'V') IS NULL
    THROW 51005, 'legacy_teams compatibility view is missing', 1;

/* The generated loader uses this shape: rerunning it must not duplicate rows. */
MERGE INTO f1sql.Season AS target
USING (VALUES (2024)) AS source ([SeasonKey])
ON target.[SeasonKey] = source.[SeasonKey]
WHEN MATCHED THEN UPDATE SET target.[SeasonKey] = source.[SeasonKey]
WHEN NOT MATCHED THEN INSERT ([SeasonKey]) VALUES (source.[SeasonKey]);

MERGE INTO f1sql.Season AS target
USING (VALUES (2024)) AS source ([SeasonKey])
ON target.[SeasonKey] = source.[SeasonKey]
WHEN MATCHED THEN UPDATE SET target.[SeasonKey] = source.[SeasonKey]
WHEN NOT MATCHED THEN INSERT ([SeasonKey]) VALUES (source.[SeasonKey]);

IF (SELECT COUNT(*) FROM f1sql.Season WHERE SeasonKey = 2024) <> 1
    THROW 51001, 'Season MERGE is not idempotent', 1;

/* A failed operation must leave the transaction with no partial row. */
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO f1sql.Season (SeasonKey) VALUES (2025);
    INSERT INTO f1sql.Season (SeasonKey) VALUES (2025);
    COMMIT TRANSACTION;
    THROW 51002, 'Duplicate-key transaction unexpectedly committed', 1;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
END CATCH;

IF EXISTS (SELECT 1 FROM f1sql.Season WHERE SeasonKey = 2025)
    THROW 51003, 'Rollback left a partial Season row', 1;

/* Check constraints must reject invalid seasons. */
BEGIN TRY
    INSERT INTO f1sql.Season (SeasonKey) VALUES (1949);
    THROW 51004, 'Season check constraint did not reject 1949', 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51004 THROW;
END CATCH;

SELECT N'phase5 integration passed' AS Result;
