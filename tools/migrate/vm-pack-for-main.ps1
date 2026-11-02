# vm-pack-for-main.ps1 : run IN THE VM. Packs what git does not carry for the move to the main PC (his order 11-02) into the bridge share:
# the ship scratchpad, the Claude memory folder, this repo's .claude\settings.local.json and C:\Users\User1\bin (butler for itch).
# These never go through git: the repo is PUBLIC. Plan: tools\handoff\move-to-main-pc-1102.md. How to run: tools\handoff\console\notes\move\kit.md
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\migrate\vm-pack-for-main.ps1 -DryRun     lists and scans, writes nothing but its log
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\migrate\vm-pack-for-main.ps1             packs and puts it in the share
#
# Every file is copied to a private snapshot and the SNAPSHOT is scanned with the secret rules of tools\migrate\host-common.ps1 (the build-pack.ps1
# scan). A file whose name looks like a login file, whose content looks like a key, or that cannot be read is LEFT OUT (fail closed). Only the
# name and the kind of pattern are printed, never the text. Left out on purpose for size: pictures, single files over 2 MB (old copies of
# mkfixture and such), and the ship and test lock files.
# The share takes one file of at most 12 MB, so the zip is cut into parts of 11 MiB; devpack-manifest.json lists each part with its SHA-256.
# main-dev-setup.ps1 and main-dev-tasks.ps1 go along in the share, because the main PC's old folder does not have them yet.
# Exit codes: 0 done, 1 error. ASCII only. Works in Windows PowerShell 5.1.
param([switch]$DryRun, [int]$MaxFileMB = 2)
$ErrorActionPreference = 'Continue'
if ($env:COMPUTERNAME -ieq 'JUL26') { Write-Host 'This one runs in the VM, not on the main PC.'; exit 1 }
. (Join-Path $PSScriptRoot 'host-common.ps1')
Start-MigLog -Name 'vm-pack-for-main'
try { (Get-Process -Id $PID).PriorityClass = 'BelowNormal' } catch { }   # the VM has under 1 GB free; stay out of the way

$repo    = $script:RepoRoot
$hostctl = Join-Path $repo 'tools\bridge\hostctl.mjs'
$memDir  = Join-Path $env:USERPROFILE '.claude\projects\C--claudecode-dark-raiders\memory'
$binDir  = 'C:\Users\User1\bin'
$work    = Join-Path $env:TEMP 'pillagers-devpack'
$zipTmp  = Join-Path $work 'devpack.zip'
$snap    = Join-Path $work 'current.snap'
$partSize = 11534336   # 11 MiB: base64 of it fits the bridge's 16 MiB request cap, and it is under its 12 MB file cap
$noPics  = @('.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.ico', '.mp4')
$binExt  = @('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.ico', '.bin', '.zip', '.exe', '.dll', '.webp', '.woff2')
$lockRx  = '(^|[\\/])(shipq\.lock|shipq\.owner|corpus\.lock|pick\.lock|start\.lock)([\\/]|$)|\.(lock|tmp)$'

$items = New-Object System.Collections.ArrayList
$leftOut = New-Object System.Collections.ArrayList
$skipped = 0; [int64]$skippedBytes = 0

