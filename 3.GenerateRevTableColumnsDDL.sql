CREATE FUNCTION [dbo].[GenerateRevTableColumnsDDL]
( 
	@TableName AS VARCHAR(50) 
)
RETURNS VARCHAR(MAX)
AS
BEGIN 
	DECLARE @sql NVARCHAR(MAX) = N'';
	SELECT @sql += CASE
				WHEN column_ordinal = 1 AND UPPER(name) = 'ID' THEN
					CHAR(9) + '[ID]'+ CHAR(9) + 'BIGINT' +  CHAR(9) + 'NOT NULL PRIMARY KEY IDENTITY,' + CHAR(13) + CHAR(10) +
					CHAR(9) + '['+@TableName+'ID]'+ CHAR(9) + 'BIGINT' +  CHAR(9) + 'NOT NULL,' + CHAR(13) + CHAR(10)
				ELSE
					CHAR(9) + '[' + name + '] ' + system_type_name + ' NULL,'+ CHAR(13) + CHAR(10) 
			END
	FROM sys.dm_exec_describe_first_result_set('select * from dbo.['+@TableName+']', NULL, 1)
	RETURN @sql + CHAR(9) + '[operation] CHAR(1) NOT NULL,' + CHAR(13) + CHAR(10)
				+ CHAR(9) + '[updated] DATETIME NOT NULL DEFAULT GetDate(),'+ CHAR(13) + CHAR(10)
				+ CHAR(9) + '[updatedby] VARCHAR(100) NOT NULL DEFAULT SYSTEM_USER'
END
 