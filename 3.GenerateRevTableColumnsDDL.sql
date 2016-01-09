CREATE FUNCTION [rev].[GenerateRevTableColumnsDDL]
( 
	@TableName AS VARCHAR(50),
	@SchemaName as varchar(50) = 'dbo'
)
RETURNS VARCHAR(MAX)
AS
BEGIN 
	DECLARE @sql NVARCHAR(MAX) = N'';
	SELECT @sql += CASE
				WHEN c.is_identity = 1 AND UPPER(c.name) like '%Id' THEN
					CHAR(9) + '['+@TableName+'RevId]'+ CHAR(9) + 'BIGINT' +  CHAR(9) + 'NOT NULL PRIMARY KEY IDENTITY,' + CHAR(13) + CHAR(10) +
					CHAR(9) + '['+@TableName+'Id]'+ CHAR(9) + 'BIGINT' +  CHAR(9) + 'NOT NULL,' + CHAR(13) + CHAR(10)
				ELSE

					CASE 
						WHEN (t.name like '%varchar') THEN
							CHAR(9) + '[' + c.name + '] ' + UPPER(t.name) + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CONVERT(VARCHAR(10),c.max_length) END + ')'  + ' NULL,'+ CHAR(13) + CHAR(10) 
						WHEN t.name = 'decimal' THEN
							CHAR(9) + '[' + c.name + '] ' + UPPER(t.name) + '(' + CONVERT(VARCHAR(10),c.[precision]) + ',' +  CONVERT(VARCHAR(10),c.scale) + ')'  + ' NULL,'+ CHAR(13) + CHAR(10) 
					ELSE 
						CHAR(9) + '[' + c.name + '] ' + t.name + ' NULL,'+ CHAR(13) + CHAR(10) 
					END
			END
	FROM sys.columns c  
	INNER JOIN sys.types AS t
	  ON c.system_type_id = t.system_type_id
	AND c.user_type_id = t.user_type_id
	WHERE c.[object_id] = OBJECT_ID(@SchemaName + '.' + @TableName)

	RETURN @sql + CHAR(9) + '[operation] CHAR(1) NOT NULL,' + CHAR(13) + CHAR(10)
				+ CHAR(9) + '[updated] DATETIME NOT NULL DEFAULT GetDate(),'+ CHAR(13) + CHAR(10)
				+ CHAR(9) + '[updatedby] VARCHAR(100) NOT NULL DEFAULT SYSTEM_USER'
END