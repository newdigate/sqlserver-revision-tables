# SQLServer Revision Tables

[![Join the chat at https://gitter.im/newdigate/sqlserver-revision-tables](https://badges.gitter.im/newdigate/sqlserver-revision-tables.svg)](https://gitter.im/newdigate/sqlserver-revision-tables?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This project aims to create scripts to automate the creation of revision tables for an existing table in SQLServer.

For a given table, the scripts will 
* create the revision table
* create the trigger for inserting rows into the revision table
* import existing rows from the table into the revision table

limitations:
* the output of each stored procedures is limited to 8000 characters. This will be addressed shortly. 

updates:
* 09 January 2016
	* Added option for application to override username by setting Context_Info(), for instance when using ASP.NET
* 05 September 2015
	* fixed SQLServer 2008 compatability issue by using [sys].[columns] instead of [sys].[dm_exec_describe_first_result_set] to get column definitions.
	* Split sql into seperate schemas for revision tables and non-revision tables
	* Using is_identity to identity primary key instead of LIKE '%ID'....

todo:
* Get around 8K limitation on generated SQL by returning table of VARCHAR(MAX) instead of returning VARCHAR(MAX) parameter

For instance say we have a table:
```sql
CREATE TABLE [dbo].Employee (
    [Id] BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [Firstname] VARCHAR(100) NULL,
    [Initial] CHAR(3) NULL,
    [Surname] VARCHAR(100) NULL,
    [Birthdate] DATETIME NULL
)
INSERT INTO Employee (Firstname, Initial, Surname, Birthdate) VALUES ('Nic', 'C', 'Newdigate',GetDate())
```

Here is how we would create a revision / audit table for it:
```sql
    DECLARE @sql nvarchar(MAX)

    -- generate and execute sql to create audit / revision table
    SELECT @sql = [rev].[GenerateRevisionTableDDL] ('Employee','dbo','rev')
    PRINT @sql
    EXECUTE sp_executesql @sql

    -- generate and execute sql to create trigger to capture revision row on insert, update or delete
    SELECT @sql = [rev].[GenerateRevisionTriggerDDL] ('Employee','dbo','rev')
    PRINT @sql
    EXECUTE sp_executesql @sql

    -- generate and execute sql to import existing rows to revision tables with operation column in revision table populated with 'm' (for migrated)
    SELECT @sql = [rev].[GenerateImportExistingRowsSQL] ('Employee','dbo','rev')
    PRINT @sql
    EXECUTE sp_executesql @sql

    -- generate and execute sql to create indexes on the revision tables
    SELECT @sql = [rev].[GenerateRevisionIdIndexDDL]('Employee','dbo','rev')
    PRINT @sql
    EXECUTE sp_executesql @sql

```

Which creates and executes this SQL:
```sql
CREATE TABLE [rev].[EmployeeRev] (
	[EmployeeRevId]	BIGINT	NOT NULL PRIMARY KEY IDENTITY,
	[EmployeeId]	BIGINT	NOT NULL,
	[Firstname] varchar(100) NULL,
	[Initial] char(3) NULL,
	[Surname] varchar(100) NULL,
	[Birthdate] datetime NULL,
	[operation] CHAR(1) NOT NULL,
	[updated] DATETIME NOT NULL DEFAULT GetDate(),
	[updatedby] VARCHAR(100) NOT NULL DEFAULT SYSTEM_USER)
	
CREATE TRIGGER [dbo].[tr_User_rev]
	ON [dbo].[User]
	AFTER UPDATE, INSERT, DELETE
	AS
	BEGIN
		DECLARE @USERNAME VARCHAR(100)
        	SET @USERNAME = CASE WHEN CONVERT(VARCHAR, CONTEXT_INFO()) <> '' THEN CONVERT(VARCHAR, CONTEXT_INFO()) ELSE SYSTEM_USER END
		
		IF EXISTS(SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
		BEGIN
			INSERT INTO [rev].[UserRev] SELECT i.Id, i.Firstname,i.Initial,i.Surname,i.Birthdate,'u' as operation, GetDate() as updated, @USERNAME as updatedby FROM INSERTED i
		END	
		IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
		BEGIN
			INSERT INTO [rev].[UserRev] SELECT i.Id, i.Firstname,i.Initial,i.Surname,i.Birthdate,'i' as operation, GetDate() as updated, @USERNAME as updatedby FROM INSERTED i
		END
		IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS(SELECT * FROM INSERTED)
		BEGIN
			INSERT INTO [rev].[UserRev] SELECT d.Id, d.Firstname,d.Initial,d.Surname,d.Birthdate,'d' as operation, GetDate() as updated, @USERNAME as updatedby FROM DELETED d
		END
	END

IF NOT EXISTS(Select 0 from [rev].[UserRev]) INSERT INTO [rev].UserRev (UserId, Firstname,Initial,Surname,Birthdate, operation) SELECT u.Id, u.Firstname,u.Initial,u.Surname,u.Birthdate, 'm'  from [dbo].[User] u

CREATE INDEX idx_UserREV_UserId ON [rev].[UserRev] (UserId ASC)

```