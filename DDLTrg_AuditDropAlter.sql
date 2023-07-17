
/****** Object:  DdlTrigger [DDLTrg_AuditDropAlter]    Script Date: 6/29/2018 9:31:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE TRIGGER [DDLTrg_AuditDropAlter]
    ON DATABASE 
	WITH EXECUTE AS 'dmladmin'
    FOR DROP_TRIGGER,ALTER_TRIGGER
AS
BEGIN
    SET NOCOUNT ON;


	 rollback;

END



GO

ENABLE TRIGGER [DDLTrg_AuditDropAlter] ON DATABASE
GO


