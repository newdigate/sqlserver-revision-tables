CREATE FUNCTION [rev].[GetColumnNames] 
(
	@TableName as varchar(50),
	@SchemaName as varchar(50) = 'dbo'
) 
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @sql VARCHAR(MAX) = N'';
	SELECT @sql += name + ',' FROM sys.columns 
			WHERE object_id = OBJECT_ID(@SchemaName + '.' + @TableName) AND is_identity <> 1 
	IF LEN(@sql) > 0
		RETURN LEFT(@sql, LEN(@sql)-1)
	
	RETURN NULL
END