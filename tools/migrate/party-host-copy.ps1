# party-host-copy.ps1 : the PARTY FALLBACK. A frozen copy of the game on the MAIN PC, served on localhost:8802, so the party on Fri 10/30 needs
# NOTHING from the VM (no relay, no VM running, no network once the copy is prepared). It never touches C:\claudecode\dark raiders.
#
# Run in a NORMAL PowerShell window (no administrator):
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\party-host-copy.ps1" -Status
#   -Prepare        download (first time) or update (later) the copy in C:\claudecode\pillagers-party from the public GitHub repository
#                   dbmosser/pillagers. Needs the internet, no login. The default copy is SMALL (only the game file and the two small servers,
#                   taken from the newest commit, a few MB); -Full downloads the whole history (about 800 MB, 5-15 minutes).
#                   Updates are "fast-forward only": the copy only ever moves forward to what GitHub has, and it refuses to overwrite edits.
#   -Ref X          what to prepare. Default origin/master (the newest). A tag (for example  party-v31.90 ), or a full 40-character commit id.
#                   Ask the VM's Claude to push the final version and tell you the tag or commit; after the Thu 10/29 lock this is a good habit.
#   -Start          stop the play relay (if it runs), then serve the copy: the game on 127.0.0.1:8802 and the run-report collector on :8799
#                   (reports go to the copy's own exports folder). Then open  http://localhost:8802/dark_raiders.html  in Chrome as usual
#                   (/stable.html shows the same frozen build). The VM can be off.
#   -Stop           stop those two servers again. Add -RestartRelay to start the play relay again afterwards.
#   -Status         look only: is the copy there, which commit, is it being served (changes nothing)
#   -Dir PATH       where the copy lives (default C:\claudecode\pillagers-party). It must NOT be, or be inside, C:\claudecode\dark raiders.
#   -RepoUrl URL    default https://github.com/dbmosser/pillagers.git (public: no login, no key). Only https://github.com/OWNER/REPO(.git) is accepted.
#   -Port N         the game port (default 8802). The collector always uses 8799, because the game posts its reports to localhost:8799.
#   -NoCollector    do not serve the collector
#   -Force          -Prepare: throw away local edits in the copy / allow a copy that points at another repository / accept a history that is not
#                   a simple fast-forward (hard reset to GitHub).
#   -DryRun         only print what would be done (changes nothing)
#
# SAFETY: it only writes inside -Dir (and its own state file under tools\migrate\state and the log under tools\migrate\logs). -Dir may not be, or
# contain, any Pillagers working folder (C:\claudecode\dark raiders, C:\claudecode\pillagers-codex, the Desktop copy), and -Prepare only updates a
# git folder it made itself (a small marker inside .git); any other git folder given as -Dir is left alone, even with -Force. -Status asks the
# game port a question only while a server of the copy is running. It starts only the
# two small servers of the copy (tools\serve.ps1 with -Root pointing at the copy, tools\collector.ps1 likewise); it never starts a helper, the
# runner or a ship. It refuses to start when 8802 or 8799 is already answering (it will not stop the main PC's own servers; host-stop.ps1 does that).
# While the copy is being served do NOT run host-stop.ps1 or party-stop.ps1: they recognise "tools\serve.ps1" in a command line and would stop it.
# No key, token or password is read or stored. git here needs no login (public repository).
# Exit codes: 0 done, 1 error, 2 refused, 3 needs the internet / git failed.
# ASCII only. Works in Windows PowerShell 5.1 and PowerShell 7.
param(
  [switch]$Prepare,
  [switch]$Start,
  [switch]$Stop,
  [switch]$Status,
  [string]$Ref = 'origin/master',
  [string]$Dir = 'C:\claudecode\pillagers-party',
  [string]$RepoUrl = 'https://github.com/dbmosser/pillagers.git',
  [int]$Port = 8802,
  [switch]$Full,
  [switch]$NoCollector,
  [switch]$RestartRelay,
  [switch]$Force,
  [switch]$DryRun
)
$ErrorActionPreference = 'Continue'
if (-not $PSScriptRoot) { Write-Host 'Please run this from its file, not pasted into a window.'; exit 1 }
$commonPath = Join-Path $PSScriptRoot 'host-common.ps1'
if (-not (Test-Path -LiteralPath $commonPath)) { Write-Host ('host-common.ps1 is missing next to this script: ' + $commonPath); exit 1 }
. $commonPath
Start-MigLog -Name 'party-host-copy'

# git must never ask for a login or open a sign-in window: the repository is public. These two settings last only for this script's process.
$env:GIT_TERMINAL_PROMPT = '0'
$env:GCM_INTERACTIVE = 'never'
$StateFile = Join-Path $script:StateDir 'party-copy.json'
$CollectorPort = 8799
$SparsePatterns = @('/dark_raiders.html', '/tools/serve.ps1', '/tools/collector.ps1')

