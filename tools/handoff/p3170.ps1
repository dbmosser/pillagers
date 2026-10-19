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

# STASH GUN KEYS AT THE 16PX FLOOR, NO BUILD STAMP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #kitsetup .kst span, #root #kitsetup .kstc span, #root #kitsetup .ksreset{ font-size:var(--fs-fine); }
'@ @'
#root #kitsetup .kst span, #root #kitsetup .kstc span, #root #kitsetup .ksreset{ font-size:var(--fs-label); }
/* v28.xx (cw-uc-stash3) b-31 step 7, critic on 04 (P1 "key names inside gun keys and wheel about 11px bold... under the 16px floor", P0 "the version stamp is the title area"): the gun key and item wheel names, the section captions and the reset buttons go from 14px to the 16px label size, names lose their letter spacing so shotgun and carbine still fit; the build stamp beside PILLAGERS is hidden in the Undercroft (it stays in the F1 and settings pages). */
#root #kitsetup .kst span{ letter-spacing:0; }
#root #hub #verlabel{ display:none; }
'@

SubRx @'
var VER='31.69';
'@ @'
var VER='31.70';
'@

$pat = "(?m)^  now:'v31\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.70: Gun key names are 16px and the stash header has no build stamp. Check 31.70 fails on v31.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
