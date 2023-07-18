select name from sys.all_columns where object_id IN (select object_id from sys.all_objects where name = 'personal')

select sys.all_columns.name, sys.all_objects.name
from sys.all_columns
inner join sys.all_objects
on sys.all_columns.object_id = sys.all_objects.object_id 
where sys.all_objects.type_desc = 'USER_TABLE'
and sys.all_objects.is_ms_shipped = 0