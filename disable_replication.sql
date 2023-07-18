-- Connect Subscriber
:connect TestSubSQL1
use [master]
exec sp_helpreplicationdboption @dbname = N'SLAFTIMEATTENDANCE'
go
use [SLAFTIMEATTENDANCE]
exec sp_subscription_cleanup @publisher = N'FP-MGR-01', @publisher_db = N'SLAFTIMEATTENDANCE', 
@publication = N''
go
-- Connect Publisher Server
:connect TestPubSQL1
-- Drop Subscription
use [SLAFTIMEATTENDANCE]
exec sp_dropsubscription @subscriber = N'all', 
@destination_db = N'SLAFTIMEATTENDANCE', @article = N'all'
go
-- Drop publication
exec sp_droppublication @publication = N'SLAFTIMEATTENDANCE'
-- Disable replication db option
exec sp_replicationdboption @dbname = N'CENTIMETRACKERNEW', @optname = N'publish', @value = N'false'
GO

sp_removedbreplication 'SLAFTIMEATTENDANCE'
go
