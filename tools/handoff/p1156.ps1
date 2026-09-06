$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# A PILLAGER YOU DOWNED AND THEN SAVED WAS STILL YOUR KILL. Your downing shot
# stamps byPlayer on him (v8.30, the one door for attribution). Reviving him
# (E, v9.24) stands him up, clears hostile and grudge, makes him friendly, and
# never clears byPlayer. A crawler bite writes no byPlayer, so when a crawler
# downs him minutes later and he bleeds out, the kill code reads the stale flag:
# you get the kill, a kill contract ticks, "will remember that", and a permanent
# -2 grudge on the man you saved. The revive clears the flag with the rest.
SubRx @'
      downRdr.hostile=false; downRdr.grudge=false; downRdr.friendlyPC=1;
'@ @'
      downRdr.hostile=false; downRdr.grudge=false; downRdr.friendlyPC=1;
      downRdr.byPlayer=false;   // v11.56: his next death is not yours unless you cause it
'@

# STAMPS.
SubRx @'
var VER='11.55';
'@ @'
var VER='11.56';
'@
SubRx @'
var WHATSNEW_VER='11.55';
'@ @'
var WHATSNEW_VER='11.56';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'SAVING A MAN YOU SHOT NO LONGER PINS HIS LATER DEATH ON YOU. If you downed a pillager, then picked him up, and a crawler killed him later, the game still called it your kill: a contract tick, a grudge, the lot. Once you have saved him, only you can make his death yours again.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.55:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.55 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.55:[^']*'",{ param($m) "now:'v11.56: a pillager you downed and then saved was still your kill. The downing shot stamps byPlayer; the revive cleared hostile and grudge and made him friendly but never byPlayer, and a crawler bite writes none, so when a crawler downed him later and he bled out the stale flag credited you the kill, ticked a kill contract and wrote a permanent -2 grudge on the man you saved. The revive clears byPlayer now. From the v11.46 audit, P1.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
