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

# Gun keys renumbered, Rocket class on key 0 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var GUN_CLASSES=['pistol','smg','rifle','carbine','lmg','shotgun','marksman','sniper','energy'];
'@ @'
// v28.xx (cw-gunkeys0), HIS ORDER (2026-10-18): "get rid of the marksman rifle, move everything past it down a number, and then add a rocket launcher as '0'". The
// Marksman class is off the keys: 7 sniper, 8 energy, and the Rocket Launcher class sits on key 0 (the ninth cell, after 8). Key 9 does nothing.
var GUN_CLASSES=['pistol','smg','rifle','carbine','lmg','shotgun','sniper','energy','rocket'];
function slotKeyCode(i){ return i===8?'Digit0':'Digit'+(i+1); }   // v28.xx (cw-gunkeys0): the ninth cell is key 0
function slotKeyName(i){ return i===8?'0':String(i+1); }
function gunKeysMigrate(a){   // a saved table that still holds the Marksman class loses it and gains the Rocket class, so no one's saved order is thrown away
  if(!Array.isArray(a)||a.indexOf('marksman')<0) return a;
  var o=a.filter(function(c){ return c!=='marksman'; });
  if(o.indexOf('rocket')<0) o.push('rocket');
  return o;
}
'@

SubRx @'
dmr:'marksman',whisper:'marksman',
'@ @'

'@

SubRx @'
var src=(typeof P==='object'&&P&&Array.isArray(P.gunKeys))?P.gunKeys:null, ok=
'@ @'
var src=(typeof P==='object'&&P&&Array.isArray(P.gunKeys))?gunKeysMigrate(P.gunKeys):null, ok=
'@

SubRx @'
var dn=parseInt(code.slice(5),10);
    if(dn>=1&&dn<=9){
'@ @'
var dn=(code==='Digit0')?9:parseInt(code.slice(5),10);   // v28.xx (cw-gunkeys0): key 0 is the ninth gun key
    if(dn>=1&&dn<=9&&code!=='Digit9'){
'@

SubRx @'
if(code==='Digit0'||code==='Numpad0'){ setZoom(1);
'@ @'
if(code==='Numpad0'){ setZoom(1);   /* v28.xx (cw-gunkeys0): the 0 key is the Rocket Launcher now, so zoom to 100 is the numpad 0 only */
'@

SubRx @'
['Digit0','zoom to 100%']
'@ @'
['Numpad0','zoom to 100%']
'@

SubRx @'
'NumpadSubtract','Digit0']]];
'@ @'
'NumpadSubtract','Numpad0']]];
'@

SubRx @'
KEYS_FIXED[physical]||/^Digit[1-9]$/.test(physical)
'@ @'
KEYS_FIXED[physical]||/^Digit[0-8]$/.test(physical)
'@

SubRx @'
return '['+keyLabel('Digit'+(gc+1),String(gc+1))+'] GUN';
'@ @'
return '['+keyLabel(slotKeyCode(gc),slotKeyName(gc))+'] GUN';
'@

SubRx @'
String(keyLabel('Digit'+(c.i+1),String(c.i+1))),'SELECT'
'@ @'
String(keyLabel(slotKeyCode(c.i),slotKeyName(c.i))),'SELECT'
'@

SubRx @'
var _hk=String(keyLabel('Digit'+(c.i+1),String(c.i+1)))
'@ @'
var _hk=String(keyLabel(slotKeyCode(c.i),slotKeyName(c.i)))
'@

SubRx @'
keyLabel('Digit'+(_swk+1),String(_swk+1))
'@ @'
keyLabel(slotKeyCode(_swk),slotKeyName(_swk))
'@

SubRx @'
_ptags[l]='SLOT '+(_swk+1);
'@ @'
_ptags[l]='SLOT '+slotKeyName(_swk);
'@

SubRx @'
keyLabel('Digit'+((k<0?1:k)+1),String((k<0?1:k)+1))
'@ @'
keyLabel(slotKeyCode(k<0?1:k),slotKeyName(k<0?1:k))
'@

SubRx @'
(k>=0?'KEY '+(k+1):'BACKPACK')
'@ @'
(k>=0?'KEY '+slotKeyName(k):'BACKPACK')
'@

SubRx @'
_bk=(+_bi)+1;
'@ @'
_bk=slotKeyName(+_bi);
'@

SubRx @'
say('SLOT '+(HC.i+1)+' TAKES GUNS ONLY')
'@ @'
say('SLOT '+slotKeyName(HC.i)+' TAKES GUNS ONLY')
'@

SubRx @'
return {tag:(BELTAT>=0)?('SLOT '+(BELTAT+1)):'BACKPACK',line:''};
'@ @'
return {tag:(BELTAT>=0)?('SLOT '+slotKeyName(BELTAT)):'BACKPACK',line:''};
'@

SubRx @'
function beltTag(){ return (BELTAT>=0)?('SLOT '+(BELTAT+1))
'@ @'
function beltTag(){ return (BELTAT>=0)?('SLOT '+slotKeyName(BELTAT))
'@

SubRx @'
{sub:_rpKy>=0?('SLOT '+(_rpKy+1))
'@ @'
{sub:_rpKy>=0?('SLOT '+slotKeyName(_rpKy))
'@

SubRx @'
ctx.fillText(String(q+1),bx+LH(4)
'@ @'
ctx.fillText(slotKeyName(q),bx+LH(4)
'@

SubRx @'
title="KEY '+(i+1)+' \u00b7 '+GUN_CLASS_NAME[gl[i]]+' \u00b7 DRAG ONTO ANOTHER KEY TO SWAP"><b>'+(i+1)+'</b>
'@ @'
title="KEY '+slotKeyName(i)+' \u00b7 '+GUN_CLASS_NAME[gl[i]]+' \u00b7 DRAG ONTO ANOTHER KEY TO SWAP"><b>'+slotKeyName(i)+'</b>
'@

SubRx @'
marksman:'MARKSMAN',sniper:'SNIPER',energy:'ENERGY'};
'@ @'
sniper:'SNIPER',energy:'ENERGY',rocket:'ROCKET'};
'@

SubRx @'
marksman:'gun_dmr',sniper:'gun_sniper',energy:'gun_lance'};
'@ @'
sniper:'gun_sniper',energy:'gun_lance',rocket:'gun_lance'};
'@

SubRx @'
marksman:'dmr',sniper:'sniper',energy:'lance'}
'@ @'
sniper:'sniper',energy:'lance'}
'@

SubRx @'
var VER='29.14';
'@ @'
var VER='29.15';
'@

$pat = "(?m)^  now:'v29\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.15: Gun keys moved down one past the marksman: 7 sniper, 8 energy. Key 0 is set aside for the Rocket Launcher. Check 29.15 fails on v29.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
