$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# GUN KEY AND WHEEL NAMES FIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #kitsetup .ksrow{ display:flex; gap:22px; padding:2px 12px 4px; }
'@ @'
  #kitsetup .ksrow{ display:flex; gap:10px; padding:2px 12px 4px; }   /* v28.20 (cloud-menus-kit-tile-names-fit), CLOUD HUNT 2026-10-15: the names were cut at the default menu size from 1080p fullscreen up; the plates sit closer */
'@

SubRx @'
  #kitsetup .ksp:first-child{ flex:1.1 1 0; }   /* v26.xx (gunkeys3): the nine class names (MARKSMAN) need a little more room than the wheel names (TRIPWIRE) */
'@ @'
  #kitsetup .ksp:first-child{ flex:1.2 1 0; }   /* v26.xx (gunkeys3): the nine class names (MARKSMAN) need a little more room than the wheel names (TRIPWIRE) */   /* v28.20 (cloud-menus-kit-tile-names-fit), CLOUD HUNT 2026-10-15: 1.2 leaves MARKSMAN and TRIPWIRE the same spare room */
'@

SubRx @'
  #kitsetup .kst span{ min-width:0; overflow:hidden; white-space:nowrap; font-weight:700; font-size:13px; letter-spacing:.06em; color:var(--tx-1); text-transform:uppercase; }
'@ @'
  #kitsetup .kst span{ min-width:0; overflow:hidden; white-space:nowrap; font-weight:700; font-size:12px; letter-spacing:0; color:var(--tx-1); text-transform:uppercase; }   /* v28.20 (cloud-menus-kit-tile-names-fit), CLOUD HUNT 2026-10-15: 13px spaced did not fit MARKSMAN */
'@

SubRx @'
  #kitsetup .kst{ gap:6px; padding:0 6px; }
'@ @'
  #kitsetup .kst{ gap:4px; padding:0 3px; }   /* v28.20 (cloud-menus-kit-tile-names-fit), CLOUD HUNT 2026-10-15: 4px still keeps the enlarged gun picture off its name */
'@

SubRx @'
var VER='28.19';
'@ @'
var VER='28.20';
'@

$pat = "(?m)^  now:'v28\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.20: Every gun key and item wheel name on the stash now shows in full at 1440p and 4K. Check 28.20 fails on v28.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
