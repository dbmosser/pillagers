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

# THE BELT MESSAGE NAMED THE WRONG KEY. A belt key that holds a gun still in
# the backpack said "TAB to equip it"; TAB opens and closes the backpack, and
# ENTER is what equips the selected gun (v2.94, and the LEGEND row "ENTER
# equip gun from backpack"). A friend who did as told opened a panel and
# equipped nothing.
SubRx @'
    say(s2.name+' is in your backpack. TAB to equip it.');
'@ @'
    say(s2.name+' is in your backpack. TAB, then ENTER to equip it.');
'@

# STAMPS.
SubRx @'
var VER='11.29';
'@ @'
var VER='11.30';
'@
SubRx @'
var WHATSNEW_VER='11.29';
'@ @'
var WHATSNEW_VER='11.30';
'@
SubRx @'
  'THE SECTOR SCREEN TELLS THE TRUTH AGAIN. Its "measured extraction" figures were three hundred builds old and half the real number; they are fresh, and they say whose they are: the test robot. And a death card no longer measures your first 67 XP against the last reward of the season.',
'@ @'
  'A BELT KEY TELLS YOU THE RIGHT KEY. Pressing a tactical belt key for a gun still in your backpack used to say "TAB to equip it"; TAB only opens the backpack. It now says TAB, then ENTER, which is what equips it.',
  'THE SECTOR SCREEN TELLS THE TRUTH AGAIN. Its "measured extraction" figures were three hundred builds old and half the real number; they are fresh, and they say whose they are: the test robot. And a death card no longer measures your first 67 XP against the last reward of the season.',
'@
SubRx @'
  now:'v11.29: the first hour past the floor, walked on a fresh profile: title, sector screen, loadout question, drop, death card, return. Two things were wrong and are fixed: the sector screen showed v8.01 robot figures (18 and 23.5 percent) as "measured extraction" while the robot extracts about 39 now, so they are refreshed from 120 seeds a map and labelled as the robot; and a death card measured a first 67 XP against the 1,200,000 of the season last reward, with the explaining sentence removed at v8.91, so it now says the total and nothing else.',
'@ @'
  now:'v11.30: a belt key for a gun still in the backpack said "TAB to equip it"; TAB opens the backpack and ENTER equips (v2.94, LEGEND). Reproduced by pressing the key: the message named the key that does nothing. It says TAB, then ENTER now. From the same read-only agent as v11.26 to v11.28; one finding a build, each pressed in the page first.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
