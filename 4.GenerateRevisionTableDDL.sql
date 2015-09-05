CREATE FUNCTION [rev].[GenerateRevisionTableDDL]
(
	@TableName AS VARCHAR(40),
	@SchemaName AS VARCHAR(40) = 'dbo',
	@RevSchemaName AS VARCHAR(40) = null
) 
RETURNS VARCHAR(MAX)
AS
BEGIN 
	IF (@RevSchemaName is null)
		SET @RevSchemaName = @SchemaName

    RETURN 'CREATE TABLE ['+@RevSchemaName+'].[' + @TableName + 'Rev] (' + CHAR(13) + [rev].[GenerateRevTableColumnsDDL]( @TableName, @SchemaName ) + ')'
END