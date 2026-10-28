# main-status.ps1 : runs ON THE MAIN PC for the host bridge job "main-status". Read only: it changes nothing and sends no request to 8802.
# One JSON object: the party copy he plays (folder, commit, game version), what serves his 8802 (from the process list), the idle runner
# (heartbeat age, status note, last log lines, last party update output) and the bridge agent itself. ASCII only.
$ErrorActionPreference = 'SilentlyContinue'
$PD = 'C:\claudecode\pillagers-party'
$W = 'C:\PillagersIdle'

function Ver([string]$dir) {
  try { $m = [regex]::Match([IO.File]::ReadAllText((Join-Path $dir 'dark_raiders.html')), "var VER='([0-9]+\.[0-9]+)';"); if ($m.Success) { return $m.Groups[1].Value } } catch {}
  return $null
}
function Tail([string]$file, [int]$n) {
  if (-not (Test-Path -LiteralPath $file)) { return @() }
  return @(Get-Content -LiteralPath $file -Tail $n | ForEach-Object { ([string]$_) -replace '[^\x20-\x7e]', '?' })
}
$procs = @(Get-CimInstance Win32_Process | Where-Object { $_.CommandLine })

# the party copy
$party = [ordered]@{ dir = $PD; exists = (Test-Path -LiteralPath (Join-Path $PD '.git')) }
if ($party.exists) {
  $party.head = ((& git -C $PD rev-parse HEAD) 2>$null | Select-Object -First 1)
  $party.subject = ((& git -C $PD log -1 --format=%s) 2>$null | Select-Object -First 1)
  $party.ver = Ver $PD
  $f = Get-Item -LiteralPath (Join-Path $PD 'dark_raiders.html')
  if ($f) { $party.fileTime = $f.LastWriteTime.ToString('s'); $party.fileBytes = $f.Length }
}

# what serves 8802: the serve.ps1 started with -Port 8802 (or no -Port, its default), else the play relay, else nothing
$play = [ordered]@{ kind = 'nothing' }
$sv = $procs | Where-Object { $_.CommandLine -match 'serve\.ps1' -and (($_.CommandLine -match '-Port\s+"?8802\b') -or ($_.CommandLine -notmatch '-Port\b')) } | Select-Object -First 1
if ($sv) {
  $m = [regex]::Match([string]$sv.CommandLine, '-Root\s+(?:"([^"]+)"|(\S+))')
  $root = $(if ($m.Success) { ($m.Groups[1].Value + $m.Groups[2].Value).TrimEnd('\') } else { 'C:\claudecode\dark raiders' })
  $play = [ordered]@{ kind = 'serve.ps1'; pid = [int]$sv.ProcessId; root = $root; ver = (Ver $root); isPartyCopy = ($root -ieq $PD) }
  # one HEAD request (headers only, as party-host-copy -Status does): does 8802 answer with exactly the file on disk?
  $fb = (Get-Item -LiteralPath (Join-Path $root 'dark_raiders.html')).Length
  try { $rq = [Net.HttpWebRequest]::Create('http://localhost:8802/dark_raiders.html'); $rq.Method = 'HEAD'; $rq.Timeout = 4000; $rs = $rq.GetResponse(); $len = [long]$rs.ContentLength; $rs.Close() } catch { $len = -1 }
  $play.servedBytes = $len; $play.servesFileOnDisk = ($len -gt 0 -and $len -eq $fb)
} elseif ($procs | Where-Object { $_.CommandLine -match 'play-relay\.mjs' }) { $play = [ordered]@{ kind = 'relay to the VM' } }

# the idle runner
$hb = Get-Item -LiteralPath (Join-Path $W 'runner.heartbeat')
$runner = [ordered]@{
  heartbeatAgeSec = $(if ($hb) { [int]((Get-Date) - $hb.LastWriteTime).TotalSeconds } else { $null })
  processes = @($procs | Where-Object { $_.CommandLine -match 'spare-runner\.ps1' }).Count
  status = (Tail (Join-Path $W 'status.txt') 40)
  log = (Tail (Join-Path $W 'runner.log') 30)
  partyRefresh = (Tail (Join-Path $W 'party-refresh.out') 12)
}

# 10-27 his order (via the main PC Claude) "make sure we are always getting game telemetry back from the main pc": the report receiver on
# 8799 (a connect, no request), which collector holds it (from the process list), and when the newest run report and note landed in the
# party copy's exports folder (HH:MM today, else MM-dd HH:MM). The idle runner starts the copy's collector again when 8799 is silent.
function PortUp([int]$p) {
  $c = New-Object Net.Sockets.TcpClient
  try { $a = $c.BeginConnect('127.0.0.1', $p, $null, $null); return [bool]($a.AsyncWaitHandle.WaitOne(700) -and $c.Connected) } catch { return $false } finally { try { $c.Close() } catch {} }
}
function Newest([string]$filter) {
  try {
    $f = Get-ChildItem -LiteralPath (Join-Path $PD 'exports') -Filter $filter -File -ErrorAction Stop | Sort-Object LastWriteTime | Select-Object -Last 1
    if ($f) { $t = $f.LastWriteTime; if ($t.Date -eq (Get-Date).Date) { return $t.ToString('HH:mm') }; return $t.ToString('MM-dd HH:mm') }
  } catch {}
  return 'none'
}
$rcUp = PortUp 8799
$col = $procs | Where-Object { $_.CommandLine -match 'collector\.ps1' } | Select-Object -First 1
$receiver = [ordered]@{ up = $rcUp; lastReport = (Newest 'run-*.txt'); lastNote = (Newest 'feedback-*.txt')
  collectorPid = $(if ($col) { [int]$col.ProcessId } else { $null }); collectorCmd = $(if ($col) { (([string]$col.CommandLine) -replace '\s+', ' ') } else { $null }) }
$receiver.line = 'report receiver 8799 ' + $(if ($rcUp) { 'up' } else { 'down' }) + ', last report ' + $receiver.lastReport + ', last note ' + $receiver.lastNote

# the bridge agent (this request runs under it)
$ag = $procs | Where-Object { $_.CommandLine -match 'host-agent\.mjs' -and $_.CommandLine -notmatch '--status|--once' } | Select-Object -First 1
$bridge = [ordered]@{ agentPid = $(if ($ag) { [int]$ag.ProcessId } else { $null }); agentCmd = $(if ($ag) { (([string]$ag.CommandLine) -replace '\s+', ' ') } else { $null }) }

$os = Get-CimInstance Win32_OperatingSystem
[ordered]@{
  ok = $true; host = $env:COMPUTERNAME; now = (Get-Date).ToString('s')
  freeGB = $(if ($os) { [math]::Round($os.FreePhysicalMemory / 1MB, 1) } else { $null })
  receiver8799 = $receiver; party = $party; play8802 = $play; runner = $runner; bridge = $bridge
} | ConvertTo-Json -Depth 5 -Compress
