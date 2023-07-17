use distribution
go
DECLARE @MyTable Table
(
id int IDENTITY(1,1) NOT NULL,
agent_id int,
id_name nvarchar(100),
start_time datetime,
comments nvarchar(max)
)

insert into @MyTable
(agent_id, start_time)
select agent_id, max(start_time) as start_time from MSdistribution_history
group by agent_id

--select * from MSdistribution_agents
--select * from @MyTable

declare @aa int, @ab int, @gent_id int, @tart_time datetime, @omments nvarchar(max), @ag_name nvarchar(100)
	set @aa = 1
	
set @ab = (select count(*) from MSdistribution_agents)
while @aa < @ab + 1
begin
	select @gent_id = agent_id, @tart_time = start_time
	from @MyTable
	where id = @aa

	select @omments = comments
	from MSdistribution_history
	where agent_id = @gent_id and start_time = @tart_time

	select @ag_name = name
	from MSdistribution_agents
	where id = @gent_id

	UPDATE @MyTable
	SET comments = @omments,
		id_name = @ag_name
	WHERE id = @aa

	SET @aa = @aa + 1
end

select * from @MyTable where comments 
like '%Executed as user: NT AUTHORITY\SYSTEM. The step succeeded%'
order by start_time
