select command,percent_complete,total_elapsed_time,estimated_completion_time,start_time from sys.dm_exec_requests
where command in ('RESTORE DATABASE')