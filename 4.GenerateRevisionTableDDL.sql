CREATE FUNCTION [dbo].[GenerateRevisionTableDDL]
(
	@TableName AS VARCHAR(50) 
) 
RETURNS VARCHAR(MAX)
AS
BEGIN 
    RETURN 'CREATE TABLE ' + @TableName + 'Rev (' + CHAR(13) + [dbo].[GenerateRevTableColumnsDDL]( @TableName ) + ')'
END