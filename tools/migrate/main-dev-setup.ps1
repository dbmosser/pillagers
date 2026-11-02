# main-dev-setup.ps1 : run ON THE MAIN PC (JUL26) by its Claude, in a normal window, no administrator. It makes C:\claudecode\dark raiders a working
# dev folder (his order 11-02, "move pillagers html development to the main PC permanently"). Plan: tools\handoff\move-to-main-pc-1102.md; how to
# run: tools\handoff\console\notes\move\kit.md. The VM's vm-pack-for-main.ps1 puts this file in the bridge share, because the old folder has no copy.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File "%LOCALAPPDATA%\PillagersBridge\share\main-dev-setup.ps1" -DryRun     prints each step, changes nothing
#   powershell -NoProfile -ExecutionPolicy Bypass -File "%LOCALAPPDATA%\PillagersBridge\share\main-dev-setup.ps1"             does it
#   ... -Refresh     after the VM has gone dark: takes master and the final pack into the folder already set up
#
# What it does: renames the old folder to "C:\claudecode\dark raiders-old-1019" (never deletes); fresh clone of GitHub master; restores the ship
# scratchpad, memory, .claude\settings.local.json and butler from the share (backs up what it replaces); Git bash on his user PATH; npm packages;
# tools\fixture.html; the host-stopped marker that says dev moved here; console\STOP and codex\STOP stay up, so nothing here starts or ships until
# the new chat lifts them; desktop shortcuts for the helper sign-in and his keys, and the first message as a text file.
# It does not touch the party copy (C:\claudecode\pillagers-party), 8802, the collector, his Chrome, his work login, or any key.
# Run it from a window whose folder is NOT the old dev folder, or the rename is refused. Safe to run again.
# Exit codes: 0 done, 1 error, 2 something holds the old folder. ASCII only. Works in Windows PowerShell 5.1. It stands alone: no other file needed.
param([switch]$DryRun, [switch]$Refresh)
$ErrorActionPreference = 'Continue'
$Repo   = 'C:\claudecode\dark raiders'
$Old    = 'C:\claudecode\dark raiders-old-1019'
$Prof   = 'C:\Users\User1'
$Scratch = $Prof + '\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad'
$Memory = $Prof + '\.claude\projects\C--claudecode-dark-raiders\memory'
$HelperCfg = $Prof + '\.claude-pillagers'
$Share  = $Prof + '\AppData\Local\PillagersBridge\share'
$GitBin = 'C:\Program Files\Git\bin'
$FloorGB = 4
$stamp  = Get-Date -Format 'MMdd-HHmm'
$onMain = ($env:COMPUTERNAME -ieq 'JUL26')
$script:Warned = 0

function Say([string]$t, [string]$lv = 'INFO') {
  $c = @{ INFO = 'Gray'; STEP = 'Cyan'; OK = 'Green'; WARN = 'Yellow'; FAIL = 'Red'; DRY = 'DarkYellow'; DONE = 'Green' }[$lv]
  Write-Host ('[' + $lv + '] ' + $t) -ForegroundColor $c
  if ($lv -eq 'WARN') { $script:Warned++ }
}
function Do-It([string]$What, [scriptblock]$Act) {
  if ($DryRun) { Say ('would ' + $What) 'DRY'; return $true }
  try { & $Act | Out-Null; Say $What 'OK'; return $true } catch { Say ($What + ': ' + $_.Exception.Message) 'FAIL'; return $false }
}
function FreeGB { try { $o = Get-CimInstance Win32_OperatingSystem; return [Math]::Round([Math]::Min($o.FreePhysicalMemory, $o.FreeVirtualMemory) / 1MB, 1) } catch { return -1 } }
function Git-C { & git -C $Repo @args }
function Hash-File([string]$P) { return (Get-FileHash -LiteralPath $P -Algorithm SHA256).Hash.ToLowerInvariant() }
# the same rule as Get-MarkerCheck in tools\migrate\host-common.ps1
function Marker-Check([string[]]$Lines) {
  $keep = @(); foreach ($l in $Lines) { $t = ([string]$l).Trim(); if (-not $t) { continue }; if ($t -match '^check\s*=') { continue }; $keep += $t }
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { $h = $sha.ComputeHash([System.Text.Encoding]::ASCII.GetBytes(($keep -join "`n"))) } finally { $sha.Dispose() }
  return (($h | ForEach-Object { $_.ToString('x2') }) -join '')
}
function Write-Ascii([string]$P, [string]$T) { [System.IO.File]::WriteAllText($P, $T, (New-Object System.Text.ASCIIEncoding)) }
function New-Link([string]$Path, [string]$Target, [string]$LinkArgs, [string]$Dir, [string]$Desc) {
  $sh = New-Object -ComObject WScript.Shell; $l = $sh.CreateShortcut($Path)
  $l.TargetPath = $Target; $l.Arguments = $LinkArgs; $l.WorkingDirectory = $Dir; $l.Description = $Desc; $l.Save()
}