function Add-Tree([string]$Root, [string]$Prefix, [bool]$Filter) {
  if (-not (Test-Path -LiteralPath $Root -PathType Container)) { Write-Mig ('not found, skipped: ' + $Root) 'WARN'; return }
  $full = (Get-Item -LiteralPath $Root -Force).FullName.TrimEnd('\')
  foreach ($f in @(Get-ChildItem -LiteralPath $full -Recurse -File -Force -ErrorAction SilentlyContinue)) {
    $rel = $f.FullName.Substring($full.Length + 1)
    if (($f.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { continue }
    if ($Filter) {
      if ($rel -match $lockRx -or ($noPics -contains $f.Extension.ToLowerInvariant()) -or ($f.Length -gt ($MaxFileMB * 1MB))) { $script:skipped++; $script:skippedBytes += $f.Length; continue }
    }
    Add-One $f ($Prefix + '/' + $rel.Replace('\', '/'))
  }
}
function Add-One([System.IO.FileInfo]$F, [string]$Entry) {
  if (Test-SecretFileName $F.FullName) { [void]$leftOut.Add([pscustomobject]@{ Name = $Entry; Why = 'the file name looks like a login or key file' }); return }
  [void]$items.Add([pscustomobject]@{ Full = $F.FullName; Entry = $Entry; Size = [int64]$F.Length; Time = $F.LastWriteTime })
}
function Copy-Snap([string]$Src, [string]$Dst) {
  $in = $null; $out = $null
  try {
    $in = [System.IO.File]::Open($Src, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, ([System.IO.FileShare]::ReadWrite -bor [System.IO.FileShare]::Delete))
    $out = [System.IO.File]::Open($Dst, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
    $in.CopyTo($out, 1048576); return $true
  } catch { return $false } finally { if ($out) { $out.Dispose() }; if ($in) { $in.Dispose() } }
}
function Hash-File([string]$P) { return (Get-FileHash -LiteralPath $P -Algorithm SHA256).Hash.ToLowerInvariant() }
function Share-Put([string]$Name, [string]$File) {
  if ($DryRun) { Write-Mig ('would put ' + $Name + ' in the share') 'DRY'; return $true }
  $o = & node $hostctl share-put ('name=' + $Name) --file $File 2>&1
  $j = $null; try { $j = (($o | Out-String) | ConvertFrom-Json) } catch { }
  if ($j -and $j.ok -and ([int64]$j.size -eq (Get-Item -LiteralPath $File).Length)) { return $true }
  Write-Mig ('the share did not take ' + $Name + ': ' + (Protect-Text (($o | Out-String).Trim()))) 'FAIL'; return $false
}

Write-MigBlank
Write-Mig '=== VM PACK: scratchpad, memory and tools for the main PC ===' 'STEP'
if ($DryRun) { Write-Mig '(dry run: nothing is built or put in the share)' 'DRY' }
New-Item -ItemType Directory -Force -Path $work | Out-Null

Write-Mig 'Collecting the file list' 'STEP'
Add-Tree -Root $script:ScratchPad -Prefix 'scratch' -Filter $true
$nScratch = $items.Count
Add-Tree -Root $memDir -Prefix 'memory' -Filter $false
$nMem = $items.Count - $nScratch
$sl = Join-Path $repo '.claude\settings.local.json'
if (Test-Path -LiteralPath $sl) { Add-One (Get-Item -LiteralPath $sl -Force) 'repo/.claude/settings.local.json' }
Add-Tree -Root $binDir -Prefix 'bin' -Filter $false
[int64]$total = 0; foreach ($it in $items) { $total += $it.Size }
Write-Mig ('scratchpad ' + $nScratch + ' file(s), memory ' + $nMem + ' file(s), ' + $items.Count + ' in all, ' + (Format-Bytes $total) + ' before compression') 'INFO'
Write-Mig ('left out for size or as locks: ' + $skipped + ' file(s), ' + (Format-Bytes $skippedBytes)) 'INFO'
if ($nMem -eq 0) { Write-Mig ('no memory files found in ' + $memDir) 'FAIL'; Exit-Mig 1 }
foreach ($need in @('shipq.sh', 'shipone.sh', 'lock.sh', 'unlock.sh', 'fixq.sh', 'genP.sh', 'runchk.sh')) {
  if (-not (Test-Path -LiteralPath (Join-Path $script:ScratchPad $need))) { Write-Mig ('the scratchpad has no ' + $need) 'WARN' }
}
$lk = Get-ShipLock
if ($lk.Exists) { Write-Mig ('a ship holds the lock right now (' + $lk.Owner + '). The lock itself is not packed; pack again after the last ship.') 'WARN' }

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
Write-Mig 'Scanning and packing (this reads every file once)' 'STEP'
if (Test-Path -LiteralPath $zipTmp) { Remove-Item -LiteralPath $zipTmp -Force }
$zfs = $null; $za = $null; $packed = 0; $i = 0; $failed = $false
try {
  if (-not $DryRun) {
    $zfs = [System.IO.File]::Open($zipTmp, [System.IO.FileMode]::Create, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
    $za = New-Object System.IO.Compression.ZipArchive($zfs, [System.IO.Compression.ZipArchiveMode]::Create, $false)
  }
  foreach ($it in $items) {
    $i++
    if (($i % 500) -eq 0) { Write-Mig ('... ' + $i + ' of ' + $items.Count + ' files') 'INFO' }
    if (-not (Copy-Snap $it.Full $snap)) { [void]$leftOut.Add([pscustomobject]@{ Name = $it.Entry; Why = 'could not be read' }); continue }
    $ext = [System.IO.Path]::GetExtension($it.Entry).ToLowerInvariant()
    $kinds = Find-SecretKindsInFile -Path $snap -Generic ($binExt -notcontains $ext)
    if ($null -eq $kinds) { $kinds = @() }
    if ($kinds.Count -gt 0) { [void]$leftOut.Add([pscustomobject]@{ Name = $it.Entry; Why = ('looks like it holds a key: ' + ($kinds -join ', ')) }); continue }
    if (-not $DryRun) {
      $e = $za.CreateEntry($it.Entry, [System.IO.Compression.CompressionLevel]::Optimal)
      try { $e.LastWriteTime = [System.DateTimeOffset]$it.Time } catch { }
      $es = $null; $ss = $null
      try { $es = $e.Open(); $ss = [System.IO.File]::Open($snap, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read); $ss.CopyTo($es, 1048576) }
      finally { if ($ss) { $ss.Dispose() }; if ($es) { $es.Dispose() } }
    }
    $packed++
  }
} catch { $failed = $true; Write-Mig ('packing failed: ' + (Protect-Text $_.Exception.Message)) 'FAIL' }
finally { if ($za) { $za.Dispose() }; if ($zfs) { $zfs.Dispose() }; if (Test-Path -LiteralPath $snap) { Remove-Item -LiteralPath $snap -Force -ErrorAction SilentlyContinue } }
if ($failed) { Exit-Mig 1 }
foreach ($lo in $leftOut) { Write-Mig ('left out: ' + $lo.Name + ' (' + $lo.Why + ')') 'WARN' }
Write-Mig ($packed.ToString() + ' file(s) pass the scan; ' + $leftOut.Count + ' left out by the secret rules') 'OK'
$bad = @($leftOut | Where-Object { $_.Name -match '^scratch/(shipq|shipone|lock|unlock|fixq|genP|runchk)\.sh$' })
if ($bad.Count -gt 0) { Write-Mig 'a ship script itself was left out; the main PC cannot ship without it. Look at it before going on.' 'FAIL'; if (-not $DryRun) { Exit-Mig 1 } }

if ($DryRun) { Write-Mig 'Dry run finished. Nothing was built or sent.' 'DONE'; Exit-Mig 0 }

# ------------------------------------------------------------------ parts and manifest
$zr = $null; $count = -1
try { $zr = [System.IO.Compression.ZipFile]::OpenRead($zipTmp); $count = $zr.Entries.Count } catch { } finally { if ($zr) { $zr.Dispose() } }
if ($count -ne $packed) { Write-Mig ('the zip holds ' + $count + ' entries, ' + $packed + ' were written. Nothing sent.') 'FAIL'; Exit-Mig 1 }
$zipLen = (Get-Item -LiteralPath $zipTmp).Length
$zipHash = Hash-File $zipTmp
Write-Mig ('zip: ' + (Format-Bytes $zipLen)) 'OK'
$parts = @(); $buf = New-Object byte[] $partSize; $n = 0
$rd = [System.IO.File]::OpenRead($zipTmp)
try {
  while (($got = $rd.Read($buf, 0, $partSize)) -gt 0) {
    $n++
    $pn = 'devpack-part-{0:d3}.bin' -f $n
    $pf = Join-Path $work $pn
    $w = [System.IO.File]::Create($pf); try { $w.Write($buf, 0, $got) } finally { $w.Dispose() }
    $parts += [ordered]@{ name = $pn; size = [int64]$got; sha256 = (Hash-File $pf) }
  }
} finally { $rd.Dispose() }
# git identity and account ids go in the share, never in the public repo. The ids (no tokens, only these two fields are read) let the new
# main PC chat confirm it is on the personal account, as memory note pillagers-fortnite-island-idea-2026-11-01.md says to.
$acct = ''; $org = ''
try { $cj = Get-Content -LiteralPath (Join-Path $env:USERPROFILE '.claude.json') -Raw | ConvertFrom-Json; $acct = [string]$cj.oauthAccount.accountUuid; $org = [string]$cj.oauthAccount.organizationUuid } catch { Write-Mig 'could not read the account ids from .claude.json' 'WARN' }
$rs = Get-RepoState
$loList = @(); foreach ($x in $leftOut) { $loList += [ordered]@{ name = [string]$x.Name; why = [string]$x.Why } }
$man = [ordered]@{
  created  = (Get-Date).ToString('s'); host = $env:COMPUTERNAME; gitHead = [string]$rs.Head
  remote   = ((& git -C $repo remote get-url origin) | Out-String).Trim()
  gitName  = ((& git -C $repo config user.name) | Out-String).Trim(); gitEmail = ((& git -C $repo config user.email) | Out-String).Trim()
  accountId = $acct; organizationId = $org
  entries  = $packed; zipSize = [int64]$zipLen; zipSha256 = $zipHash; parts = $parts; leftOut = $loList
}
$manFile = Join-Path $work 'devpack-manifest.json'
Write-AsciiFile -Path $manFile -Text ($man | ConvertTo-Json -Depth 6)

Write-Mig ('Putting ' + $parts.Count + ' part(s) in the bridge share') 'STEP'
foreach ($p in $parts) { if (-not (Share-Put $p.name (Join-Path $work $p.name))) { Exit-Mig 1 }; Write-Mig ('sent ' + $p.name) 'OK' }
foreach ($s in @('main-dev-setup.ps1', 'main-dev-tasks.ps1')) { if (-not (Share-Put $s (Join-Path $PSScriptRoot $s))) { Exit-Mig 1 } }
# the manifest goes last: main-dev-setup treats a pack as whole only when every part it names checks out
if (-not (Share-Put 'devpack-manifest.json' $manFile)) { Exit-Mig 1 }
$lst = $null; try { $lst = ((& node $hostctl share-list 2>$null) | Out-String) | ConvertFrom-Json } catch { }
$miss = 0; foreach ($p in $parts) { if (-not (@($lst.files) | Where-Object { $_.name -eq $p.name -and [int64]$_.size -eq [int64]$p.size })) { $miss++ } }
if ($miss -gt 0) { Write-Mig ($miss.ToString() + ' part(s) are not in the share at the right size') 'FAIL'; Exit-Mig 1 }
Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
Write-Mig ('Pack is in the share: ' + $parts.Count + ' part(s), ' + (Format-Bytes $zipLen) + ', head ' + ([string]$rs.Head).Substring(0, 8)) 'DONE'
Exit-Mig 0
