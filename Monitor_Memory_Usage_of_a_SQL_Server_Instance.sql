/*============================================================================
   Script to report Memory usage details of a SQL Server instance
   Author: Sakthivel Chidambaram, Microsoft http://blogs.msdn.com/b/sqlsakthi 

   Date: June 2012
   Version: V2
   
   V1: Initial Release
   V2: Added PLE, Memory grants pending, Checkpoint, Lazy write,Free list counters

   THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
   ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
   TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
   PARTICULAR PURPOSE. 

============================================================================*/ 
-- We don't need the row count
SET NOCOUNT ON

-- Get size of SQL Server Page in bytes
DECLARE @pg_size INT, @Instancename varchar(50) 
SELECT @pg_size = low from master..spt_values where number = 1 and type = 'E' 

-- Extract perfmon counters to a temporary table
IF OBJECT_ID('tempdb..#perfmon_counters') is not null DROP TABLE #perfmon_counters
SELECT * INTO #perfmon_counters FROM sys.dm_os_performance_counters

-- Get SQL Server instance name
SELECT @Instancename = LEFT([object_name], (CHARINDEX(':',[object_name]))) FROM #perfmon_counters WHERE counter_name = 'Buffer cache hit ratio' 

-- Print Memory usage details
PRINT '----------------------------------------------------------------------------------------------------' 
PRINT 'Memory usage details for SQL Server instance ' + @@SERVERNAME + ' (' + CAST(SERVERPROPERTY('productversion') AS VARCHAR) + ' - ' + SUBSTRING(@@VERSION, CHARINDEX('X',@@VERSION),4) + ' - ' + CAST(SERVERPROPERTY('edition') AS VARCHAR) + ')' 
PRINT '----------------------------------------------------------------------------------------------------' 
SELECT 'Memory visible to the Operating System' 
SELECT CEILING(physical_memory_in_bytes/1048576.0) as [Physical Memory_MB], CEILING(physical_memory_in_bytes/1073741824.0) as [Physical Memory_GB], CEILING(virtual_memory_in_bytes/1073741824.0) as [Virtual Memory GB] FROM sys.dm_os_sys_info 
SELECT 'Buffer Pool Usage at the Moment' 
SELECT (bpool_committed*8)/1024.0 as BPool_Committed_MB, (bpool_commit_target*8)/1024.0 as BPool_Commit_Tgt_MB,(bpool_visible*8)/1024.0 as BPool_Visible_MB FROM sys.dm_os_sys_info 
SELECT 'Total Memory used by SQL Server Buffer Pool as reported by Perfmon counters' 
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM #perfmon_counters WHERE counter_name = 'Total Server Memory (KB)' 
SELECT 'Memory needed as per current Workload for SQL Server instance' 
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM #perfmon_counters WHERE counter_name = 'Target Server Memory (KB)' 
SELECT 'Total amount of dynamic memory the server is using for maintaining connections' 
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM #perfmon_counters WHERE counter_name = 'Connection Memory (KB)' 
SELECT 'Total amount of dynamic memory the server is using for locks' 
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM #perfmon_counters WHERE counter_name = 'Lock Memory (KB)' 
SELECT 'Total amount of dynamic memory the server is using for the dynamic SQL cache' 
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM #perfmon_counters WHERE counter_name = 'SQL Cache Memory (KB)' 
SELECT 'Total amount of dynamic memory the server is using for query optimization' 
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM #perfmon_counters WHERE counter_name = 'Optimizer Memory (KB) ' 
SELECT 'Total amount of dynamic memory used for hash, sort and create index operations.' 
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM #perfmon_counters WHERE counter_name = 'Granted Workspace Memory (KB) ' 
SELECT 'Total Amount of memory consumed by cursors' 
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM #perfmon_counters WHERE counter_name = 'Cursor memory usage' and instance_name = '_Total' 
SELECT 'Number of pages in the buffer pool (includes database, free, and stolen).' 
SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB FROM #perfmon_counters WHERE object_name= @Instancename+'Buffer Manager' and counter_name = 'Total pages' 
SELECT 'Number of Data pages in the buffer pool' 
SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Database pages' 
SELECT 'Number of Free pages in the buffer pool' 
SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Free pages' 
SELECT 'Number of Reserved pages in the buffer pool' 
SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Reserved pages' 
SELECT 'Number of Stolen pages in the buffer pool' 
SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Stolen pages' 
SELECT 'Number of Plan Cache pages in the buffer pool' 
SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB FROM #perfmon_counters WHERE object_name=@Instancename+'Plan Cache' and counter_name = 'Cache Pages' and instance_name = '_Total'
SELECT 'Page Life Expectancy - Number of seconds a page will stay in the buffer pool without references' 
SELECT cntr_value as [Page Life in seconds],CASE WHEN (cntr_value > 300) THEN 'PLE is Healthy' ELSE 'PLE is not Healthy' END as 'PLE Status'  FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Page life expectancy'
SELECT 'Number of requests per second that had to wait for a free page' 
SELECT cntr_value as [Free list stalls/sec] FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Free list stalls/sec'
SELECT 'Number of pages flushed to disk/sec by a checkpoint or other operation that require all dirty pages to be flushed' 
SELECT cntr_value as [Checkpoint pages/sec] FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Checkpoint pages/sec'
SELECT 'Number of buffers written per second by the buffer manager"s lazy writer'
SELECT cntr_value as [Lazy writes/sec] FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Lazy writes/sec'
SELECT 'Total number of processes waiting for a workspace memory grant'
SELECT cntr_value as [Memory Grants Pending] FROM #perfmon_counters WHERE object_name=@Instancename+'Memory Manager' and counter_name = 'Memory Grants Pending'
SELECT 'Total number of processes that have successfully acquired a workspace memory grant'
SELECT cntr_value as [Memory Grants Outstanding] FROM #perfmon_counters WHERE object_name=@Instancename+'Memory Manager' and counter_name = 'Memory Grants Outstanding'


