select db_name(dbid) AS DB, count(loginame) AS NoOfConnection, loginame, hostname
from sys.sysprocesses
group by dbid, loginame, hostname
order by NoOfConnection DESC


select count(loginame) AS NoOfConnection, loginame
from sys.sysprocesses
where loginame not in ('NT AUTHORITY\SYSTEM','NT AUTHORITY\NETWORK SERVICE')
group by loginame
order by NoOfConnection DESC