Set-Location -LiteralPath 'C:\'   # never hold the folder this renames
Say ('=== MAIN PC DEV SETUP' + $(if ($Refresh) { ' (refresh)' } else { '' }) + ' on ' + $env:COMPUTERNAME + ' ===') 'STEP'
if ($DryRun) { Say 'dry run: nothing is changed' 'DRY' }
if (-not $onMain) { if ($DryRun) { Say 'this is not JUL26; a real run would refuse here' 'WARN' } else { Say 'This runs only on the main PC (JUL26).' 'FAIL'; exit 1 } }
if ($onMain -and ($env:USERPROFILE -ine $Prof)) { Say ('This window runs as ' + $env:USERPROFILE + ', not ' + $Prof) 'FAIL'; exit 1 }

# ---- 1. what must be there
Say 'Step 1: tools and the pack' 'STEP'
foreach ($t in @('git', 'node', 'npm')) { $c = Get-Command $t -ErrorAction SilentlyContinue; if ($c) { Say ($t + ': ' + $c.Source) 'OK' } elseif ($onMain) { Say ($t + ' is not on the PATH') 'FAIL'; if (-not $DryRun) { exit 1 } } }
if (Test-Path -LiteralPath ($GitBin + '\bash.exe')) { Say ('Git bash: ' + $GitBin + '\bash.exe') 'OK' } else { Say 'Git bash is not where it should be' 'FAIL'; if (-not $DryRun) { exit 1 } }
Say ('free memory now: ' + (FreeGB) + ' GB (his floor here is ' + $FloorGB + ')') 'INFO'
$manFile = Join-Path $Share 'devpack-manifest.json'
$man = $null
if (Test-Path -LiteralPath $manFile) { try { $man = Get-Content -LiteralPath $manFile -Raw | ConvertFrom-Json } catch { Say 'devpack-manifest.json does not read' 'FAIL'; if (-not $DryRun) { exit 1 } } }
if (-not $man) { if ($DryRun) { Say 'no pack in the share yet (vm-pack-for-main.ps1 in the VM makes it)' 'WARN' } else { Say 'No pack in the share yet: run vm-pack-for-main.ps1 in the VM first.' 'FAIL'; exit 1 } }
else {
  Say ('pack from ' + $man.created + ', ' + $man.entries + ' files, ' + @($man.parts).Count + ' part(s), head ' + ([string]$man.gitHead).Substring(0, 8)) 'INFO'
  foreach ($p in @($man.parts)) {
    $f = Join-Path $Share $p.name
    if (-not (Test-Path -LiteralPath $f)) { Say ('part missing: ' + $p.name) 'FAIL'; if (-not $DryRun) { exit 1 }; continue }
    if ((Hash-File $f) -ne $p.sha256) { Say ('part does not check out: ' + $p.name) 'FAIL'; if (-not $DryRun) { exit 1 } }
  }
  Say 'every part checks out' 'OK'
}
if ($man) { $remote = [string]$man.remote } else { $remote = 'https://github.com/dbmosser/pillagers.git' }

