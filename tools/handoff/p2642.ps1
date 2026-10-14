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

# THE SETUP PLATES FIT THEIR WORDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #kitsetup .ksp{ flex:1 1 0; min-width:0; }
'@ @'
  #kitsetup .ksp{ flex:1 1 0; min-width:0; }
  #kitsetup .ksp:first-child{ flex:1.1 1 0; }   /* v26.xx (gunkeys3): the nine class names (MARKSMAN) need a little more room than the wheel names (TRIPWIRE) */
'@

SubRx @'
  #kitsetup .kst b{ flex:none; width:14px; font-weight:700; font-size:18px; line-height:1; color:var(--acc); }
'@ @'
  #kitsetup .kst b{ flex:none; width:11px; font-weight:700; font-size:18px; line-height:1; color:var(--acc); }
'@

SubRx @'
  #kitsetup .kst span{ min-width:0; overflow:hidden; white-space:nowrap; font-weight:700; font-size:13px; letter-spacing:.1em; color:var(--tx-1); text-transform:uppercase; }
'@ @'
  #kitsetup .kst span{ min-width:0; overflow:hidden; white-space:nowrap; font-weight:700; font-size:13px; letter-spacing:.06em; color:var(--tx-1); text-transform:uppercase; }
  #kitsetup .kst{ gap:6px; padding:0 6px; }
  #kitsetup [data-gk] .ic{ transform:scale(1.4); }   /* a gun picture is a wide shape in a square: drawn larger it reads on a tile this size */
'@

SubRx @'
var VER='26.41';
'@ @'
var VER='26.42';
'@

$pat = "(?m)^  now:'v26\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.42: The gun keys plate on the Stash screen shows every name whole and bigger gun pictures. Check 26.42 fails on v26.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
