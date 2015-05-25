# SQLServer Revision Tables
This project aims to create scripts to automate the creation of revision tables for an existing table in SQLServer.

For a given table, the scripts will 
* create the revision table
* create the trigger for inserting rows into the revision table
* import existing rows from the table into the revision table

For instance say we have a table:
```sql
CREATE TABLE [dbo].Employee (
    [Id] BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [Firstname] VARCHAR(100) NULL,
    [Initial] CHAR(3) NULL,
    [Surname] VARCHAR(100) NULL,
    [Birthdate] DATETIME NULL
)
INSERT INTO Employee (Firstname, Initial, Surname, Birthdate) VALUES ('Nic', 'B', 'Newdigate',GetDate())
```

Here is how we would create a revision / audit table for it:
```sql
    DECLARE @sql nvarchar(MAX)

    SELECT @sql = [dbo].[GenerateRevisionTableDDL] ('Employee')
    PRINT @sql
    EXECUTE sp_executesql @sql

    SELECT @sql = [dbo].[GenerateRevisionTriggerDDL] ('Employee')
    PRINT @sql
    EXECUTE sp_executesql @sql

    SELECT @sql = [dbo].[GenerateImportExistingRowsSQL] ('Employee')
    PRINT @sql
    EXECUTE sp_executesql @sql
```

Which creates and executes this SQL:
```sql
CREATE TABLE EmployeeRev (
	[ID]	BIGINT	NOT NULL PRIMARY KEY IDENTITY,
	[EmployeeID]	BIGINT	NOT NULL,
	[Firstname] varchar(100) NULL,
	[Initial] char(3) NULL,
	[Surname] varchar(100) NULL,
	[Birthdate] datetime NULL,
	[operation] CHAR(1) NOT NULL,
	[updated] DATETIME NOT NULL DEFAULT GetDate(),
	[updatedby] VARCHAR(100) NOT NULL DEFAULT SYSTEM_USER)
	
CREATE TRIGGER tr_Employee_rev
ON [Employee]
AFTER UPDATE, INSERT, DELETE
AS
BEGIN
	IF EXISTS(SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		INSERT INTO [EmployeeRev](EmployeeID,Firstname,Initial,Surname,Birthdate,operation, updated, updatedby) SELECT inserted.ID, inserted.Firstname,inserted.Initial,inserted.Surname,inserted.Birthdate,'u', GetDate(), SYSTEM_USER FROM INSERTED
	END	

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
	BEGIN
		INSERT INTO [EmployeeRev](EmployeeID,Firstname,Initial,Surname,Birthdate,operation, updated, updatedby) SELECT inserted.ID, inserted.Firstname,inserted.Initial,inserted.Surname,inserted.Birthdate,'i', GetDate(), SYSTEM_USER FROM INSERTED
	END

	IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS(SELECT * FROM INSERTED)
	BEGIN
		INSERT INTO [EmployeeRev](EmployeeID,Firstname,Initial,Surname,Birthdate,operation, updated, updatedby) SELECT deleted.ID, deleted.Firstname,deleted.Initial,deleted.Surname,deleted.Birthdate,'d', GetDate(), SYSTEM_USER FROM DELETED 
	END
END

INSERT INTO EmployeeRev (EmployeeID, Firstname,Initial,Surname,Birthdate, operation) SELECT u.ID, u.Firstname,u.Initial,u.Surname,u.Birthdate, 'i'  from [Employee] u
```