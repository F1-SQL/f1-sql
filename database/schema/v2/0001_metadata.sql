/* F1 SQL schema v2 metadata. No database name is assumed. */
IF SCHEMA_ID(N'f1sql') IS NULL
    EXEC(N'CREATE SCHEMA f1sql');
GO

IF OBJECT_ID(N'f1sql.SchemaHistory', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.SchemaHistory
    (
        SchemaVersion int NOT NULL,
        ScriptName nvarchar(255) NOT NULL,
        AppliedAtUtc datetime2(3) NOT NULL
            CONSTRAINT DF_SchemaHistory_AppliedAtUtc DEFAULT SYSUTCDATETIME(),
        ScriptSha256 char(64) NOT NULL,
        CONSTRAINT PK_SchemaHistory PRIMARY KEY (SchemaVersion),
        CONSTRAINT UQ_SchemaHistory_ScriptName UNIQUE (ScriptName),
        CONSTRAINT CK_SchemaHistory_Version CHECK (SchemaVersion > 0),
        CONSTRAINT CK_SchemaHistory_Sha256 CHECK (ScriptSha256 NOT LIKE '%[^0-9a-fA-F]%')
    );
END;
GO

IF OBJECT_ID(N'f1sql.BuildRun', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.BuildRun
    (
        RunId uniqueidentifier NOT NULL,
        TargetVersion nvarchar(32) NOT NULL,
        Season smallint NOT NULL,
        RoundNumber smallint NOT NULL,
        Revision smallint NOT NULL,
        CoreRepositorySha char(40) NOT NULL,
        DatabaseRepositorySha char(40) NOT NULL,
        SourceVersionsJson nvarchar(max) NOT NULL,
        ConfigFingerprint char(64) NOT NULL,
        StartedAtUtc datetime2(3) NOT NULL,
        CompletedAtUtc datetime2(3) NULL,
        Status nvarchar(32) NOT NULL,
        CONSTRAINT PK_BuildRun PRIMARY KEY (RunId),
        CONSTRAINT CK_BuildRun_Target CHECK (Season >= 1950 AND RoundNumber > 0 AND Revision >= 0),
        CONSTRAINT CK_BuildRun_Status CHECK (Status IN (N'planned', N'running', N'verified', N'failed')),
        CONSTRAINT CK_BuildRun_CoreSha CHECK (CoreRepositorySha NOT LIKE '%[^0-9a-fA-F]%'),
        CONSTRAINT CK_BuildRun_DatabaseSha CHECK (DatabaseRepositorySha NOT LIKE '%[^0-9a-fA-F]%'),
        CONSTRAINT CK_BuildRun_ConfigSha CHECK (ConfigFingerprint NOT LIKE '%[^0-9a-fA-F]%')
    );
END;
GO

IF OBJECT_ID(N'f1sql.SourceArtifact', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.SourceArtifact
    (
        ArtifactId uniqueidentifier NOT NULL,
        RunId uniqueidentifier NOT NULL,
        SourceName nvarchar(64) NOT NULL,
        SourceUrl nvarchar(2048) NULL,
        RelativePath nvarchar(800) NOT NULL,
        Sha256 char(64) NOT NULL,
        SizeBytes bigint NOT NULL,
        FetchedAtUtc datetime2(3) NULL,
        MediaType nvarchar(128) NULL,
        CONSTRAINT PK_SourceArtifact PRIMARY KEY (ArtifactId),
        CONSTRAINT FK_SourceArtifact_BuildRun FOREIGN KEY (RunId) REFERENCES f1sql.BuildRun (RunId),
        CONSTRAINT UQ_SourceArtifact_RunPath UNIQUE (RunId, RelativePath),
        CONSTRAINT CK_SourceArtifact_Size CHECK (SizeBytes >= 0),
        CONSTRAINT CK_SourceArtifact_Sha256 CHECK (Sha256 NOT LIKE '%[^0-9a-fA-F]%')
    );
END;
GO

IF OBJECT_ID(N'f1sql.ExternalIdentifier', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.ExternalIdentifier
    (
        ExternalIdentifierId bigint IDENTITY(1, 1) NOT NULL,
        EntityType nvarchar(64) NOT NULL,
        EntityKey nvarchar(128) NOT NULL,
        SourceName nvarchar(64) NOT NULL,
        ExternalId nvarchar(256) NOT NULL,
        FirstSeenRunId uniqueidentifier NOT NULL,
        CONSTRAINT PK_ExternalIdentifier PRIMARY KEY (ExternalIdentifierId),
        CONSTRAINT FK_ExternalIdentifier_BuildRun FOREIGN KEY (FirstSeenRunId) REFERENCES f1sql.BuildRun (RunId),
        CONSTRAINT UQ_ExternalIdentifier_SourceId UNIQUE (SourceName, ExternalId),
        CONSTRAINT UQ_ExternalIdentifier_Entity UNIQUE (EntityType, EntityKey, SourceName)
    );
END;
GO

IF OBJECT_ID(N'f1sql.DataRelease', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.DataRelease
    (
        ReleaseVersion nvarchar(32) NOT NULL,
        RunId uniqueidentifier NOT NULL,
        PublishedAtUtc datetime2(3) NULL,
        ReleaseUrl nvarchar(2048) NULL,
        ManifestSha256 char(64) NOT NULL,
        QualityReportSha256 char(64) NOT NULL,
        CONSTRAINT PK_DataRelease PRIMARY KEY (ReleaseVersion),
        CONSTRAINT FK_DataRelease_BuildRun FOREIGN KEY (RunId) REFERENCES f1sql.BuildRun (RunId),
        CONSTRAINT CK_DataRelease_ManifestSha CHECK (ManifestSha256 NOT LIKE '%[^0-9a-fA-F]%'),
        CONSTRAINT CK_DataRelease_QualitySha CHECK (QualityReportSha256 NOT LIKE '%[^0-9a-fA-F]%')
    );
END;
GO
