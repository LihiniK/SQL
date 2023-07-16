
/****** Object:  StoredProcedure [dbo].[spGenerateAuditTrgsTblsNew]    Script Date: 7/2/2018 4:05:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROC [dbo].[spGenerateAuditTrgsTblsNew]
 @Schemaname Sysname = 'dbo' 
,@Tablename  Sysname 
,@AuditDBname  Sysname 
,@GenerateScriptOnly    bit = 1 
AS 
BEGIN

	SET NOCOUNT ON;
 
/* 
Parameters 
@Schemaname           - SchemaName to which the table belongs to. Default value 'dbo'. 
@Tablename            - TableName for which the procs needs to be generated. 
@GenerateScriptOnly - When passed 1 , this will generate the scripts alone. 
                      When passed 0 , this will create the audit tables and triggers in the current database. 
                      Default value is 1 
*/  
 
DECLARE @SQL VARCHAR(MAX) 
DECLARE @SQLTrigger VARCHAR(MAX) 
DECLARE @AuditTableName SYSNAME 
DECLARE @DBname SYSNAME 
select @DBname = db_name()  
 
SELECT @AuditTableName =  @Tablename + '_forAuditTb'
 
---------------------------------------------------------------------------------------------------------------------- 
-- Audit Create table  
---------------------------------------------------------------------------------------------------------------------- 

DECLARE @ColList VARCHAR(MAX)

SELECT @ColList = ''

SELECT @ColList = @ColList +   CASE SC.is_identity
							   WHEN 1 THEN 'CONVERT(' + ST.name + ',' + QUOTENAME(SC.name) + ') as ' + QUOTENAME(SC.name)
							   ELSE QUOTENAME(SC.name)
							   END + ','
  FROM SYS.COLUMNS SC
  JOIN SYS.OBJECTS SO
    ON SC.object_id = SO.object_id   
  JOIN SYS.schemas SCH
    ON SCH.schema_id = SO.schema_id
  JOIN SYS.types ST
    ON ST.user_type_id = SC.user_type_id
   AND ST.system_type_id = SC.system_type_id 
 WHERE SCH.Name = @Schemaname 
	AND ST.name not in ('text','ntext','image','binary')
   AND SO.name  = @Tablename 
   and SC.name not in ('rowguid', 'msrepl_tran_version') 

SELECT @ColList = SUBSTRING(@ColList,1,LEN(@ColList)-1)
--print @ColList
---------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------


SELECT @SQL = '  
use [' + @AuditDBname + ']

IF NOT EXISTS (SELECT 1  
             FROM sys.objects  
            WHERE Name=''' + @AuditTableName + ''' 
              AND Schema_id=Schema_id(''' + @Schemaname + ''') 
              AND Type = ''U'') 
BEGIN

