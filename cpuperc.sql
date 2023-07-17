-- 5/6/2003 sp - SqlHogs 2.0
-- Modify below to proper number of processors
--   (hyperthreaded and multi-core count so probably just see how many show in task mgr)
-- 2/2/07 sp - Modified to sum for ecids per spid, as opposed to just showing ecit=0
-- Grabs two snapshots from sysperfinfo and presents a delta between them
-- to estimate sql server usage.
Declare @iCpuCount integer
Set @iCpuCount = 4

-- dbcc inputbuffer(spid) - shows the command that was run
-- spid = Sql Server process id.
-- kpid = Windows thread id.  The Thread Id shows the kpid for a given Sql Server thread.
-- blocked = spid of the blocking process.
-- waittime = ms.
-- dbid = database id
-- uid = user id
-- cpu = ms
-- physical io = physical reads and writes
-- memusage = number of pages in proc cache for this spid
-- last_batch = time of last exec or stored proc
-- ecid = identifies subthreads within a spid
Set NoCount On

-- Get the two snapshots, 1 second apart.
-- Exclude user = system.
Select 1 As SnapNum, spid, kpid, blocked, 
    waittime, dbid, uid, cpu, 
    physical_io, memusage, login_time, last_batch,
    ecid, status, hostname, program_name, 
    cmd, net_address, loginame, GetDate() As SnapTime
  Into #SnapShot
  From master..sysprocesses
    Where uid >= 0

WaitFor Delay '00:00:01'

Insert Into #SnapShot
  Select 2 As SnapNum, spid, kpid, blocked, 
    waittime, dbid, uid, cpu, 
    physical_io, memusage, login_time, last_batch,
    ecid, status, hostname, program_name, 
    cmd, net_address, loginame, GetDate() As SnapTime
    From master..sysprocesses
    Where uid >= 0

-- Join the two snapshots, dropping ecid's that were missing from one or the other.
-- Just do the columns that require a delta for performance.
Select 
    S1.spid As S1_spid, S1.ecid As S1_ecid, 
    S1.waittime As S1_waittime, S1.cpu As S1_cpu, 
    S1.physical_io As S1_physical_io, S1.SnapTime As S1_SnapTime,
    S2.waittime As S2_waittime, S2.cpu As S2_cpu, 
    S2.physical_io As S2_physical_io, S2.SnapTime As S2_SnapTime
  Into #SnapBoth
  From #SnapShot As S1 Join #SnapShot As S2
    On S1.spid = S2.spid
      And S1.ecid = S2.ecid
      And S1.SnapNum = 1
      And S2.SnapNum = 2

-- Get the difference between the 2 snapshots, ms per ecid
-- This is ( / 1000 * 100 ).
Select S1_spid As spid, S1_ecid As ecid,
    Sum( S2_waittime - S1_waittime ) As WaitMsPerEcid, 
    Sum( S2_cpu - S1_cpu ) As CpuMsPerEcid, 
    Sum( S2_physical_io - S1_physical_io ) As DeltaIoPerEcid
  Into #PerfDeltaPerEcid
  From #SnapBoth
  Group By S1_spid, S1_ecid

-- And sum those across per spid.
Select spid,
    Sum( WaitMsPerEcid ) As WaitMs, 
    Sum( CpuMsPerEcid ) As CpuMs, 
    Sum( DeltaIoPerEcid ) As DeltaIo
  Into #PerfDelta
  From #PerfDeltaPerEcid
  Group By spid

-- Get the commands.
Declare
  @iSpid integer,
  @sSql            varchar(128)
Create Table #DbccOutput ( spid integer, EventInfo varchar(256) )
Create Table #DbccOutputTemp ( EventType varchar(256), Parameters integer, EventInfo varchar(256))
Declare MyCursor Cursor For
  Select spid 
    From #PerfDelta 
    Group By spid
Open MyCursor
Fetch Next From MyCursor Into @iSpid
While @@Fetch_Status = 0
Begin
  Set @sSql = 'DBCC inputbuffer(' + Convert( varchar(3), @iSpid ) + ')'
  Insert Into #DbccOutputTemp Exec ( @sSql )
  Insert Into #DbccOutput ( spid, EventInfo )
    Select @iSpid As spid, EventInfo From #DbccOutputTemp
  Delete #DbccOutputTemp
  Fetch Next From MyCursor Into @iSpid
End
Close MyCursor
Deallocate MyCursor

-- Show the results for the cpu hogs.
-- cpu conversion is ms to sec and then to percent / cpus.
Set NoCount Off
Select Top 5 Convert( integer, PD.CpuMs * 0.001 * 100.0 / @iCpuCount ) As CpuPercent,
    PD.spid, Convert( varchar(16), SS.loginame ) As UserName, 
    DO.EventInfo As Command,
    Convert( varchar(15), SS.hostname ) As Host, Convert( varchar(15), SS.program_name ) As Program,
    ( Select name From master..sysdatabases Where dbid = SS.dbid ) As Db,
    SS.status, SS.login_time, SS.last_batch,
    PD.DeltaIo, SS.cmd, SS.net_address
  From #PerfDelta As PD Join #SnapShot As SS
      On PD.spid = SS.spid
        And SS.ecid = 0
        And SS.SnapNum = 1
    Left Join #DbccOutput As DO
      On PD.spid = DO.spid
  Where CpuMs > 5
  Order By CpuMs Desc

  Drop Table #DbccOutput
  Drop Table #DbccOutputTemp
  Drop Table #PerfDeltaPerEcid
  Drop Table #PerfDelta
  Drop Table #SnapBoth
  Drop Table #SnapShot