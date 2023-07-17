use [EPAS]
go
exec sp_spaceused 'table'
go


-----------whole database---------------
use [EPAS]
go
exec sp_msforeachtable 'exec sp_spaceused [?]'
go