SELECT ' + @ColList + ' 
    ,AuditDataState=CONVERT(NVARCHAR(10),'''')  
    ,AuditDMLAction=CONVERT(NVARCHAR(10),'''')  
    ,AuditHostName=CONVERT(NVARCHAR(50),'''')  
    ,AuditAppName=CONVERT(NVARCHAR(500),'''')
    ,AuditUser =CONVERT(SYSNAME,'''') 
    ,AuditDateTime=CONVERT(DATETIME,''01-JAN-1900'') 
    Into ' + QUOTENAME(@Schemaname) + '.' + QUOTENAME(@AuditTableName) + ' 
FROM ' + QUOTENAME(@DBname) + '.' + QUOTENAME(@Schemaname) + '.' + QUOTENAME(@Tablename) +' 
WHERE 1=2

ALTER TABLE ' + QUOTENAME(@Schemaname) + '.' + QUOTENAME(@AuditTableName) + ' ADD myauindx int NOT NULL IDENTITY (1,1) PRIMARY KEY

END
' 
 
IF @GenerateScriptOnly = 1 
BEGIN 
    PRINT REPLICATE ('-',200) 
    PRINT '--Create Script Audit table for ' + @Schemaname + '.' + @Tablename 
    PRINT REPLICATE ('-',200) 
    PRINT @SQL 
    PRINT 'GO' 
END 
ELSE 
BEGIN 
    PRINT 'Creating Audit table for ' + @Schemaname + '.' + @Tablename 
    EXEC(@SQL) 
    PRINT 'Audit table ' + @Schemaname + '.' + @AuditTableName + ' Created succefully' 
END 
 
 
---------------------------------------------------------------------------------------------------------------------- 
-- Create Insert Trigger 
---------------------------------------------------------------------------------------------------------------------- 
 
 
SELECT @SQL = ' 
IF EXISTS (SELECT 1  
             FROM sys.objects  
            WHERE Name=''' + @Tablename + '_AuditInsert' + ''' 
              AND Schema_id=Schema_id(''' + @Schemaname + ''') 
              AND Type = ''TR'') 
DROP TRIGGER [' + @Tablename + '_AuditInsert] 
' 

SELECT @SQLTrigger = ' 
CREATE TRIGGER [' + @Tablename + '_AuditInsert] 
ON '+ QUOTENAME(@Schemaname) + '.' + QUOTENAME(@Tablename) + ' 
WITH EXECUTE AS ''dmladmin''
FOR INSERT 
NOT FOR REPLICATION 
AS
BEGIN
 SET NOCOUNT ON;
	
 INSERT INTO ' + QUOTENAME(@AuditDBname) + '.' + QUOTENAME(@Schemaname) + '.' + QUOTENAME(@AuditTableName) +' 
 SELECT ' + @ColList + ',''New'',''Insert'',host_name(),app_name(),ORIGINAL_LOGIN(),getdate()  FROM INSERTED  
 
END
' 
 
IF @GenerateScriptOnly = 1 
BEGIN 
    PRINT REPLICATE ('-',200) 
    PRINT '--Create Script Insert Trigger for ' + @Schemaname + '.' + @Tablename 
    PRINT REPLICATE ('-',200) 
    PRINT @SQL 
    PRINT 'GO' 
    PRINT @SQLTrigger 
    PRINT 'GO' 
END 
ELSE 
BEGIN 
    PRINT 'Creating Insert Trigger ' + @Tablename + '_AuditInsert  for ' + @Schemaname + '.' + @Tablename 
    EXEC(@SQL) 
    EXEC(@SQLTrigger) 
    PRINT 'Trigger ' + @Schemaname + '.' + @Tablename + '_AuditInsert  Created succefully' 
END 
 
 
---------------------------------------------------------------------------------------------------------------------- 
-- Create Delete Trigger 
---------------------------------------------------------------------------------------------------------------------- 
 
 
SELECT @SQL = ' 
 
IF EXISTS (SELECT 1  
             FROM sys.objects  
            WHERE Name=''' + @Tablename + '_AuditDelete' + ''' 
              AND Schema_id=Schema_id(''' + @Schemaname + ''') 
              AND Type = ''TR'') 
DROP TRIGGER [' + @Tablename + '_AuditDelete] 
' 
 
SELECT @SQLTrigger =  
' 
CREATE TRIGGER [' + @Tablename + '_AuditDelete] 
ON '+ QUOTENAME(@Schemaname) + '.' + QUOTENAME(@Tablename) + ' 
WITH EXECUTE AS ''dmladmin''
FOR DELETE 
NOT FOR REPLICATION 
AS 
 BEGIN
	SET NOCOUNT ON;

 INSERT INTO ' + QUOTENAME(@AuditDBname) + '.' + QUOTENAME(@Schemaname) + '.' + QUOTENAME(@AuditTableName) +' 
 SELECT ' + @ColList + ',''Old'',''Delete'',host_name(),app_name(),ORIGINAL_LOGIN(),getdate()  FROM DELETED

END
' 
 
IF @GenerateScriptOnly = 1 
BEGIN 
    PRINT REPLICATE ('-',200) 
    PRINT '--Create Script Delete Trigger for ' + @Schemaname + '.' + @Tablename 
    PRINT REPLICATE ('-',200) 
    PRINT @SQL 
    PRINT 'GO' 
    PRINT @SQLTrigger 
    PRINT 'GO' 
END 
ELSE 
BEGIN 
    PRINT 'Creating Delete Trigger ' + @Tablename + '_AuditDelete  for ' + @Schemaname + '.' + @Tablename 
    EXEC(@SQL) 
    EXEC(@SQLTrigger) 
    PRINT 'Trigger ' + @Schemaname + '.' + @Tablename + '_AuditDelete  Created succefully' 
END 
 
---------------------------------------------------------------------------------------------------------------------- 
-- Create Update Trigger 
---------------------------------------------------------------------------------------------------------------------- 
 
 
SELECT @SQL = ' 
 
IF EXISTS (SELECT 1  
             FROM sys.objects  
            WHERE Name=''' + @Tablename + '_AuditUpdate' + ''' 
              AND Schema_id=Schema_id(''' + @Schemaname + ''') 
              AND Type = ''TR'') 
DROP TRIGGER [' + @Tablename + '_AuditUpdate] 
' 
 
SELECT @SQLTrigger = 
' 
CREATE TRIGGER [' + @Tablename + '_AuditUpdate] 
ON '+ QUOTENAME(@Schemaname) + '.' + QUOTENAME(@Tablename) + ' 
WITH EXECUTE AS ''dmladmin''
FOR UPDATE 
NOT FOR REPLICATION 
AS 
 BEGIN
	SET NOCOUNT ON;

 INSERT INTO ' + QUOTENAME(@AuditDBname) + '.' + QUOTENAME(@Schemaname) + '.' + QUOTENAME(@AuditTableName) +'  
 SELECT ' + @ColList + ',''New'',''Update'',host_name(),app_name(),ORIGINAL_LOGIN(),getdate()  FROM INSERTED  
 
 INSERT INTO ' + QUOTENAME(@AuditDBname) + '.' + QUOTENAME(@Schemaname) + '.' + QUOTENAME(@AuditTableName) +' 
 SELECT ' + @ColList + ',''Old'',''Update'',host_name(),app_name(),ORIGINAL_LOGIN(),getdate()  FROM DELETED 
 
END
 ' 
 
IF @GenerateScriptOnly = 1 
BEGIN 
    PRINT REPLICATE ('-',200) 
    PRINT '--Create Script Update Trigger for ' + @Schemaname + '.' + @Tablename 
    PRINT REPLICATE ('-',200) 
    PRINT @SQL 
    PRINT 'GO' 
    PRINT @SQLTrigger 
    PRINT 'GO' 
END 
ELSE 
BEGIN 
    PRINT 'Creating Delete Trigger ' + @Tablename + '_AuditUpdate  for ' + @Schemaname + '.' + @Tablename 
    EXEC(@SQL) 
    EXEC(@SQLTrigger) 
    PRINT 'Trigger ' + @Schemaname + '.' + @Tablename + '_AuditUpdate  Created successfully' 
END 
 

END



GO


