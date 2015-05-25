IF EXISTS(SELECT * FROM SYS.objects where name = 'User')
	DROP TABLE [User]

IF EXISTS(SELECT * FROM SYS.objects where name = 'UserRev')
	DROP TABLE [UserRev]

CREATE TABLE [dbo].[User]
(
	[Id] BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1), 
    [Firstname] VARCHAR(100) NULL, 
    [Initial] CHAR(3) NULL, 
    [Surname] VARCHAR(100) NULL, 
    [Birthdate] DATETIME NULL
)

INSERT INTO [User] (Firstname, Initial, Surname, Birthdate) VALUES ('Nic', 'B', 'Newdigate',GetDate())

DECLARE @sql nvarchar(MAX)

SELECT @sql = [dbo].[GenerateRevisionTableDDL] ('User')
EXECUTE sp_executesql @sql

SELECT @sql = [dbo].[GenerateRevisionTriggerDDL] ('User')
EXECUTE sp_executesql @sql

SELECT @sql = [dbo].[GenerateImportExistingRowsSQL] ('User')
EXECUTE sp_executesql @sql
