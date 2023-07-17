backup log EPAS to disk = 'NUL:' WITH NO_CHECKSUM, CONTINUE_AFTER_ERROR 

use EPAS
dbcc loginfo 

dbcc shrinkfile (EPAS_log, EMPTYFILE) ; 



select * from sys.database_files 

select * from sys.master_files

