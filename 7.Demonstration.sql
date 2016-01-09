create schema [rev]
go

IF EXISTS(SELECT * FROM SYS.objects where name = 'User')
	DROP TABLE [User]

IF EXISTS(SELECT * FROM SYS.objects where name = 'UserRev')
	DROP TABLE [rev].[UserRev]

CREATE TABLE [dbo].[User]
(
    [Id] BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1), 
    [Firstname] VARCHAR(100) NULL, 
    [Initial] CHAR(3) NULL, 
    [Surname] VARCHAR(100) NULL, 
    [Birthdate] DATETIME NULL
)

INSERT INTO [User] (Firstname, Initial, Surname, Birthdate) VALUES ('Nic', 'h', 'Newdigate',GetDate())

DECLARE @sql nvarchar(MAX)

SELECT @sql = [rev].[GenerateRevisionTableDDL] ('User','dbo','rev')
EXECUTE sp_executesql @sql

SELECT @sql = [rev].[GenerateRevisionTriggerDDL] ('User','dbo','rev')
EXECUTE sp_executesql @sql

SELECT @sql = [rev].[GenerateImportExistingRowsSQL] ('User','dbo','rev')
EXECUTE sp_executesql @sql

-- or select generated SQL through query --

SELECT	s.name, 
		t.name, 
		[rev].[GenerateRevisionTableDDL]( t.name, s.name, 'rev') as SQLTableDDL,
		[rev].[GenerateRevisionTriggerDDL]( t.name, s.name, 'rev') as SQLTriggerDDL,
		[rev].[GenerateImportExistingRowsSQL]( t.name, s.name, 'rev') as SQLImportExistingRows
from sys.tables t
JOIN sys.schemas s
ON t.schema_id = s.schema_id
where s.name = 'dbo'


