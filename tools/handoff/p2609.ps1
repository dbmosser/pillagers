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

# A HARDER CROWBAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function meleeStrike(){
'@ @'
// v26.xx (crowbardmg), HIS NOTE 2026-10-13: "crowbar needs to do alot more damage -- 3 swings should kill a crawler", and his earlier
// answer that the crowbar is "a viable choice in close combat, think Halo". A BALANCE CHANGE (balancing is allowed since 2026-10-02).
// The Q blow was the bare hands strike, 6 damage, so a standard crawler (52 health) took nine swings. The crowbar blow now does 18, which
// is ceil(52 / 3): a crawler at full health survives two swings (36) and dies on the third (54). Only the crowbar blow changes. The
// left-click punch with bare hands stays at 6; the reach (60) and the 420 ms cooldown are the same; a blow from behind is still 1.5
// times as hard (27, so two swings for a crawler); a blow still ignores armour; nothing an enemy does to you moves. No draw from the
// seeded stream (the damage is a number), and the bot never swings a crowbar (meleeStrike refuses in a sim raid).
var CROWBAR_DMG=18;
function crowbarWep(){ var w=cloneObj(WEAPONS.fists); w.dmg=CROWBAR_DMG; return w; }
function meleeStrike(){
'@

SubRx @'
fireWeapon(p,WEAPONS.fists,p.x+Math.cos(p.face)*100,p.y+Math.sin(p.face)*100,true);
'@ @'
fireWeapon(p,crowbarWep(),p.x+Math.cos(p.face)*100,p.y+Math.sin(p.face)*100,true);   // v26.xx (crowbardmg): the crowbar's own 18, not the bare hands 6
'@

SubRx @'
var VER='26.08';
'@ @'
var VER='26.09';
'@

$pat = "(?m)^  now:'v26\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.09: The crowbar hits three times as hard: three swings now kill a crawler, where it took nine. Check 26.09 fails on v26.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