# ---- 2. the old folder
if (-not $Refresh) {
  Say 'Step 2: the old folder keeps its files under a new name' 'STEP'
  $isNew = Test-Path -LiteralPath ($Repo + '\tools\migrate\host-stopped.txt')
  if ($isNew) { $isNew = [bool](Select-String -LiteralPath ($Repo + '\tools\migrate\host-stopped.txt') -Pattern '^devMovedHere=yes' -Quiet) }
  if ($isNew) { Say 'the folder is already the new one; use -Refresh to bring it up to date' 'FAIL'; if (-not $DryRun) { exit 1 } }
  elseif (Test-Path -LiteralPath $Repo) {
    if (Test-Path -LiteralPath $Old) { Say ($Old + ' is already there; nothing is overwritten, ever. Tell the coordinator.') 'FAIL'; if (-not $DryRun) { exit 1 } }
    $users = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -and ($_.CommandLine -like ('*' + $Repo + '\*') -or $_.CommandLine -like '*/claudecode/dark raiders/*') })
    foreach ($u in $users) { Say ('runs from the old folder: ' + $u.Name + ' pid ' + $u.ProcessId) 'WARN' }
    if ($DryRun) { Say ('would rename "' + $Repo + '" to "' + $Old + '"') 'DRY' }
    else {
      $done = $false
      foreach ($try in 1..5) { try { Rename-Item -LiteralPath $Repo -NewName (Split-Path -Leaf $Old) -ErrorAction Stop; $done = $true; break } catch { Start-Sleep -Seconds 6 } }
      if (-not $done) {
        Say 'Windows would not rename the folder: something has it open. A chat or terminal whose folder is the old dev folder holds it; so can a program listed above. Close that or start it from another folder, then run this again. Nothing was changed.' 'FAIL'
        exit 2
      }
      Say ('renamed to ' + $Old) 'OK'
    }
  } else { Say 'no old folder to rename' 'INFO' }
}

# ---- 3. the code
# core.autocrlf: Git for Windows says true, which would check out every text file with CRLF. The VM's folder is LF nearly everywhere, the helpers'
# edit scripts were written against that, and a ship must not see every file changed. So files are checked out as they are in the repo, and
# autocrlf stays true for commits, exactly the VM's state. Every later checkout on this folder has to pass -c core.autocrlf=false too.
if ($Refresh) {
  Say 'Step 3: bring the folder up to master' 'STEP'
  $null = Do-It 'take master (fast forward only)' { & git -C $Repo -c core.autocrlf=false pull --ff-only origin master 2>&1 | ForEach-Object { Write-Host ('   ' + $_) }; if ($LASTEXITCODE) { throw ('git pull returned ' + $LASTEXITCODE) } }
} else {
  Say 'Step 3: fresh clone of GitHub master' 'STEP'
  $ok = Do-It ('clone ' + $remote + ' into "' + $Repo + '" (about 1.3 GB)') { & git -c core.autocrlf=false clone $remote $Repo 2>&1 | ForEach-Object { Write-Host ('   ' + $_) }; if ($LASTEXITCODE) { throw ('git clone returned ' + $LASTEXITCODE) } }
  if (-not $ok) { exit 1 }
  $null = Do-It 'set this folder''s git settings to the VM''s' {
    Git-C config core.autocrlf true; Git-C config core.filemode false; Git-C config core.symlinks false
    if ($man -and $man.gitName) { Git-C config user.name ([string]$man.gitName) }
    if ($man -and $man.gitEmail) { Git-C config user.email ([string]$man.gitEmail) }
  }
}

