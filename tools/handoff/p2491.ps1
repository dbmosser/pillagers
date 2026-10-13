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

# THE SCAV PISTOL IS SPAWN-ONLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var LOOT={
  crate:
'@ @'
// v24.xx (scavspawnonly), HIS ORDER (2026-10-12): "scav pistol should not be a findable item -- only spawn with one, never find one in
// environment or on pillager bot etc". The Scav Pistol is the gun you go up with (the freebie kit, the armoury pistol every save
// starts with) and nothing else: it is out of the locker and body tables below, the landmark ammo table, the Peddler gun slot and
// Wirt's gamble, no pillager or hired man rolls it (the three pistol rows in mkRaider are the Tacker now, the same tier and feel),
// an imported friend who favoured it walks in with the Tacker, and reward 5 pays its value when you already own one instead of a
// second pistol to the stash. Every roll that drew it still draws once from the rest, so no seeded draw moved and the seed 4242
// build holds the same entities and containers. The item (Scav Pistol (field)) stays: it is what your own pistol becomes in the
// backpack, and a stash that already holds one keeps it.
var LOOT={
  crate:
'@

SubRx @'
['stim',5],['gun_pistol',4],['gun_smg',2],['gun_carbine',2]
'@ @'
['stim',5],['gun_smg',2],['gun_carbine',2]
'@

SubRx @'
        ['gun_pistol',7],['gun_smg',5],
'@ @'
        ['gun_smg',5],
'@

SubRx @'
  var wk=pick(['pistol','pistol','pistol','smg','smg','rifle','rifle','carbine','shotgun']);
'@ @'
  // v24.xx (scavspawnonly), HIS ORDER: the Scav Pistol is spawn-only, so the three pistol rows are the Tacker, the other tier 1
  // sidearm (20 a round against 23, 14 rounds against 12), and the pick still draws once from nine.
  var wk=pick(['tacker','tacker','tacker','smg','smg','rifle','rifle','carbine','shotgun']);
'@

SubRx @'
  r.bag.push('gun_'+wk);
'@ @'
  if(ITEMS['gun_'+wk]) r.bag.push('gun_'+wk);   // v24.xx (scavspawnonly): the Tacker is an issued gun with no item form, so it is not loot
'@

SubRx @'
var PED_GUNS=['gun_pistol','gun_smg',
'@ @'
// v24.xx (scavspawnonly): six now, the Scav Pistol is spawn-only (his order 2026-10-12); the slot still draws once.
var PED_GUNS=['gun_smg',
'@

SubRx @'
['board',5],['gun_pistol',3],['gun_smg',2]]
'@ @'
['board',5],['gun_smg',2]]
'@

SubRx @'
      if(old&&old.id!=='fists'&&e.bag.indexOf('gun_'+old.id)<0) e.bag.push('gun_'+old.id);
'@ @'
      if(old&&old.id!=='fists'&&ITEMS['gun_'+old.id]&&e.bag.indexOf('gun_'+old.id)<0) e.bag.push('gun_'+old.id);   // v24.xx (scavspawnonly): a Tacker has no item form
'@

SubRx @'
      if(ITEMS[_dupK]){
'@ @'
      // v24.xx (scavspawnonly), HIS ORDER: the Scav Pistol is spawn-only, so a duplicate one (reward 5, BACKUP PISTOL, on every save
      // that still owns the pistol) pays what the gun is worth instead of putting a second Scav Pistol in the stash.
      if(ITEMS[_dupK]&&T.v!=='pistol'){
'@

SubRx @'
      e.wep=(WEAPONS[P.ghost.wep].mag===0)?WEAPONS.pistol:WEAPONS[P.ghost.wep];
'@ @'
      // v24.xx (scavspawnonly), HIS ORDER: no pillager carries the Scav Pistol, so a friend who favoured it (or bare hands) walks in
      // with the Tacker, the same tier and feel.
      e.wep=(WEAPONS[P.ghost.wep].mag===0||P.ghost.wep==='pistol')?WEAPONS.tacker:WEAPONS[P.ghost.wep];
'@

SubRx @'
  ['gun_pistol',4],['gun_smg',3],['gun_carbine',2],
'@ @'
  ['gun_smg',3],['gun_carbine',2],
'@

SubRx @'
var VER='24.90';
'@ @'
var VER='24.91';
'@

$pat = "(?m)^  now:'v24\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.91: The Scav Pistol is spawn-only now: you never find one in a container, on the ground, at the Peddler or on a pillager. Check 24.91 fails on v24.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
