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

# FROM THE 2026-09-06 MENU AUDIT (P1, raised by two regions): the safe pocket
# accepted a Frag Charge, a Smoke, a Decoy or an Ammo Box and read 1/1, but
# those ride in the pouch and the reserve, not the backpack, and the death
# path banks only the backpack; so naming one spent the only death
# protection there is on nothing, for the whole raid. Refused now, the way a
# gun is refused, and a pocket already saved on one is cleared on load.
SubRx @'
function setSafe(k){
  if(k&&!ITEMS[k]) return 'That is not a thing you can carry.';
  if(k&&ITEMS[k].use==='gun') return 'A gun does not fit in a safe pocket.';
  P.safe=k||null; saveProfile(); return null;
}
'@ @'
function setSafe(k){
  if(k&&!ITEMS[k]) return 'That is not a thing you can carry.';
  if(k&&ITEMS[k].use==='gun') return 'A gun does not fit in a safe pocket.';
  // v11.92, from the 2026-09-06 menu audit: a grenade rides in the pouch and
  // ammunition in the reserve, and the death path banks the backpack only,
  // so a pocket naming either came home with nothing while reading 1/1.
  if(k&&ITEMS[k].use==='throw') return 'A throwable rides in the pouch, not a pocket. It cannot come home from there.';
  if(k&&ITEMS[k].use==='ammo') return 'Ammunition rides in the reserve, not a pocket. It cannot come home from there.';
  P.safe=k||null; saveProfile(); return null;
}
'@
SubRx @'
if(!P.arrays)P.arrays=0;   // v6.76: folded racks. Additive, so old saves just have none.
'@ @'
if(!P.arrays)P.arrays=0;   // v6.76: folded racks. Additive, so old saves just have none.
// v11.92: a pocket saved on a grenade or an ammo box protects nothing; cleared so the ascent screen stops saying 1/1.
if(P.safe&&ITEMS[P.safe]&&(ITEMS[P.safe].use==='throw'||ITEMS[P.safe].use==='ammo')) P.safe=null;
'@

# The right-click menu offered the pocket for the same items; a verb the game
# cannot perform is the rule that file states twelve lines above the row.
SubRx @'
  if(it.use!=='gun'){
    var _isSafe=(P.safe===key);
'@ @'
  if(it.use!=='gun'&&it.use!=='throw'&&it.use!=='ammo'){   // v11.92: the pocket refuses these, so the menu does not offer it
    var _isSafe=(P.safe===key);
'@

# STAMPS.
SubRx @'
var VER='11.91';
'@ @'
var VER='11.92';
'@
SubRx @'
var WHATSNEW_VER='11.91';
'@ @'
var WHATSNEW_VER='11.92';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE SAFE POCKET REFUSES A THROWABLE OR AN AMMO BOX. Neither rides in the backpack, so neither could ever come home from it; the pocket said 1/1 anyway.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.91:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.91 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.91:[^']*'",{ param($m) "now:'v11.92: from the 2026-09-06 menu audit, the safe pocket accepted a grenade or an ammo box and read 1/1, but both ride outside the backpack and the death path banks the backpack only, so the one death protection there is was spent on nothing. setSafe refuses throwables and ammunition the way it refuses a gun, and a saved pocket on either is cleared on load. Check 11.92 drives setSafe with a frag, an ammo box and a medkit and the real loader with a saved frag pocket; fails on v11.91.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