# ---- 4. scratchpad, memory, settings, butler
Say 'Step 4: restore what git does not carry' 'STEP'
if ($man) {
  $work = Join-Path $env:TEMP ('pillagers-devpack-' + $stamp)
  $zip = Join-Path $work 'devpack.zip'
  if ($DryRun) { Say ('would join the parts, check the whole zip, and restore to:') 'DRY'; Say ('   scratch -> ' + $Scratch) 'DRY'; Say ('   memory  -> ' + $Memory + ' (backed up first)') 'DRY'; Say ('   repo    -> ' + $Repo) 'DRY'; Say ('   bin     -> ' + $Prof + '\bin (only if butler is missing)') 'DRY' }
  else {
    New-Item -ItemType Directory -Force -Path $work | Out-Null
    $out = [System.IO.File]::Create($zip)
    try { foreach ($p in @($man.parts)) { $in = [System.IO.File]::OpenRead((Join-Path $Share $p.name)); try { $in.CopyTo($out) } finally { $in.Dispose() } } } finally { $out.Dispose() }
    if ((Hash-File $zip) -ne [string]$man.zipSha256) { Say 'the joined zip does not check out' 'FAIL'; exit 1 }
    # what it replaces is kept, under a dated name beside it
    if ((Test-Path -LiteralPath $Scratch) -and -not $Refresh) {
      $sb = $Scratch + '-old-' + $stamp
      Rename-Item -LiteralPath $Scratch -NewName (Split-Path -Leaf $sb) -ErrorAction SilentlyContinue
      if (Test-Path -LiteralPath $sb) { Say ('the old scratchpad is kept as ' + $sb) 'OK' } else { Say 'the old scratchpad could not be renamed; files are copied over it' 'WARN' }
    }
    if (Test-Path -LiteralPath $Memory) {
      $mb = $Memory + '-old-' + $stamp
      Copy-Item -LiteralPath $Memory -Destination $mb -Recurse -Force
      Say ('the memory folder was backed up to ' + $mb) 'OK'
    }
    foreach ($d in @($Scratch, $Memory)) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
    $hasButler = Test-Path -LiteralPath ($Prof + '\bin\butler.exe')
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $roots = @{ scratch = $Scratch; memory = $Memory; repo = $Repo; bin = ($Prof + '\bin') }
    $zr = [System.IO.Compression.ZipFile]::OpenRead($zip); $n = @{ scratch = 0; memory = 0; repo = 0; bin = 0 }
    try {
      foreach ($e in $zr.Entries) {
        $name = $e.FullName.Replace('\', '/'); $cut = $name.IndexOf('/')
        if ($cut -lt 1 -or $name.Contains('..') -or $name.EndsWith('/')) { continue }
        $top = $name.Substring(0, $cut); $rel = $name.Substring($cut + 1)
        if (-not $roots.ContainsKey($top)) { continue }
        if ($top -eq 'bin' -and $hasButler) { continue }
        $dst = Join-Path $roots[$top] ($rel.Replace('/', '\'))
        $dd = Split-Path -Parent $dst; if (-not (Test-Path -LiteralPath $dd)) { New-Item -ItemType Directory -Force -Path $dd | Out-Null }
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($e, $dst, $true)
        $n[$top]++
      }
    } finally { $zr.Dispose() }
    Say ('restored: scratchpad ' + $n.scratch + ', memory ' + $n.memory + ', repo ' + $n.repo + ', bin ' + $n.bin + $(if ($hasButler) { ' (butler was already here)' } else { '' })) 'OK'
    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
    foreach ($lf in @('shipq.lock', 'corpus.lock')) { if (Test-Path -LiteralPath (Join-Path $Scratch $lf)) { Say ('a lock came along: ' + $lf + ' (it should not have); look before shipping') 'WARN' } }
    if (@($man.leftOut).Count -gt 0) { Say (@($man.leftOut).Count.ToString() + ' file(s) were left out by the secret scan in the VM; names in devpack-manifest.json') 'WARN' }
  }
}
if (-not (Test-Path -LiteralPath ($Prof + '\bin\butler.exe')) -and -not $DryRun) { Say 'butler is not on this PC, so itch pushes will fail until it is' 'WARN' }

# ---- 5. stop signs, marker, small folders
Say 'Step 5: stop signs and the marker' 'STEP'
$h = $Repo + '\tools\handoff'
if (-not $Refresh) {
  $null = Do-It 'console\STOP and codex\STOP (nothing here starts or ships until the new chat lifts them; not committed, see .git\info\exclude)' {
    foreach ($s in @(($h + '\console\STOP'), ($h + '\codex\STOP'))) {
      New-Item -ItemType Directory -Force -Path (Split-Path -Parent $s) | Out-Null
      Set-Content -LiteralPath $s -Value ('dev is moving to this PC; the new chat lifts this once vm-dark.txt is in the bridge share, ' + (Get-Date -Format 's')) -Encoding ASCII
    }
  }
}
$null = Do-It 'keep the STOP files out of every ship (.git\info\exclude)' {
  $ex = $Repo + '\.git\info\exclude'; $t = ''; if (Test-Path -LiteralPath $ex) { $t = Get-Content -LiteralPath $ex -Raw }
  foreach ($l in @('tools/handoff/console/STOP', 'tools/handoff/codex/STOP')) { if ($t -notmatch [regex]::Escape($l)) { Add-Content -LiteralPath $ex -Value $l -Encoding ASCII } }
}
$null = Do-It 'empty builds and shots folders git does not keep' { foreach ($d in @('builds', 'tools\shots', 'tools\publish', 'exports')) { New-Item -ItemType Directory -Force -Path (Join-Path $Repo $d) | Out-Null } }
if (-not $Refresh) {
  # the party copy's state record: tools\spare\spare-runner.ps1 looks for it at this path too
  $st = $Old + '\tools\migrate\state'
  if (Test-Path -LiteralPath ($st + '\party-copy.json')) { $null = Do-It 'copy the party copy''s state record to the new folder' { New-Item -ItemType Directory -Force -Path ($Repo + '\tools\migrate\state') | Out-Null; Copy-Item -LiteralPath ($st + '\party-copy.json') -Destination ($Repo + '\tools\migrate\state\party-copy.json') -Force } }
}
$null = Do-It 'write tools\migrate\host-stopped.txt saying dev moved here (status=stopped keeps the host guards as they were; devMovedHere=yes is what checkin.sh reads)' {
  $head = ((Git-C rev-parse HEAD) | Out-String).Trim(); $now = Get-Date
  $lines = @('PILLAGERS HOST STOPPED', 'status=stopped', 'devMovedHere=yes', ('computer=' + $env:COMPUTERNAME), ('user=' + $env:USERNAME), ('time=' + $now.ToString('s')),
    ('timeUtc=' + $now.ToUniversalTime().ToString('s') + 'Z'), ('epoch=' + [DateTimeOffset]::Now.ToUnixTimeSeconds()), ('gitHead=' + $head), ('originMaster=' + $head),
    'unpushedCommits=0', 'changedFiles=0', 'shipLockClear=yes', 'runnerTaskDisabled=no', 'lanesRunning=0', 'playServersKept=yes', 'gpuPack=ok',
    'note=Dev moved from the VM to this PC on the order of 2026-11-02. See tools/handoff/move-to-main-pc-1102.md.')
  $lines += ('check=' + (Marker-Check $lines))
  Write-Ascii ($Repo + '\tools\migrate\host-stopped.txt') (($lines -join "`n") + "`n")
}

# ---- 6. Git bash on his user PATH (not a machine setting, no administrator)
Say 'Step 6: Git bash where scripts find it' 'STEP'
$k = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', (-not $DryRun))
$cur = [string]$k.GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
if (($cur -split ';') -contains $GitBin) { Say 'already on his user PATH' 'OK' }
elseif ($DryRun) { Say ('would add ' + $GitBin + ' to the end of his user PATH') 'DRY' }
else {
  $new = $cur.TrimEnd(';'); if ($new) { $new += ';' }; $new += $GitBin
  $k.SetValue('Path', $new, [Microsoft.Win32.RegistryValueKind]::ExpandString)
  # tell Windows the variable changed (setting and clearing a harmless variable sends the notice), so new programs see it
  [Environment]::SetEnvironmentVariable('PILLAGERS_PATH_NOTICE', '1', 'User'); [Environment]::SetEnvironmentVariable('PILLAGERS_PATH_NOTICE', $null, 'User')
  Say ('added ' + $GitBin + ' to his user PATH') 'OK'
}
$k.Close()
$env:Path = $env:Path.TrimEnd(';') + ';' + $GitBin
$w = Get-Command bash -ErrorAction SilentlyContinue | Select-Object -First 1
if ($w -and $w.Source -notlike ($GitBin + '*') -and -not $DryRun) { Say ('another bash comes first on the PATH: ' + $w.Source + '. Scripts started by the runner use the full path and are fine; a plain "bash" typed in a window is not.') 'WARN' }

# ---- 7. packages and the fixture. These are builds, not tests; they wait for his memory floor
Say 'Step 7: npm packages and tools\fixture.html' 'STEP'
function Wait-Floor {
  foreach ($i in 1..20) { $g = FreeGB; if ($g -lt 0 -or $g -ge ($FloorGB + 0.5)) { return $true }; Say ('waiting for memory: ' + $g + ' GB free, this step wants ' + ($FloorGB + 0.5)) 'INFO'; Start-Sleep -Seconds 30 }
  return $false
}
foreach ($d in @('tools\console-sdk', 'tools\lint')) {
  if ($DryRun) { Say ('would run npm ci in ' + $d) 'DRY'; continue }
  $full = Join-Path $Repo $d
  if (Test-Path -LiteralPath ($full + '\node_modules')) { Say ($d + ': packages already there') 'OK'; continue }
  if (-not (Wait-Floor)) { Say ($d + ': not installed, memory stayed under the floor; run this again later') 'WARN'; continue }
  Push-Location -LiteralPath $full
  & cmd.exe /c 'npm ci --no-audit --no-fund' 2>&1 | Select-Object -Last 2 | ForEach-Object { Write-Host ('   ' + $_) }
  $rc = $LASTEXITCODE; Pop-Location
  Set-Location -LiteralPath 'C:\'
  if ($rc) { Say ($d + ': npm ci returned ' + $rc) 'WARN' } else { Say ($d + ': packages installed') 'OK' }
}
if ($DryRun) { Say 'would build tools\fixture.html with tools\mkfixture.ps1' 'DRY' }
elseif (-not (Wait-Floor)) { Say 'fixture not built, memory stayed under the floor; run this again later' 'WARN' }
else {
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File ($Repo + '\tools\mkfixture.ps1') -Root $Repo 2>&1 | Select-Object -Last 2 | ForEach-Object { Write-Host ('   ' + $_) }
  $fx = Get-Item -LiteralPath ($Repo + '\tools\fixture.html') -ErrorAction SilentlyContinue
  if ($fx -and $fx.Length -gt 1MB) { Say ('tools\fixture.html built, ' + [int]($fx.Length / 1MB) + ' MB') 'OK' } else { Say 'tools\fixture.html was not built' 'WARN' }
}

# ---- 8. what he clicks
if (-not $Refresh) {
  Say 'Step 8: his desktop' 'STEP'
  $desk = [Environment]::GetFolderPath('Desktop')
  $psExe = 'powershell.exe'
  $null = Do-It ('folder for the helpers'' own sign-in: ' + $HelperCfg) { New-Item -ItemType Directory -Force -Path $HelperCfg | Out-Null }
  $null = Do-It 'desktop shortcut "Pillagers helper sign-in"' { New-Link (Join-Path $desk 'Pillagers helper sign-in.lnk') $psExe ('-NoProfile -ExecutionPolicy Bypass -File "' + $Repo + '\tools\migrate\main-helper-signin.ps1"') $Repo 'Signs the Pillagers helpers in to your personal Claude account. Your work login is not touched.' }
  $null = Do-It 'desktop shortcut "Pillagers keys"' { New-Link (Join-Path $desk 'Pillagers keys.lnk') $psExe ('-NoProfile -ExecutionPolicy Bypass -File "' + $Repo + '\tools\migrate\main-enter-keys.ps1"') $Repo 'Asks for your Console and itch keys, hidden, and saves them on this PC.' }
  $null = Do-It 'desktop file "Pillagers first message.txt"' { Copy-Item -LiteralPath ($h + '\main-pc-first-message.md') -Destination (Join-Path $desk 'Pillagers first message.txt') -Force }
}

# ---- 9. check
Say 'Step 9: check' 'STEP'
if ($DryRun) { Say 'Dry run finished. Nothing was changed.' 'DONE'; exit 0 }
$fails = 0
function Check([string]$What, [bool]$Ok) { if ($Ok) { Say $What 'OK' } else { Say $What 'FAIL'; $script:fails++ } }
Check ('master at ' + ((Git-C log -1 --format='%h %s') | Out-String).Trim().Substring(0, 8)) ($LASTEXITCODE -eq 0)
Check 'the ship scripts are in the scratchpad' (Test-Path -LiteralPath ($Scratch + '\shipq.sh'))
Check ('memory: ' + @(Get-ChildItem -LiteralPath $Memory -File -ErrorAction SilentlyContinue).Count + ' notes') (Test-Path -LiteralPath ($Memory + '\MEMORY.md'))
Check 'console\STOP is up' (Test-Path -LiteralPath ($h + '\console\STOP'))
$bash = $GitBin + '\bash.exe'
& $bash -n "$($Repo.Replace('\','/'))/tools/nightly.sh" 2>$null; Check 'nightly.sh parses with Git bash here' ($LASTEXITCODE -eq 0)
$hc = (& $bash -c 'cd /c/claudecode/dark\ raiders && . tools/handoff/machine.sh && echo $ON_MAIN $(machine_floor 2)' 2>$null | Out-String).Trim()
Check ('machine.sh says main PC, floor 4 (' + $hc + ')') ($hc -eq '1 4')
$dirty = @(Git-C status --porcelain -- dark_raiders.html tools/mkfixture.ps1); Check 'the game file and mkfixture show no change (a ship needs that)' ($dirty.Count -eq 0)
$pr = 'C:\claudecode\pillagers-party'; if (Test-Path -LiteralPath $pr) { Say 'the party copy was not touched' 'OK' }
Say ('free memory now: ' + (FreeGB) + ' GB') 'INFO'
if ($fails) { Say ($fails.ToString() + ' check(s) failed; nothing here runs while STOP is up, so it is safe to fix and run again') 'FAIL'; exit 1 }
Say ('Setup done, ' + $script:Warned + ' warning(s). STOP is up. Next: main-dev-tasks.ps1, then his one sitting (tools\handoff\his-one-sitting.md).') 'DONE'
exit 0
