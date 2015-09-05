CREATE FUNCTION [rev].[GenerateRevisionTriggerDDL]
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
	
	DECLARE @PrimaryKey VARCHAR(50) = null

	SELECT top 1 @PrimaryKey = c.name 
	FROM sys.columns c
		JOIN sys.tables t ON c.object_id = t.object_id
	WHERE 
		c.object_id = object_id(@SchemaName+'.' + @TableName)
		AND c.is_identity = 1;

	DECLARE @sql VARCHAR(MAX) 

	If (@PrimaryKey is not null) 
	BEGIN
		SET @sql = 'CREATE TRIGGER ['+@SchemaName+'].[tr_' + @TableName + '_rev]
	ON ['+@SchemaName+'].['+ @TableName+']
	AFTER UPDATE, INSERT, DELETE
	AS
	BEGIN
		IF EXISTS(SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
		BEGIN
			INSERT INTO ['+@RevSchemaName+'].['+@TableName+'Rev] SELECT i.'+@PrimaryKey+', '+[rev].[GetPrefixedColumnNames](@TableName,'i', @SchemaName)+',''u'' as operation, GetDate() as updated, SYSTEM_USER as updatedby FROM INSERTED i
		END	
		IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
		BEGIN
			INSERT INTO ['+@RevSchemaName+'].['+@TableName+'Rev] SELECT i.'+@PrimaryKey+', '+[rev].[GetPrefixedColumnNames](@TableName,'i', @SchemaName)+',''i'' as operation, GetDate() as updated, SYSTEM_USER as updatedby FROM INSERTED i
		END
		IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS(SELECT * FROM INSERTED)
		BEGIN
			INSERT INTO ['+@RevSchemaName+'].['+@TableName+'Rev] SELECT d.'+@PrimaryKey+', '+ [rev].[GetPrefixedColumnNames](@TableName,'d', @SchemaName)+',''d'' as operation, GetDate() as updated, SYSTEM_USER as updatedby FROM DELETED d
		END
	END';
	END ELSE 
	BEGIN
		SET @sql = 'CREATE TRIGGER ['+@SchemaName+'].[tr_' + @TableName + '_rev]
	ON ['+@SchemaName+'].['+ @TableName+']
	AFTER UPDATE, INSERT, DELETE
	AS
	BEGIN
		IF EXISTS(SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
		BEGIN
			INSERT INTO ['+@RevSchemaName+'].['+@TableName+'Rev] SELECT '+[rev].[GetPrefixedColumnNames](@TableName,'i', @SchemaName)+',''u'' as operation, GetDate() as updated, SYSTEM_USER as updatedby FROM INSERTED i
		END	
		IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
		BEGIN
			INSERT INTO ['+@RevSchemaName+'].['+@TableName+'Rev] SELECT '+[rev].[GetPrefixedColumnNames](@TableName,'i', @SchemaName)+',''i'' as operation, GetDate() as updated, SYSTEM_USER as updatedby FROM INSERTED i
		END
		IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS(SELECT * FROM INSERTED)
		BEGIN
			INSERT INTO ['+@RevSchemaName+'].['+@TableName+'Rev] SELECT '+ [rev].[GetPrefixedColumnNames](@TableName,'d', @SchemaName)+',''d'' as operation, GetDate() as updated, SYSTEM_USER as updatedby FROM DELETED d
		END
	END';	
	END
	
	RETURN @sql

END