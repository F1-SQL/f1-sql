CREATE FUNCTION dbo.SplitString
(
    @String NVARCHAR(MAX),
    @Delimiter NVARCHAR(10)
)
RETURNS @Result TABLE (Item NVARCHAR(MAX))
AS
BEGIN
    DECLARE @Index INT
    DECLARE @Slice NVARCHAR(MAX)

    SELECT @Index = 1

    IF @String IS NULL OR @String = ''
        RETURN

    WHILE @Index != 0
    BEGIN
        SET @Index = CHARINDEX(@Delimiter, @String)

        IF @Index != 0
            SET @Slice = LTRIM(RTRIM(LEFT(@String, @Index - 1))) -- Trim whitespace
        ELSE
            SET @Slice = LTRIM(RTRIM(@String)) -- Trim whitespace

        IF (LEN(@Slice) > 0)
            INSERT INTO @Result(Item) VALUES (@Slice)

        SET @String = RIGHT(@String, LEN(@String) - @Index)

        IF LEN(@String) = 0 BREAK
    END

    RETURN
END