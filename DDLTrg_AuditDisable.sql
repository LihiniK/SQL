
/****** Object:  DdlTrigger [DDLTrg_AuditDisable]    Script Date: 6/29/2018 9:30:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE TRIGGER [DDLTrg_AuditDisable]
    ON DATABASE 
	WITH EXECUTE AS 'dmladmin'
    FOR ALTER_TABLE,ALTER_TRIGGER
AS
BEGIN
    SET NOCOUNT ON;

    declare @mytabletrg Table(sqlquery nvarchar(max));
 
	insert into @mytabletrg
	select EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)');
 
	 if ( select count(*) from @mytabletrg where sqlquery like '%disable%trigger%')> 0
	 rollback;

END




GO

ENABLE TRIGGER [DDLTrg_AuditDisable] ON DATABASE
GO


