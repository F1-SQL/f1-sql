/* Opt-in compatibility projection for the legacy two-column teams table. */
IF OBJECT_ID(N'f1sql.legacy_teams', N'V') IS NULL
BEGIN
    EXEC(N'
        CREATE VIEW f1sql.legacy_teams
        AS
        SELECT
            ConstructorKey AS team_key,
            Name AS team_name
        FROM f1sql.Constructor;
    ');
END;
GO
