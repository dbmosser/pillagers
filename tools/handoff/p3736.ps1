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

# the hall: its sign sits at its ring, gen has room, the empty line is quiet (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ly=(s3.labelBelow?s3.y+s3.r+4:s3.y-56)+10;
'@ @'
var ly=(s3.labelY!==undefined)?s3.labelY:((s3.labelBelow?s3.y+s3.r+4:s3.y-56)+10);   // v37.xx (cw-m2hallb), critic 3 of 5 on the hall wall: its sign sat 30 below its ring, detached
'@

SubRx @'
wallSt:1,labelBelow:1,acts:
'@ @'
wallSt:1,labelY:101,acts:
'@

SubRx @'
    #opane_hall #hallempty{ padding:32px 16px; font:600 28px/1.2 var(--f-cond); color:var(--tx-2); text-align:center; }

'@ @'
    #opane_hall #hallempty{ padding:16px; font:400 20px/1.4 var(--f-body); color:var(--tx-2); text-align:left; }
    #opane_hall .hallgrid > :nth-child(2){ margin-right:16px; }   /* v37.xx (cw-m2hallb), critic: gen sat 16px from how it ended, 32 now */

'@

SubRx @'
#opane_hall .hv{ font:700 36px/1.15 var(--f-cond); color:var(--tx-1); margin-top:8px;
'@ @'
#opane_hall .hv{ font:700 36px/1.35 var(--f-cond); color:var(--tx-1); margin-top:4px;
'@

SubRx @'
#opane_hall .hname{ font:700 28px/1.2 var(--f-cond);
'@ @'
#opane_hall .hname{ font:700 28px/1.35 var(--f-cond);
'@

SubRx @'
var VER='37.35';
'@ @'
var VER='37.36';
'@

$pat = "(?m)^  now:'v37\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.36: The hall sign sits right under the ring by the wall. Watch for: nothing else changes. Check 37.36 fails on v37.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
