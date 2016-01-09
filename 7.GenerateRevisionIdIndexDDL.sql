CREATE FUNCTION [rev].[GenerateRevisionIdIndexDDL]
( 
	@TableName AS VARCHAR(40),
	@SchemaName as varchar(50) = 'dbo',
	@RevSchemaName as varchar(50) = 'rev'
) 
RETURNS VARCHAR(MAX)
AS 
BEGIN
	DECLARE @sql VARCHAR(MAX) = 'CREATE INDEX idx_'+ @TableName+'REV_' + @TableName + 'Id ON ['+@RevSchemaName+'].['+ @TableName+'Rev] ('+@TableName+'Id ASC)' + CHAR(13) + CHAR(10) +'GO';
	RETURN @sql
END