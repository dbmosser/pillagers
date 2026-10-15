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

# THE MEDAL SPOT IS RESERVED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var FEEDBOX={on:0,x:0,y:0,w:0,h:0,rows:[]};
'@ @'
var FEEDBOX={on:0,x:0,y:0,w:0,h:0,rows:[]};
// v27.40 (medal0), HIS ANSWER (2026-10-14), "Halo puts medals in a row at the left": THE MEDAL SPOT IS RESERVED. A row for the style medals
// (the later party polish draws the emblems there, 48 px at 1080p) between the feed and the vitals, the feed's width: nothing else may draw
// in it. The feed stands on it now, so the feed moved up by its height; until the emblems exist the spot is empty.
var MEDALBOX={on:0,x:0,y:0,w:0,h:0};
'@

SubRx @'
  bot=((B&&B.h>0&&B.y>H*0.5)?B.y:Math.round(H-LH(142)*rs*1.4))-Math.round(LH(8)*rs);
'@ @'
  bot=((B&&B.h>0&&B.y>H*0.5)?B.y:Math.round(H-LH(142)*rs*1.4))-Math.round(LH(8)*rs);
  MEDALBOX.h=Math.round(LH(40)*rs); MEDALBOX.y=bot-MEDALBOX.h; MEDALBOX.x=Math.round(LH(9)*rs); MEDALBOX.w=Math.round(W*0.24); MEDALBOX.on=1;   // v27.40 (medal0): the medal spot, on the vitals
  bot=MEDALBOX.y-Math.round(LH(6)*rs);   // and the feed stands on it
'@

SubRx @'
var VER='27.39';
'@ @'
var VER='27.40';
'@

$pat = "(?m)^  now:'v27\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.40: A row for the style medals is reserved between the feed and the vitals. Check 27.40 fails on v27.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
