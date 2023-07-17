DECLARE @MynewTable Table 
(pubname nvarchar(200), name nvarchar(200), dest_db nvarchar(30), srvname nvarchar(30))

DECLARE @FirstDiffTables as table (
	id int identity(1,1),
    publisher_svr nvarchar(20),
	publication nvarchar(200),
    publisher_db nvarchar(20),
	name nvarchar(500),
	dest_db nvarchar(20),
	srvname nvarchar(50))

insert into @MynewTable (pubname, name, dest_db, srvname)
select c.name AS pubname, b.name, a.dest_db, a.srvname
from DBHQ.EPAS.dbo.syssubscriptions a
inner join DBHQ.EPAS.dbo.sysarticles b 
		on a.artid = b.artid
inner join DBHQ.EPAS.dbo.syspublications c
		on b.pubid = c.pubid
where a.dest_db != 'virtual'
union
select c.name AS pubname, b.name, a.dest_db, a.srvname
from DBHQ.HRMS.dbo.syssubscriptions a
inner join DBHQ.HRMS.dbo.sysarticles b 
		on a.artid = b.artid
inner join DBHQ.HRMS.dbo.syspublications c
		on b.pubid = c.pubid
where a.dest_db != 'virtual'
union
select c.name AS pubname, b.name, a.dest_db, a.srvname
from DBHQ.GERMS2013.dbo.syssubscriptions a
inner join DBHQ.GERMS2013.dbo.sysarticles b 
		on a.artid = b.artid
inner join DBHQ.GERMS2013.dbo.syspublications c
		on b.pubid = c.pubid
where a.dest_db != 'virtual'

--select * from @MynewTable
--select * from distribution.dbo.MSpublications
DELETE FROM [NEW_1].[dbo].[Tbl_Diff_Dbhq]

INSERT INTO [NEW_1].[dbo].[Tbl_Diff_Dbhq]([publisher_svr],[publication],[publisher_db],[name],[dest_db],[srvname])
select 'DBHQ' AS publisher_svr, b.publication, b.publisher_db, a.name, a.dest_db, a.srvname
from @MynewTable a
inner join DBHQ.distribution.dbo.MSpublications b
		on a.pubname = b.publication


insert into @FirstDiffTables (publisher_svr, publication, publisher_db, name, dest_db, srvname)
select 'DBHQ' AS publisher_svr, b.publication, b.publisher_db, a.name, a.dest_db, a.srvname
from @MynewTable a
inner join DBHQ.distribution.dbo.MSpublications b
		on a.pubname = b.publication

select * from [NEW_1].[dbo].[Tbl_Diff_Dbhq]
