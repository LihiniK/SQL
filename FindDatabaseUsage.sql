select mf.database_id, d.name, mf.name, mf.size*8/1024 Size_MBs
from sys.master_files mf
join sys.databases d 
ON mf.database_id = d.database_id
order by d.name