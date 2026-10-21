# memwatch.ps1 (coordinator 10-21): read-only recorder for the short virtual memory spikes (Windows event 2004 at 05:16 and 05:40:
# the system commit charge hit its 34.2 GB limit while all processes together held about 20 GB, so about 13 GB sat outside any
# process, most likely shared memory, and it was gone a minute later). Every 5 s it reads the commit charge. A line a minute goes
# to the log; when the commit is above -HighGB it writes a snapshot: the top processes, every test browser with its port and
# memory, and every process started in the last 3 minutes. Program names, ports and profile folders only (no command lines).
# Usage: powershell -File tools\memwatch.ps1 [-Minutes 90] [-HighGB 27] [-Out tools\handoff\console\log\memwatch-MMDD.txt]
param([double]$Minutes=90,[double]$HighGB=27,[string]$Out='')
if(-not $Out){ $Out=Join-Path $PSScriptRoot ('handoff\console\log\memwatch-'+(Get-Date -Format MMdd)+'.txt') }
function W([string]$s){ Add-Content -Path $Out -Value $s -Encoding UTF8 }
function Tag($p){ $c=[string]$p.CommandLine; $t=[regex]::Match($c,'--type=([a-z-]+)').Groups[1].Value
  $port=[regex]::Match($c,'remote-debugging-port=(\d+)').Groups[1].Value; $prof=[regex]::Match($c,'user-data-dir="?[^" ]*?([^\\/" ]+)"?(\s|$)').Groups[1].Value
  $f=[regex]::Match($c,'-File\s+"?([^" ]+)').Groups[1].Value; if($f){ $f=Split-Path $f -Leaf }
  (@($t,$(if($port){'port '+$port}),$prof,$f) | Where-Object { $_ }) -join ' ' }
W ("--- memwatch start {0}, {1} min, snapshot above {2} GB committed" -f (Get-Date -Format 'MM-dd HH:mm:ss'),$Minutes,$HighGB)
$end=(Get-Date).AddMinutes($Minutes); $lastMin=''; $lastSnap=[datetime]::MinValue
while((Get-Date) -lt $end){
  $o=Get-CimInstance Win32_OperatingSystem
  $used=($o.TotalVirtualMemorySize-$o.FreeVirtualMemory)/1MB; $lim=$o.TotalVirtualMemorySize/1MB; $ram=$o.FreePhysicalMemory/1MB
  $m=Get-Date -Format 'HH:mm'
  if($m -ne $lastMin){ $lastMin=$m; W ("{0} committed {1:N1} of {2:N1} GB, free RAM {3:N1} GB" -f (Get-Date -Format 'HH:mm:ss'),$used,$lim,$ram) }
  if($used -ge $HighGB -and ((Get-Date)-$lastSnap).TotalSeconds -ge 20){
    $lastSnap=Get-Date; $procs=Get-Process; $priv=($procs | Measure-Object PagedMemorySize64 -Sum).Sum/1GB
    W ("=== SNAPSHOT {0}: committed {1:N1} of {2:N1} GB; processes hold {3:N1} GB, so {4:N1} GB is outside any process" -f (Get-Date -Format 'HH:mm:ss'),$used,$lim,$priv,($used-$priv))
    $cim=@{}; Get-CimInstance Win32_Process | ForEach-Object { $cim[[int]$_.ProcessId]=$_ }
    $procs | Sort-Object PagedMemorySize64 -Descending | Select-Object -First 10 | ForEach-Object {
      W ("  top {0} {1} {2} MB, started {3}, {4}" -f $_.ProcessName,$_.Id,[int]($_.PagedMemorySize64/1MB),$(try{$_.StartTime.ToString('HH:mm:ss')}catch{'?'}),(Tag $cim[[int]$_.Id])) }
    $cim.Values | Where-Object { $_.Name -in 'chrome.exe','msedge.exe' -and ([string]$_.CommandLine) -notmatch '--type=' } | ForEach-Object { $r=$_
      $kids=@($cim.Values | Where-Object { $_.ParentProcessId -eq $r.ProcessId }); $mb=0; foreach($k in @($kids)+$r){ $gp=Get-Process -Id $k.ProcessId -ErrorAction SilentlyContinue; if($gp){ $mb+=$gp.PagedMemorySize64/1MB } }
      W ("  browser {0} {1}, {2} processes, {3} MB" -f $r.ProcessId,(Tag $r),($kids.Count+1),[int]$mb) }
    $recent=(Get-Date).AddMinutes(-3)
    $procs | Where-Object { try{ $_.StartTime -gt $recent }catch{ $false } } | ForEach-Object {
      W ("  new {0} {1} {2} MB, started {3}, {4}" -f $_.ProcessName,$_.Id,[int]($_.PagedMemorySize64/1MB),$_.StartTime.ToString('HH:mm:ss'),(Tag $cim[[int]$_.Id])) }
  }
  Start-Sleep -Seconds 5
}
W ("--- memwatch end {0}" -f (Get-Date -Format 'MM-dd HH:mm:ss'))
