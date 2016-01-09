CREATE FUNCTION [rev].[GenerateImportExistingRowsSQL] 
(
	@TableName varchar(50),
	@SchemaName varchar(50) = 'dbo',
	@RevSchemaName varchar(50) = null
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @PrimaryKey VARCHAR(50) = null

	--IF EXISTS(SELECT * FROM sys.columns c JOIN sys.tables t ON c.object_id = t.object_id WHERE c.object_id = object_id(@SchemaName+'.' + @TableName) AND c.is_identity = 1)
	--BEGIN
		SELECT top 1 @PrimaryKey = c.name 
		FROM sys.columns c
			JOIN sys.tables t ON c.object_id = t.object_id
		WHERE 
			c.object_id = object_id(@SchemaName+'.' + @TableName)
			AND c.is_identity = 1;
	--END

	IF (@RevSchemaName is null)
		SET @RevSchemaName = @SchemaName

	DECLARE @sql VARCHAR(MAX);

	IF (@PrimaryKey is not null)
		SELECT @sql = 'IF NOT EXISTS(Select 0 from ['+@RevSchemaName+'].['+@TableName+'Rev]) INSERT INTO ['+@RevSchemaName+'].'+@TableName+'Rev ('+@TableName+'Id, '+[rev].[GetColumnNames](@TableName,@SchemaName)+', operation) SELECT u.'+@PrimaryKey+', '+[rev].[GetPrefixedColumnNames](@TableName, 'u', @SchemaName) + ', ''m''  from ['+@SchemaName+'].['+@TableName+'] u';
	ELSE 
		SELECT @sql = 'IF NOT EXISTS(Select 0 from ['+@RevSchemaName+'].['+@TableName+'Rev]) INSERT INTO ['+@RevSchemaName+'].'+@TableName+'Rev ('+[rev].[GetColumnNames](@TableName,@SchemaName)+', operation) SELECT '+[rev].[GetPrefixedColumnNames](@TableName, 'u', @SchemaName) + ', ''m''  from ['+@SchemaName+'].['+@TableName+'] u';
	RETURN @sql
END