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

# THE FINISHER ON A CONTROLLER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var PADLABEL={KeyE:'X',KeyR:'X',KeyF:'D-DOWN',KeyT:'RB',KeyG:'RT',KeyQ:'D-DOWN',
'@ @'
var PADLABEL={KeyE:'X',KeyR:'X',KeyF:'D-DOWN',KeyT:'RB',KeyG:'RT',KeyQ:'D-DOWN',KeyV:'Y',
'@

SubRx @'
var PADLOGIC={KeyE:2,KeyR:2,KeyF:13,KeyT:5,KeyG:7,KeyQ:13,Space:0,KeyP:9,KeyX:2,ShiftLeft:10,ControlLeft:1,KeyM:12,KeyI:8};
'@ @'
var PADLOGIC={KeyE:2,KeyR:2,KeyF:13,KeyT:5,KeyG:7,KeyQ:13,Space:0,KeyP:9,KeyX:2,ShiftLeft:10,ControlLeft:1,KeyM:12,KeyI:8,KeyV:3};   // v27.xx (feel2g): V, the finisher, is on action 3 (Y)
'@

SubRx @'
      padHold('PadSearch',(_yD&&!PAD.yAid)||(_xDown&&PAD.xMode==='KeyE'&&_xSearch));   // v25.xx (keyswap): the pad ring search (was keyboard X, which is the extraction now)
'@ @'
      // v27.xx (feel2g), a cloud review finding (2026-10-15, #5): THE FINISHER ON A CONTROLLER. The finisher (v26.64) read keyboard V and no pad button reached it, so player 2 on a pad was
      // shown FINISH [V] over every downed pillager and could not do it. Y (pad action 3, whatever CHANGE PAD BUTTONS has put it on) held with a downed pillager in finisher reach is the
      // finisher: it holds the same key V the keyboard does (and so does not swing the crowbar), and the prompt names the button as bound (PADLABEL). Y keeps its other jobs, which win
      // when they apply: helping a teammate (netAidHold, decided on the press), and the search of a box or the ring when one is in reach underfoot.
      var _yF=!!(_yD&&!PAD.yAid&&G&&!G.over&&G.player&&!G.player.downed&&!G.nearContainer&&!G.nearPad&&finTarget(G.player));
      padHold('KeyV',_yF);
      padHold('PadSearch',(_yD&&!PAD.yAid&&!_yF)||(_xDown&&PAD.xMode==='KeyE'&&_xSearch));   // v25.xx (keyswap): the pad ring search (was keyboard X, which is the extraction now)
'@

SubRx @'
[3,'search in a ring, help a teammate','FIGHT']
'@ @'
[3,'search in a ring, help a teammate, finish a downed pillager','FIGHT']
'@

SubRx @'
[n(3),'search in a ring']
'@ @'
[n(3),'search in a ring; hold to finish a pillager']
'@

SubRx @'
['Y','search in a ring']
'@ @'
['Y','search in a ring; hold to finish a pillager']
'@

SubRx @'
var VER='27.43';
'@ @'
var VER='27.44';
'@

$pat = "(?m)^  now:'v27\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.44: On a controller, hold Y on a downed pillager in reach to finish him. Check 27.44 fails on v27.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
