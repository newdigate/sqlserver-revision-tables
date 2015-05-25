CREATE FUNCTION [dbo].[GenerateImportExistingRowsSQL] 
(
	@TableName varchar(50)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);
	SELECT @sql = 'INSERT INTO '+@TableName+'Rev ('+@TableName+'ID, '+[dbo].[GetColumnNames](@TableName)+', operation) SELECT u.ID, '+[dbo].[GetPrefixedColumnNames](@TableName, 'u') + ', ''i''  from ['+@TableName+'] u';
	RETURN @sql
END