# ------------------------------------------------------------------ pure helpers (unit-tested without running the script)
function ConvertTo-RefSpec {
  # -Ref text -> @{ Kind = 'branch'|'tag'|'commit'; Name = ... } or $null when the text is not usable
  param([string]$Text)
  $t = ([string]$Text).Trim()
  if (-not $t) { return $null }
  if ($t -match '^(origin/)?(master|main)$') { return @{ Kind = 'branch'; Name = $Matches[2] } }
  if ($t -match '^[0-9a-fA-F]{40}$') { return @{ Kind = 'commit'; Name = $t.ToLowerInvariant() } }
  if ($t -match '^[0-9a-fA-F]{4,39}$') { return $null }       # a short commit id cannot be fetched from GitHub; ask for the full one
  if ($t -match '^[A-Za-z0-9][A-Za-z0-9._/-]{0,100}$' -and $t -notmatch '\.\.' -and $t -notmatch '\.lock$' -and $t -notmatch '/$') { return @{ Kind = 'tag'; Name = $t } }
  return $null
}

function Test-DirAllowed {
  # The copy must live outside the real repository, not be a drive root, and be an absolute path.
  param([string]$Path, [string]$RepoRoot)
  if ([string]::IsNullOrWhiteSpace($Path)) { return 'no folder given' }
  if (-not [System.IO.Path]::IsPathRooted($Path)) { return 'the folder must be a full path (like C:\claudecode\pillagers-party)' }
  try { $full = [System.IO.Path]::GetFullPath($Path).TrimEnd('\', '/') } catch { return 'the folder path is not valid' }
  $repo = [System.IO.Path]::GetFullPath($RepoRoot).TrimEnd('\', '/')
  if ($full.Length -le 3) { return 'a whole drive is not allowed' }
  if ($full -ieq $repo) { return 'that is the real Pillagers folder; the copy must be somewhere else' }
  if ($full.StartsWith($repo + '\', [System.StringComparison]::OrdinalIgnoreCase)) { return 'the copy must not be inside the real Pillagers folder' }
  if ($repo.StartsWith($full + '\', [System.StringComparison]::OrdinalIgnoreCase)) { return 'the real Pillagers folder would be inside the copy folder' }
  # the other working copies of Pillagers on this PC are never a party copy either (the Codex lane's copy, the old Desktop copy)
  $others = @('C:\claudecode\pillagers-codex')
  if ($env:USERPROFILE) { $others += (Join-Path $env:USERPROFILE 'Desktop\dark raiders') }
  $others += 'C:\Users\User1\Desktop\dark raiders'
  foreach ($o in $others) {
    $oo = $o.TrimEnd('\', '/')
    if ($full -ieq $oo -or $full.StartsWith($oo + '\', [System.StringComparison]::OrdinalIgnoreCase)) { return ('that is another Pillagers working folder (' + $oo + '); the party copy must be a folder of its own') }
    if ($oo.StartsWith($full + '\', [System.StringComparison]::OrdinalIgnoreCase)) { return ('the other Pillagers working folder ' + $oo + ' would be inside the copy folder') }
  }
  if ((Split-Path -Path $full -Leaf) -ieq 'dark raiders') { return 'a folder called "dark raiders" is a Pillagers working folder; choose another name for the copy' }
  return ''
}

function Test-RepoUrlAllowed {
  # The copy is only ever cloned from github.com (public, https, no login in the address). Returns '' when fine, else the reason.
  param([string]$Url)
  $u = ([string]$Url).Trim()
  if (-not $u) { return 'no address given' }
  if ($u -notmatch '^https://github\.com/') { return 'the address must start with https://github.com/' }
  if ($u -notmatch '^https://github\.com/[A-Za-z0-9][A-Za-z0-9._-]*/[A-Za-z0-9][A-Za-z0-9._-]*(\.git)?/?$') { return 'the address must look like https://github.com/OWNER/REPO.git' }
  return ''
}

function Get-MarkerPath { return (Join-Path $Dir '.git\pillagers-party-copy.txt') }

function Test-OurCopy {
  # true when the .git folder in -Dir was made by this script's clone (it leaves a small marker inside .git)
  return (Test-Path -LiteralPath (Get-MarkerPath))
}

function Test-SameRepoUrl {
  param([string]$A, [string]$B)
  $n = { param($u) ([string]$u).Trim().TrimEnd('/') -replace '\.git$', '' }
  return ((& $n $A) -ieq (& $n $B))
}

# ------------------------------------------------------------------ small helpers
function Test-PortOpen {
  param([int]$P)
  $c = New-Object System.Net.Sockets.TcpClient
  try {
    $iar = $c.BeginConnect('127.0.0.1', $P, $null, $null)
    return [bool]($iar.AsyncWaitHandle.WaitOne(700) -and $c.Connected)
  } catch { return $false } finally { try { $c.Close() } catch { } }
}

function Invoke-Git {
  # runs git in $Dir (or none), returns @{ Code; Out } with stdout and stderr together; the text goes to the log (secrets masked by Write-Mig)
  param([string[]]$GitArgs, [string]$WorkDir = '', [string[]]$StdinLines = $null)
  $git = Get-GitExe
  $old = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try {
    $argv = @()
    if ($WorkDir) { $argv += @('-C', $WorkDir) }
    $argv += $GitArgs
    if ($StdinLines) { $out = @($StdinLines | & $git @argv 2>&1 | ForEach-Object { [string]$_ }) }
    else { $out = @(& $git @argv 2>&1 | ForEach-Object { [string]$_ }) }
    $code = $LASTEXITCODE
  } finally { $ErrorActionPreference = $old }
  return [pscustomobject]@{ Code = $code; Out = $out }
}

function Write-GitOut {
  param($R, [string]$Level = 'SKIP')
  foreach ($l in @($R.Out | Where-Object { $_ } | Select-Object -Last 8)) { Write-Mig ('    git: ' + $l) $Level }
}

function Test-IsRepo {
  if (-not (Test-Path -LiteralPath (Join-Path $Dir '.git'))) { return $false }
  $r = Invoke-Git @('rev-parse', '--is-inside-work-tree') $Dir
  return ($r.Code -eq 0 -and (($r.Out -join '') -match 'true'))
}

function Get-CopyFacts {
  $f = [ordered]@{ Exists = $false; IsRepo = $false; Head = ''; Subject = ''; Date = ''; Branch = ''; Origin = ''; HtmlBytes = 0; HasServe = $false; HasCollector = $false; Stamp = ''; Dirty = 0 }
  if (-not (Test-Path -LiteralPath $Dir)) { return [pscustomobject]$f }
  $f.Exists = $true
  $html = Join-Path $Dir 'dark_raiders.html'
  if (Test-Path -LiteralPath $html) {
    $f.HtmlBytes = [int64](Get-Item -LiteralPath $html).Length
    try { $m = Select-String -LiteralPath $html -Pattern "var WHATSNEW_VER='([^']+)'" -List | Select-Object -First 1; if ($m) { $f.Stamp = $m.Matches[0].Groups[1].Value } } catch { }
  }
  $f.HasServe = Test-Path -LiteralPath (Join-Path $Dir 'tools\serve.ps1')
  $f.HasCollector = Test-Path -LiteralPath (Join-Path $Dir 'tools\collector.ps1')
  if (Test-IsRepo) {
    $f.IsRepo = $true
    $h = Invoke-Git @('rev-parse', 'HEAD') $Dir; if ($h.Code -eq 0 -and $h.Out.Count -gt 0) { $f.Head = ([string]$h.Out[0]).Trim() }
    $s = Invoke-Git @('log', '-1', '--format=%s') $Dir; if ($s.Code -eq 0 -and $s.Out.Count -gt 0) { $f.Subject = ([string]$s.Out[0]).Trim() }
    $d = Invoke-Git @('log', '-1', '--format=%cd', '--date=format:%Y-%m-%d %H:%M') $Dir; if ($d.Code -eq 0 -and $d.Out.Count -gt 0) { $f.Date = ([string]$d.Out[0]).Trim() }
    $b = Invoke-Git @('rev-parse', '--abbrev-ref', 'HEAD') $Dir; if ($b.Code -eq 0 -and $b.Out.Count -gt 0) { $f.Branch = ([string]$b.Out[0]).Trim() }
    $o = Invoke-Git @('config', '--get', 'remote.origin.url') $Dir; if ($o.Code -eq 0 -and $o.Out.Count -gt 0) { $f.Origin = ([string]$o.Out[0]).Trim() }
    $st = Invoke-Git @('status', '--porcelain', '-uno') $Dir; if ($st.Code -eq 0) { $f.Dirty = @($st.Out | Where-Object { $_ }).Count }
  }
  return [pscustomobject]$f
}

function Test-CopyUsable {
  # the files the servers need are there and the game file is whole
  $facts = Get-CopyFacts
  if (-not $facts.Exists) { return 'the copy folder does not exist yet (run -Prepare)' }
  if ($facts.HtmlBytes -lt 1000000) { return 'dark_raiders.html is missing or too small (run -Prepare)' }
  if (-not $facts.HasServe) { return 'tools\serve.ps1 is missing in the copy (run -Prepare)' }
  if (-not $facts.HasCollector -and -not $NoCollector) { return 'tools\collector.ps1 is missing in the copy (run -Prepare, or use -NoCollector)' }
  try {
    $fs = [System.IO.File]::OpenRead((Join-Path $Dir 'dark_raiders.html'))
    try { $fs.Seek(-512, [System.IO.SeekOrigin]::End) | Out-Null; $buf = New-Object byte[] 512; [void]$fs.Read($buf, 0, 512); $tail = [System.Text.Encoding]::ASCII.GetString($buf) } finally { $fs.Dispose() }
    # the real game file ends  </script> </div>  (it has no </html>); git checks every file it writes, so this is only a last sanity look
    if ($tail -notmatch '</(script|div|body|html)>\s*$') { return 'dark_raiders.html does not end like the game page (a cut-off file): run -Prepare again' }
  } catch { return 'dark_raiders.html could not be read' }
  return ''
}

function Get-RelayProcs {
  # 10-20 evening: on the main PC a FILTERED process query (-Filter "Name='node.exe'") returned nothing while the relay ran (pid 30112 on
  # 8802 and 8799), so -Start refused the busy port and -Status said 'not running'; host-verify, which lists every process and filters
  # afterwards, saw it. Every process is listed here too, then filtered.
  return @(Get-CimInstance -ClassName Win32_Process -ErrorAction SilentlyContinue |
      Where-Object { ([string]$_.Name -match '(?i)^node(\.exe)?$') -and $_.CommandLine -and ($_.CommandLine -match 'play-relay\.mjs') -and ($_.CommandLine -notmatch '--probe|--help|play-relay\.test') })
}

function Get-PartyProcs {
  $rx = [regex]::Escape($Dir.TrimEnd('\', '/')) + '[\\/]+tools[\\/]+(serve|collector)\.ps1'
  return @(Get-CimInstance -ClassName Win32_Process -ErrorAction SilentlyContinue |   # unfiltered, see Get-RelayProcs
      Where-Object { ([string]$_.Name -match '(?i)^(powershell|pwsh)(\.exe)?$') -and $_.CommandLine -and ($_.CommandLine -match $rx) -and ([int]$_.ProcessId -ne [int]$PID) })
}

function Read-PartyState {
  if (-not (Test-Path -LiteralPath $StateFile)) { return $null }
  try { return (Get-Content -LiteralPath $StateFile -Raw | ConvertFrom-Json) } catch { return $null }
}

function Save-PartyState {
  param([hashtable]$Data)
  if ($DryRun) { return }
  $Data['time'] = (Get-Date).ToString('s')
  Write-AsciiFile -Path $StateFile -Text ($Data | ConvertTo-Json -Depth 4)
}

function Get-ServedLength {
  # asks the server on this PC for the size of dark_raiders.html (HEAD request, Host localhost:<port>); -1 when it does not answer
  param([int]$P)
  try {
    $req = [System.Net.HttpWebRequest]::Create('http://localhost:' + $P + '/dark_raiders.html')
    $req.Method = 'HEAD'
    $req.Timeout = 4000
    $req.ReadWriteTimeout = 4000
    $resp = $req.GetResponse()
    try { return [int64]$resp.ContentLength } finally { $resp.Close() }
  } catch { return [int64]-1 }
}

# ------------------------------------------------------------------ the actions
function Invoke-Prepare {
  Write-Mig '=== PARTY COPY: PREPARE ===' 'STEP'
  if ($DryRun) { Write-Mig '(dry run: nothing will be changed)' 'DRY' }
  $git = Get-GitExe
  if (-not $git) { Write-Mig 'git was not found on this PC.' 'FAIL'; return 3 }
  $why = Test-DirAllowed $Dir $script:RepoRoot
  if ($why) { Write-Mig ('-Dir "' + $Dir + '": ' + $why + '.') 'FAIL'; return 2 }
  $whyUrl = Test-RepoUrlAllowed $RepoUrl
  if ($whyUrl) { Write-Mig ('-RepoUrl "' + $RepoUrl + '": ' + $whyUrl + '.') 'FAIL'; return 2 }
  $spec = ConvertTo-RefSpec $Ref
  if (-not $spec) { Write-Mig ('-Ref "' + $Ref + '" is not usable. Use origin/master, a tag name, or the FULL 40-character commit id (a short id cannot be fetched).') 'FAIL'; return 2 }
  Write-Mig ('Copy folder : ' + $Dir) 'INFO'
  Write-Mig ('From        : ' + $RepoUrl + ' (' + $spec.Kind + ' ' + $spec.Name + ')') 'INFO'
  $freeNeeded = 1GB
  if ($Full) { $freeNeeded = 4GB }
  $free = Get-DriveFreeBytes $Dir
  if ($free -ge 0 -and $free -lt $freeNeeded) { Write-Mig ('Only ' + (Format-Bytes $free) + ' free on that drive; this wants about ' + (Format-Bytes $freeNeeded) + '.') 'FAIL'; return 2 }

  $hasRepo = (Test-Path -LiteralPath (Join-Path $Dir '.git'))
  if (-not $hasRepo) {
    if ((Test-Path -LiteralPath $Dir) -and @(Get-ChildItem -LiteralPath $Dir -Force -ErrorAction SilentlyContinue).Count -gt 0) {
      Write-Mig ('The folder ' + $Dir + ' exists, has files in it, and is not a git copy. It is left alone. Pick another -Dir or empty it yourself.') 'FAIL'; return 2
    }
    if ($DryRun) {
      if ($Full) { Write-Mig ('would run: git clone --no-checkout --single-branch --branch master "' + $RepoUrl + '" "' + $Dir + '"   (the whole history, about 800 MB)') 'DRY' }
      else {
        Write-Mig ('would run: git clone --depth 1 --filter=blob:none --no-checkout --single-branch --branch master "' + $RepoUrl + '" "' + $Dir + '"') 'DRY'
        Write-Mig ('would limit the checkout to: ' + ($SparsePatterns -join ', ')) 'DRY'
      }
      Write-Mig ('would then bring it to ' + $spec.Kind + ' ' + $spec.Name + ' and copy dark_raiders.html to stable.html') 'DRY'
      return 0
    }
    Write-Mig 'Downloading the copy for the first time (the small version takes about a minute; this window must stay open)...' 'INFO'
    $parent = Split-Path -Path $Dir -Parent
    if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    $cloneArgs = @('clone', '--no-checkout', '--single-branch', '--branch', 'master', '--origin', 'origin')
    if (-not $Full) { $cloneArgs += @('--depth', '1', '--filter=blob:none') }
    $r = Invoke-Git ($cloneArgs + @('--', $RepoUrl, $Dir))
    if ($r.Code -ne 0 -and -not $Full) {
      Write-Mig 'The small download did not work; trying again without the partial-download feature (bigger, slower).' 'WARN'
      Write-GitOut $r 'WARN'
      if (Test-Path -LiteralPath $Dir) { Get-ChildItem -LiteralPath $Dir -Force -ErrorAction SilentlyContinue | ForEach-Object { try { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction Stop } catch { } } }
      $r = Invoke-Git @('clone', '--no-checkout', '--single-branch', '--branch', 'master', '--origin', 'origin', '--depth', '1', '--', $RepoUrl, $Dir)
    }
    if ($r.Code -ne 0) {
      Write-Mig 'git could not download the copy. Is the internet on? The last lines git printed:' 'FAIL'
      Write-GitOut $r 'FAIL'
      return 3
    }
    Write-Mig 'Download finished.' 'OK'
    # mark the copy as this script's own, so a later -Prepare never "updates" (and resets) somebody else's git folder that was given as -Dir
    try { Write-AsciiFile -Path (Get-MarkerPath) -Text ('made by party-host-copy.ps1 on ' + (Get-Date).ToString('s') + "`r`n" + 'from ' + $RepoUrl + "`r`n") } catch { Write-Mig ('Could not write the copy marker: ' + $_.Exception.Message) 'WARN' }
    if (-not $Full) {
      $rs = Invoke-Git @('sparse-checkout', 'set', '--no-cone', '--stdin') $Dir $SparsePatterns
      if ($rs.Code -ne 0) { Write-Mig 'Could not limit the checkout to the few files the party needs; the whole tree will be written instead.' 'WARN'; Write-GitOut $rs 'WARN' }
    }
    $rh = Invoke-Git @('reset', '--hard', 'HEAD') $Dir
    if ($rh.Code -ne 0) { Write-Mig 'git could not write the files of the copy.' 'FAIL'; Write-GitOut $rh 'FAIL'; return 3 }
  } else {
    if (-not (Test-IsRepo)) { Write-Mig ($Dir + ' has a .git folder that git cannot read. It is left alone.') 'FAIL'; return 2 }
    if (-not (Test-OurCopy)) {
      Write-Mig ('The folder ' + $Dir + ' already holds a git folder that this script did not make (no party-copy marker inside .git). It is left alone, even with -Force. Pick another -Dir, or delete that folder yourself.') 'FAIL'
      return 2
    }
    $facts = Get-CopyFacts
    if ($facts.Origin -and -not (Test-SameRepoUrl $facts.Origin $RepoUrl)) {
      if (-not $Force) { Write-Mig ('The copy points at ' + $facts.Origin + ', not at ' + $RepoUrl + '. Not touching it (-Force overrides).') 'FAIL'; return 2 }
      Write-Mig 'The copy points at another repository, but -Force was given. Going on.' 'WARN'
    }
    if ($facts.Dirty -gt 0) {
      if (-not $Force) { Write-Mig ('The copy has ' + $facts.Dirty + ' edited file(s). A frozen copy should not be edited, so nothing is overwritten. Use -Force to throw the edits away.') 'FAIL'; return 2 }
      Write-Mig ('The copy has ' + $facts.Dirty + ' edited file(s); -Force was given, so they are thrown away.') 'WARN'
      if (-not $DryRun) { [void](Invoke-Git @('reset', '--hard', 'HEAD') $Dir) }
    }
    if ($DryRun) {
      Write-Mig ('would update the existing copy to ' + $spec.Kind + ' ' + $spec.Name + ' (git fetch, then fast-forward only)') 'DRY'
      return 0
    }
    Write-Mig 'Updating the existing copy ...' 'INFO'
  }

  # bring it to the wanted ref
  switch ($spec.Kind) {
    'branch' {
      $cur = Invoke-Git @('rev-parse', '--abbrev-ref', 'HEAD') $Dir
      $r = Invoke-Git @('fetch', 'origin', $spec.Name) $Dir
      if ($r.Code -ne 0) { Write-Mig 'git could not fetch from GitHub (internet?).' 'FAIL'; Write-GitOut $r 'FAIL'; return 3 }
      if ((($cur.Out -join '').Trim()) -ne $spec.Name) {
        $rc = Invoke-Git @('checkout', $spec.Name) $Dir
        if ($rc.Code -ne 0) { Write-Mig ('git could not switch to the branch ' + $spec.Name + '.') 'FAIL'; Write-GitOut $rc 'FAIL'; return 3 }
      }
      $rm = Invoke-Git @('merge', '--ff-only', ('origin/' + $spec.Name)) $Dir
      if ($rm.Code -ne 0) {
        if ($Force) {
          Write-Mig 'The copy is not a simple step behind GitHub; -Force was given, so it is reset to GitHub.' 'WARN'
          $rr = Invoke-Git @('reset', '--hard', ('origin/' + $spec.Name)) $Dir
          if ($rr.Code -ne 0) { Write-GitOut $rr 'FAIL'; return 3 }
        } else {
          Write-Mig 'The copy cannot be moved forward as a simple fast-forward (GitHub history changed?). Nothing was changed. -Force resets the copy to GitHub.' 'FAIL'
          Write-GitOut $rm 'FAIL'
          return 2
        }
      }
    }
    'tag' {
      $r = Invoke-Git @('fetch', '--depth', '1', 'origin', ('+refs/tags/' + $spec.Name + ':refs/tags/' + $spec.Name)) $Dir
      if ($r.Code -ne 0) { Write-Mig ('git could not fetch the tag "' + $spec.Name + '" (does it exist on GitHub? is the internet on?).') 'FAIL'; Write-GitOut $r 'FAIL'; return 3 }
      $rc = Invoke-Git @('checkout', '--detach', ('refs/tags/' + $spec.Name)) $Dir
      if ($rc.Code -ne 0) { Write-Mig 'git could not switch to that tag.' 'FAIL'; Write-GitOut $rc 'FAIL'; return 3 }
    }
    'commit' {
      $have = Invoke-Git @('cat-file', '-e', ($spec.Name + '^{commit}')) $Dir
      if ($have.Code -ne 0) {
        $r = Invoke-Git @('fetch', '--depth', '1', 'origin', $spec.Name) $Dir
        if ($r.Code -ne 0) { Write-Mig ('git could not fetch the commit ' + $spec.Name + ' (is it on GitHub? is the internet on?).') 'FAIL'; Write-GitOut $r 'FAIL'; return 3 }
      }
      $rc = Invoke-Git @('checkout', '--detach', $spec.Name) $Dir
      if ($rc.Code -ne 0) { Write-Mig 'git could not switch to that commit.' 'FAIL'; Write-GitOut $rc 'FAIL'; return 3 }
    }
  }

  $bad = Test-CopyUsable
  if ($bad) { Write-Mig ('The copy is not usable: ' + $bad) 'FAIL'; return 3 }
  # stable.html is not in git (the main repository ignores it); the party notes name both addresses, so make them the same frozen build
  try { Copy-Item -LiteralPath (Join-Path $Dir 'dark_raiders.html') -Destination (Join-Path $Dir 'stable.html') -Force } catch { Write-Mig ('Could not write stable.html: ' + $_.Exception.Message) 'WARN' }
  $facts = Get-CopyFacts
  Write-Mig ('The copy is ready: commit ' + $facts.Head.Substring(0, [Math]::Min(10, $facts.Head.Length)) + ' "' + $facts.Subject + '" (' + $facts.Date + '), game file ' + (Format-Bytes $facts.HtmlBytes) + '.') 'DONE'
  if ($facts.Stamp) { Write-Mig ('  the game file says what-is-new stamp ' + $facts.Stamp + ' (the commit line above is the reliable version).') 'INFO' }
  $prev = Read-PartyState
  $running = $false
  if ($prev -and $prev.state -eq 'running') { $running = $true }
  Save-PartyState @{ state = $(if ($running) { 'running' } else { 'prepared' }); dir = $Dir; ref = $Ref; head = $facts.Head; port = $Port; pids = $(if ($running) { @($prev.pids) } else { @() }); relayWasRunning = $(if ($prev) { [bool]$prev.relayWasRunning } else { $false }) }
  if ($running) { Write-Mig 'The copy is being served right now; the NEW files are served at once (the server reads the file on every request). Reload the page.' 'INFO' }
  Write-Mig 'Next: -Start on party night (or earlier to rehearse), then open http://localhost:8802/dark_raiders.html in Chrome.' 'INFO'
  return 0
}

function Invoke-StartCopy {
  Write-Mig '=== PARTY COPY: START ===' 'STEP'
  if ($DryRun) { Write-Mig '(dry run: nothing will be changed)' 'DRY' }
  $why = Test-DirAllowed $Dir $script:RepoRoot
  if ($why) { Write-Mig ('-Dir "' + $Dir + '": ' + $why + '.') 'FAIL'; return 2 }
  $bad = Test-CopyUsable
  if ($bad) { Write-Mig ('Cannot start: ' + $bad) 'FAIL'; return 2 }
  $facts = Get-CopyFacts
  $htmlLen = [int64](Get-Item -LiteralPath (Join-Path $Dir 'dark_raiders.html')).Length

  # already serving this copy?
  $mine = Get-PartyProcs
  if ($mine.Count -gt 0 -and (Get-ServedLength $Port) -eq $htmlLen) {
    Write-Mig ('The party copy is already being served on localhost:' + $Port + '. Open http://localhost:' + $Port + '/dark_raiders.html') 'OK'
    return 0
  }
  if ($mine.Count -gt 0) { Write-Mig 'Old servers of the copy are running but do not answer correctly; they are stopped first.' 'WARN' }

  # the play relay must step aside (it holds 8802 and 8799 on the VM's behalf)
  $relayRan = $false
  $rp = Get-RelayProcs
  if ($rp.Count -gt 0) {
    $relayRan = $true
    foreach ($p in $rp) {
      if ($DryRun) { Write-Mig ('would stop the play relay (process ' + $p.ProcessId + ')') 'DRY'; continue }
      try { Stop-Process -Id ([int]$p.ProcessId) -Force -ErrorAction Stop; Write-Mig ('Stopped the play relay (process ' + $p.ProcessId + '); the party copy does not need the VM.') 'OK' }
      catch { Write-Mig ('Could not stop the play relay (process ' + $p.ProcessId + '): ' + $_.Exception.Message) 'FAIL'; return 1 }
    }
    if (-not $DryRun) { $sf = Join-Path $script:StateDir 'play-relay.status.json'; Start-Sleep -Milliseconds 500; if (Test-Path -LiteralPath $sf) { Remove-Item -LiteralPath $sf -Force -ErrorAction SilentlyContinue } }
  }
  if (-not $DryRun) {
    foreach ($p in @($mine)) { try { Stop-Process -Id ([int]$p.ProcessId) -Force -ErrorAction Stop } catch { } }
    if ($mine.Count -gt 0) { Start-Sleep -Milliseconds 800 }
  }
  $ports = @($Port)
  if (-not $NoCollector) { $ports += $CollectorPort }
  if (-not $DryRun) {
    $t0 = Get-Date
    while (((Get-Date) - $t0).TotalSeconds -lt 6) {
      $stillBusy = @($ports | Where-Object { Test-PortOpen $_ })
      if ($stillBusy.Count -eq 0) { break }
      Start-Sleep -Milliseconds 500
    }
  }
  foreach ($p in $ports) {
    if ((-not $DryRun) -and (Test-PortOpen $p)) {
      Write-Mig ('Port ' + $p + ' on this PC is already in use by something else, so the party copy cannot use it. It will not stop it for you.') 'FAIL'
      Write-Mig '  Probably the main PC''s own play server or collector (host-stop.ps1 stops them), or another program. Nothing was started.' 'INFO'
      return 2
    }
  }

  $ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
  $serve = Join-Path $Dir 'tools\serve.ps1'
  $coll = Join-Path $Dir 'tools\collector.ps1'
  $rootArg = '"' + $Dir.TrimEnd('\', '/') + '"'
  $serveLine = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $serve + '" -Root ' + $rootArg + ' -Port ' + $Port
  $collLine = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $coll + '" -Root ' + $rootArg + ' -Port ' + $CollectorPort
  if ($DryRun) {
    foreach ($p in $ports) { if (Test-PortOpen $p) { Write-Mig ('port ' + $p + ' is in use right now: a real -Start would refuse until it is free') 'DRY' } else { Write-Mig ('port ' + $p + ' is free') 'DRY' } }
    Write-Mig ('would start hidden: powershell ' + $serveLine) 'DRY'
    if (-not $NoCollector) { Write-Mig ('would start hidden: powershell ' + $collLine) 'DRY' }
    return 0
  }
  $pids = @()
  try {
    $p1 = Start-Process -FilePath $ps -ArgumentList $serveLine -WindowStyle Hidden -PassThru
    $pids += [int]$p1.Id
    if (-not $NoCollector) { $p2 = Start-Process -FilePath $ps -ArgumentList $collLine -WindowStyle Hidden -PassThru; $pids += [int]$p2.Id }
  } catch { Write-Mig ('Could not start the servers: ' + $_.Exception.Message) 'FAIL'; foreach ($i in $pids) { try { Stop-Process -Id $i -Force -ErrorAction SilentlyContinue } catch { } }; return 1 }

  $ok = $false
  $t0 = Get-Date
  while (((Get-Date) - $t0).TotalSeconds -lt 20) {
    Start-Sleep -Milliseconds 500
    if ((Get-ServedLength $Port) -eq $htmlLen) { $ok = $true; break }
  }
  if (-not $ok) {
    Write-Mig ('The game server did not answer correctly on localhost:' + $Port + ' within 20 seconds. Stopping what was started.') 'FAIL'
    foreach ($i in $pids) { try { Stop-Process -Id $i -Force -ErrorAction SilentlyContinue } catch { } }
    return 1
  }
  Write-Mig ('The party copy is being served: http://localhost:' + $Port + '/dark_raiders.html  (and /stable.html, the same frozen build).') 'DONE'
  Write-Mig ('  commit ' + $facts.Head.Substring(0, [Math]::Min(10, $facts.Head.Length)) + ' "' + $facts.Subject + '" - the game file the server sends is the copy''s own (' + (Format-Bytes $htmlLen) + ').') 'INFO'
  if (-not $NoCollector) {
    if (Test-PortOpen $CollectorPort) { Write-Mig ('  Run reports are collected on localhost:' + $CollectorPort + ' into ' + (Join-Path $Dir 'exports') + '.') 'OK' }
    else { Write-Mig ('  The collector did not start on ' + $CollectorPort + '. The game still plays; run reports would be offered as downloads instead.') 'WARN' }
  }
  Write-Mig '  The VM can be off. Do not run host-stop.ps1 or party-stop.ps1 while this is on (they would stop it).' 'INFO'
  Save-PartyState @{ state = 'running'; dir = $Dir; ref = $Ref; head = $facts.Head; port = $Port; pids = @($pids); relayWasRunning = $relayRan; startedAt = (Get-Date).ToString('s') }
  return 0
}

function Invoke-StopCopy {
  Write-Mig '=== PARTY COPY: STOP ===' 'STEP'
  if ($DryRun) { Write-Mig '(dry run: nothing will be changed)' 'DRY' }
  $procs = Get-PartyProcs
  $st = Read-PartyState
  if ($procs.Count -eq 0) { Write-Mig 'No server of the party copy is running.' 'SKIP' }
  foreach ($p in $procs) {
    if ($DryRun) { Write-Mig ('would stop process ' + $p.ProcessId) 'DRY'; continue }
    try { Stop-Process -Id ([int]$p.ProcessId) -Force -ErrorAction Stop; Write-Mig ('Stopped server process ' + $p.ProcessId + '.') 'OK' }
    catch { Write-Mig ('Could not stop process ' + $p.ProcessId + ': ' + $_.Exception.Message) 'FAIL'; return 1 }
  }
  if (-not $DryRun) {
    $facts = Get-CopyFacts
    Save-PartyState @{ state = 'stopped'; dir = $Dir; ref = $Ref; head = $facts.Head; port = $Port; pids = @(); relayWasRunning = $(if ($st) { [bool]$st.relayWasRunning } else { $false }) }
  }
  $wantRelay = $RestartRelay -or ($st -and $st.relayWasRunning)
  $relayScript = Join-Path $PSScriptRoot 'host-play-relay.ps1'
  if ($RestartRelay) {
    if ($DryRun) { Write-Mig 'would start the play relay again (host-play-relay.ps1 -Start)' 'DRY' }
    else {
      Write-Mig 'Starting the play relay again ...' 'INFO'
      & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $relayScript -Start 2>&1 | ForEach-Object { Write-Host ('    ' + $_) }
    }
  } elseif ($wantRelay) {
    Write-Mig ('The play relay was running before the party copy started. To get the VM route back:  powershell -ExecutionPolicy Bypass -File "' + $relayScript + '" -Start   (or -Stop -RestartRelay next time)') 'INFO'
  }
  return 0
}

function Invoke-StatusCopy {
  Write-Mig '=== PARTY COPY: STATUS (looks only, changes nothing) ===' 'STEP'
  $why = Test-DirAllowed $Dir $script:RepoRoot
  if ($why) { Write-Mig ('-Dir "' + $Dir + '": ' + $why + '.') 'FAIL'; return 2 }
  $facts = Get-CopyFacts
  if (-not $facts.Exists) { Write-Mig ('No copy yet at ' + $Dir + '. Run -Prepare (needs the internet, about a minute).') 'INFO' }
  else {
    if ($facts.IsRepo) {
      Write-Mig ('Copy: ' + $Dir) 'OK'
      Write-Mig ('  commit ' + $facts.Head.Substring(0, [Math]::Min(10, $facts.Head.Length)) + ' "' + $facts.Subject + '" (' + $facts.Date + '), ' + $(if ($facts.Branch -eq 'HEAD') { 'on a fixed tag/commit' } else { 'on branch ' + $facts.Branch }) + '; remote ' + $facts.Origin) 'INFO'
      if ($facts.Dirty -gt 0) { Write-Mig ('  WARNING: ' + $facts.Dirty + ' file(s) edited in the copy') 'WARN' }
    } else { Write-Mig ('Folder ' + $Dir + ' exists but is not a git copy.') 'WARN' }
    $bad = Test-CopyUsable
    if ($bad) { Write-Mig ('  not usable: ' + $bad) 'WARN' } else { Write-Mig ('  ready to serve: dark_raiders.html ' + (Format-Bytes $facts.HtmlBytes) + ', both small servers present') 'OK' }
  }
  $procs = Get-PartyProcs
  # -Status looks only: it asks the port a question only when a server of the copy is running (the copy's own servers are the only thing it may probe)
  $len = [int64]-1
  if ($procs.Count -gt 0) { $len = Get-ServedLength $Port }
  if ($procs.Count -gt 0 -and $facts.HtmlBytes -gt 0 -and $len -eq $facts.HtmlBytes) { Write-Mig ('Serving: yes, http://localhost:' + $Port + '/dark_raiders.html (process ' + (($procs | ForEach-Object { $_.ProcessId }) -join ', ') + ').') 'OK' }
  elseif ($procs.Count -gt 0) { Write-Mig ('Servers of the copy are running (process ' + (($procs | ForEach-Object { $_.ProcessId }) -join ', ') + ') but localhost:' + $Port + ' does not give the copy''s game file.') 'WARN' }
  else {
    Write-Mig 'Serving: no (the party copy is not running).' 'INFO'
    if (Test-PortOpen $Port) { Write-Mig ('  Something else answers on localhost:' + $Port + ' (the play relay, or the main PC''s own server). -Start will refuse until it is stopped, or stops the relay by itself.') 'INFO' }
  }
  if ((Get-RelayProcs).Count -gt 0) { Write-Mig 'The play relay (VM route) is running.' 'INFO' }
  $st = Read-PartyState
  if ($st -and $st.state -eq 'running' -and $procs.Count -eq 0) { Write-Mig 'The state file says running, but the servers are gone (this PC restarted?). -Start serves it again.' 'INFO' }
  return 0
}

# ------------------------------------------------------------------ choose the action
$chosen = @()
if ($Prepare) { $chosen += 'Prepare' }
if ($Start) { $chosen += 'Start' }
if ($Stop) { $chosen += 'Stop' }
if ($Status) { $chosen += 'Status' }
if ($chosen.Count -ne 1) {
  Write-Mig 'Choose exactly one of: -Status, -Prepare, -Start, -Stop. Start with -Status (it changes nothing).' 'WARN'
  Exit-Mig 1
}
$rc = 0
switch ($chosen[0]) {
  'Prepare' { $rc = Invoke-Prepare }
  'Start'   { $rc = Invoke-StartCopy }
  'Stop'    { $rc = Invoke-StopCopy }
  'Status'  { $rc = Invoke-StatusCopy }
}
Exit-Mig $rc
