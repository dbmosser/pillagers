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

# THE CONTROLLER PING IS D-UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ['TEAM',[['Y','backpack open: drop an item for a teammate'],['LB + RB','ping, twice for danger']]]   // v18.27: his order, trading is dropping
'@ @'
  // v20.76, from the whole-game bug hunt of 2026-10-08 (H46): THE PING IS D-UP ON A CONTROLLER. This row said LB + RB, but both
  // bumpers together walk the belt and zoom and have not pinged since v16.46 moved the ping to D-UP, so the row taught a button
  // that does nothing. It names D-UP now, the same button the WORLD row above names.
  ['TEAM',[['Y','backpack open: drop an item for a teammate'],['DPAD UP','ping, twice for danger']]]   // v18.27: his order, trading is dropping
'@

SubRx @'
    if(typeof NET==='object'&&NET&&NET.on) MN.push([(PAD&&PAD.on)?'Y':'Z','drop to trade'],[(PAD&&PAD.on)?'LB + RB':'N','ping']);   // v18.27: his order, trading is dropping
'@ @'
    // v20.76, from the whole-game bug hunt of 2026-10-08 (H46): ON A CONTROLLER THE PARTY ROWS ADD NO SECOND PING. The pad list
    // above already says D-UP ping, and the row added here named both bumpers, which never ping. On keys N still pings.
    if(typeof NET==='object'&&NET&&NET.on){ if(PAD&&PAD.on) MN.push(['Y','drop to trade']); else MN.push(['Z','drop to trade'],['N','ping']); }   // v18.27: his order, trading is dropping
'@

SubRx @'
var VER='20.75';
'@ @'
var VER='20.76';
'@

$pat = "(?m)^  now:'v20\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.76: On a controller the controls list says D-UP pings, the button that really does. Check 20.76 fails on v20.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
