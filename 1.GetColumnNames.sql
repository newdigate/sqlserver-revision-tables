CREATE FUNCTION [dbo].[GetColumnNames] 
(
	@TableName as nvarchar(50)
) 
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @sql VARCHAR(MAX) = N'';
	SELECT @sql += name + ',' FROM sys.columns 
			WHERE object_id = OBJECT_ID(@TableName) AND UPPER(name) != 'ID' AND UPPER(name) != UPPER(@TableName) + 'ID'
	RETURN LEFT(@sql, LEN(@sql)-1)
END