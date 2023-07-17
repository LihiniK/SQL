USE [EPAS]
GO
declare @aa int, @bb int, @artname nvarchar(250), @artpub nvarchar(100), @artsubs nvarchar(100)
declare @mytable table(name nvarchar(250), publisher nvarchar(100), subscriber_server nvarchar(100), myid int identity(1,1) not null)
insert into @mytable
select art.name, pub.publisher, sub.subscriber_server from sysmergearticles art
join sysmergepublications pub on art.pubid = pub.pubid
join sysmergesubscriptions sub on art.pubid = sub.pubid
where pub.publisher <> sub.subscriber_server and sub.subscriber_server <> 'APPTEMPKTN'
order by pub.publisher ASC
--select * from @mytable
set @aa = 1
select @bb = count(*) from @mytable
--print @bb
while @aa < @bb + 1
begin
select @artname = name, @artpub = publisher, @artsubs = subscriber_server from @mytable where myid = @aa
--print @artname+'_________'+@artpub+'_________'+@artsubs
exec spTableDifference @artsubs, @artpub, 'EPAS', 'EPAS', @artname
set @aa = @aa + 1
end
GO