select *
from sys.dm_os_process_memory


DECLARE @mgcounter INT
SET @mgcounter = 1
WHILE @mgcounter <= 5 -- return data from dmv 5 times when there is data
BEGIN
    IF (SELECT COUNT(*)
      FROM sys.dm_exec_query_memory_grants) > 0
    BEGIN
             SELECT *
             FROM sys.dm_exec_query_memory_grants mg
                         CROSS APPLY sys.dm_exec_sql_text(mg.sql_handle) -- shows query text
             -- WAITFOR DELAY '00:00:01' -- add a delay if you see the exact same query in results
             SET @mgcounter = @mgcounter + 1
    END
END





-- Note: querying sys.dm_os_buffer_descriptors
-- requires the VIEW_SERVER_STATE permission.

DECLARE @total_buffer INT;

SELECT @total_buffer = cntr_value
   FROM sys.dm_os_performance_counters 
   WHERE RTRIM([object_name]) LIKE '%Buffer Manager'
   AND counter_name = 'Total Pages';

;WITH src AS
(
   SELECT 
       database_id, db_buffer_pages = COUNT_BIG(*)
       FROM sys.dm_os_buffer_descriptors
       --WHERE database_id BETWEEN 5 AND 32766
       GROUP BY database_id
)
SELECT
   [db_name] = CASE [database_id] WHEN 32767 
       THEN 'Resource DB' 
       ELSE DB_NAME([database_id]) END,
   db_buffer_pages,
   db_buffer_MB = db_buffer_pages / 128,
   db_buffer_percent = CONVERT(DECIMAL(6,3), 
       db_buffer_pages * 100.0 / @total_buffer)
FROM src
ORDER BY db_buffer_MB DESC;






USE SQLSentry;
GO

;WITH src AS
(
   SELECT
       [Object] = o.name,
       [Type] = o.type_desc,
       [Index] = COALESCE(i.name, ''),
       [Index_Type] = i.type_desc,
       p.[object_id],
       p.index_id,
       au.allocation_unit_id
   FROM
       sys.partitions AS p
   INNER JOIN
       sys.allocation_units AS au
       ON p.hobt_id = au.container_id
   INNER JOIN
       sys.objects AS o
       ON p.[object_id] = o.[object_id]
   INNER JOIN
       sys.indexes AS i
       ON o.[object_id] = i.[object_id]
       AND p.index_id = i.index_id
   WHERE
       au.[type] IN (1,2,3)
       AND o.is_ms_shipped = 0
)
SELECT
   src.[Object],
   src.[Type],
   src.[Index],
   src.Index_Type,
   buffer_pages = COUNT_BIG(b.page_id),
   buffer_mb = COUNT_BIG(b.page_id) / 128
FROM
   src
INNER JOIN
   sys.dm_os_buffer_descriptors AS b
   ON src.allocation_unit_id = b.allocation_unit_id
WHERE
   b.database_id = DB_ID()
GROUP BY
   src.[Object],
   src.[Type],
   src.[Index],
   src.Index_Type
ORDER BY
   buffer_pages DESC;