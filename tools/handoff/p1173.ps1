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

# A CHARACTER WHO HAS NEVER SAVED HAS NO NAME. From the 2026-09-06 menu audit.
# The default profile literal carries no pname. The line that fills it in,
# "if(typeof P.pname!=='string'||!P.pname) P.pname='PILLAGER'", lives inside
# applyLoadedProfile, which only runs when a SAVED profile is found, so it
# cannot help the one player who has never saved: a brand new one. It is the
# same class as the dayMigrated hole v8.44 closed, a default written only for
# people who already have a save.
SubRx @'
var P={credits:900,stash:[],weapons:['pistol'],equipped:'fists',runs:0,ext:0,died:0,best:0,dayMigrated:1,
'@ @'
var P={credits:900,stash:[],weapons:['pistol'],equipped:'fists',runs:0,ext:0,died:0,best:0,dayMigrated:1,
  // v11.73, from the 2026-09-06 menu audit: BORN SET, like dayMigrated above.
  // The pname default lives inside applyLoadedProfile, which only runs when a
  // save exists, so a player who has never saved had no name at all and the
  // character screen read "undefined" beside his first raid.
  pname:'PILLAGER',
'@

# AND THE LINE THAT PRINTS IT. The default is born set above, but the character
# screen is what a player reads, and every other reader of the name already
# falls back. This is also the only part of the defect a check can observe,
# since the harness rebuilds profiles through the loader.
SubRx @'
        ? (P.pname+'  \u00b7  '+P.runs+' raid'+(P.runs===1?'':'s')+' logged  \u00b7  '+'$'+P.credits.toLocaleString()+' banked')
'@ @'
        // v11.73: the same fallback every other reader of the name already has.
        // The default is born set now, but this is the line a player SEES, and
        // a name is not something to print raw.
        ? ((P.pname||'PILLAGER')+'  \u00b7  '+P.runs+' raid'+(P.runs===1?'':'s')+' logged  \u00b7  '+'$'+P.credits.toLocaleString()+' banked')
'@

# STAMPS.
SubRx @'
var VER='11.72';
'@ @'
var VER='11.73';
'@
SubRx @'
var WHATSNEW_VER='11.72';
'@ @'
var WHATSNEW_VER='11.73';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A BRAND NEW CHARACTER HAS A NAME. Before this, someone playing for the first time had none until the game had saved and loaded once, and the character screen read "undefined" beside their first raid.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.72:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.72 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.72:[^']*'",{ param($m) "now:'v11.73: a character who has never saved had no name. The default profile literal carries no pname and the line that fills it in sits inside applyLoadedProfile, which only runs when a save is found, so it could never help a brand new player. After a first raid the character screen read undefined beside the run count, since that line only prints the name once runs is above zero. pname is born set in the literal now, like dayMigrated. From the 2026-09-06 menu audit.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
