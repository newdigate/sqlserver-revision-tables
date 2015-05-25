CREATE FUNCTION [dbo].[GenerateRevisionTriggerDDL]
( 
	@TableName AS VARCHAR(40) 
) 
RETURNS VARCHAR(MAX)
AS 
BEGIN
	DECLARE @sql VARCHAR(MAX) = 'CREATE TRIGGER tr_' + @TableName + '_rev
ON ['+ @TableName+']
AFTER UPDATE, INSERT, DELETE
AS
BEGIN
	IF EXISTS(SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		INSERT INTO ['+@TableName+'Rev]('+@TableName+'ID,'+[dbo].[GetColumnNames](@TableName)+',operation, updated, updatedby) SELECT inserted.ID, '+[dbo].[GetPrefixedColumnNames](@TableName,'inserted')+',''u'', GetDate(), SYSTEM_USER FROM INSERTED
	END	

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
	BEGIN
		INSERT INTO ['+@TableName+'Rev]('+@TableName+'ID,'+[dbo].[GetColumnNames](@TableName)+',operation, updated, updatedby) SELECT inserted.ID, '+[dbo].[GetPrefixedColumnNames](@TableName,'inserted')+',''i'', GetDate(), SYSTEM_USER FROM INSERTED
	END

	IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS(SELECT * FROM INSERTED)
	BEGIN
		INSERT INTO ['+@TableName+'Rev]('+@TableName+'ID,'+[dbo].[GetColumnNames](@TableName)+',operation, updated, updatedby) SELECT deleted.ID, '+.[dbo].[GetPrefixedColumnNames](@TableName,'deleted')+',''d'', GetDate(), SYSTEM_USER FROM DELETED 
	END
END';
	RETURN @sql
END