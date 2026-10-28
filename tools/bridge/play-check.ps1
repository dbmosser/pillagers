# play-check.ps1 : runs ON THE MAIN PC for the host bridge job "play-check". Read only: two GET requests to his 8802 (the game page and
# /stable.html), nothing else. 10-27: what the main PC Claude did by hand to prove a build reached him, so the VM can do it with no Claude
# open there. For each page: the HTTP status, Cache-Control, size, SHA256 and game version of what 8802 SENDS, the same of the file on disk
# in the folder the 8802 server serves, and whether they match. The title label he reads is v0.(major*100+minor-2370). ASCII only.
$ErrorActionPreference = 'SilentlyContinue'
$PD = 'C:\claudecode\pillagers-party'

function Sha([byte[]]$b) { $h = [Security.Cryptography.SHA256]::Create(); try { return (($h.ComputeHash($b) | ForEach-Object { $_.ToString('x2') }) -join '') } finally { $h.Dispose() } }
function Facts([string]$text) {
  $v = [regex]::Match($text, "var VER='([0-9]+)\.([0-9]+)';")
  $w = [regex]::Match($text, "WHATSNEW_VER\s*=\s*'([0-9.]+)'")
  $o = [ordered]@{ ver = $null; titleLabel = $null; whatsNew = $(if ($w.Success) { $w.Groups[1].Value } else { $null }) }
  if ($v.Success) { $o.ver = $v.Groups[1].Value + '.' + $v.Groups[2].Value; $o.titleLabel = 'v0.' + ([int]$v.Groups[1].Value * 100 + [int]$v.Groups[2].Value - 2370) }
  return $o
}

# the folder his 8802 serves: the -Root of the serve.ps1 on 8802 (process list), else the party copy
$root = $PD
$sv = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'serve\.ps1' -and (($_.CommandLine -match '-Port\s+"?8802\b') -or ($_.CommandLine -notmatch '-Port\b')) } | Select-Object -First 1
if ($sv) { $m = [regex]::Match([string]$sv.CommandLine, '-Root\s+(?:"([^"]+)"|(\S+))'); if ($m.Success) { $root = ($m.Groups[1].Value + $m.Groups[2].Value).TrimEnd('\') } else { $root = 'C:\claudecode\dark raiders' } }

$pages = [ordered]@{}
foreach ($name in @('dark_raiders.html', 'stable.html')) {
  $p = [ordered]@{ url = 'http://localhost:8802/' + $name }
  try {
    $rq = [Net.HttpWebRequest]::Create($p.url); $rq.Method = 'GET'; $rq.Timeout = 20000; $rq.ReadWriteTimeout = 20000
    $rs = $rq.GetResponse(); $p.status = [int]$rs.StatusCode; $p.cacheControl = $rs.Headers['Cache-Control']
    $ms = New-Object IO.MemoryStream; $rs.GetResponseStream().CopyTo($ms); $rs.Close(); $b = $ms.ToArray()
    $p.servedBytes = $b.Length; $p.servedSha256 = Sha $b; $p.served = Facts ([Text.Encoding]::UTF8.GetString($b))
  } catch { $p.status = -1; $p.error = ([string]$_.Exception.Message) -replace '[^\x20-\x7e]', '?' }
  $f = Join-Path $root $name
  if (Test-Path -LiteralPath $f) {
    $d = [IO.File]::ReadAllBytes($f)
    $p.diskFile = $f; $p.diskBytes = $d.Length; $p.diskSha256 = Sha $d; $p.diskTime = (Get-Item -LiteralPath $f).LastWriteTime.ToString('s')
    $p.disk = Facts ([Text.Encoding]::UTF8.GetString($d))
  } else { $p.diskFile = $f + ' (missing)' }
  $p.match = [bool]($p.servedSha256 -and $p.diskSha256 -and $p.servedSha256 -eq $p.diskSha256)
  $pages[$name] = $p
}

$head = $null; if (Test-Path -LiteralPath (Join-Path $root '.git')) { $head = ((& git -C $root log -1 --format='%h %s') 2>$null | Select-Object -First 1) }
[ordered]@{
  ok = [bool]($pages['dark_raiders.html'].match); host = $env:COMPUTERNAME; now = (Get-Date).ToString('s')
  root = $root; rootCommit = $head; serverPid = $(if ($sv) { [int]$sv.ProcessId } else { $null })
  pages = $pages
} | ConvertTo-Json -Depth 5 -Compress
