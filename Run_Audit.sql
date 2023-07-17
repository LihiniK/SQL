declare @count int, @tbname nvarchar(250), @loop int
declare @mytable Table ( Name nvarchar(250), id int identity(1,1) not null )
insert into @mytable (Name)
select name from sys.objects where type = 'U' and is_ms_shipped = 0
and name not like 'conflict_%' and name not in ('sysdiagrams')
order by name ASC
--select * from @mytable
select @count = count(*) from @mytable
--print @count
set @loop = 1
while @loop < @count + 1
begin
select @tbname = Name from @mytable where id = @loop
print @tbname

exec spGenerateAuditTrgsTblsNew 'dbo',@tbname,'AUDIT_POS_KAT_NEW',0

set @loop = @loop + 1
end

