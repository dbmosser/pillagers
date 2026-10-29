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

# the hotbar has a 9 key (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var HOTBAR_N=9;
'@ @'
var HOTBAR_N=10; // v28.xx (cw-cx-hotbar9), his order 10-28: the hotbar has a 9 key.
'@

SubRx @'
var GUNKEYS=9;   // v26.xx (wheel4), HIS ORDER 2026-10-14: "Lets ONLY show guns at the bottom of the screen, only 9 of them." Nine gun keys; grenades, heals and plates live on the item wheel (hold Q)
'@ @'
var GUNKEYS=10; // v28.xx (cw-cx-hotbar9): ten assignable cells, keys 1-9 and 0.
'@

SubRx @'
var BELT_CLASS=['gun','gun','gun','gun','gun','gun','gun','gun','gun'];   // v26.xx (wheel4): was four guns, two throwables, two medical and a plate; the items moved to the wheel
'@ @'
var BELT_CLASS=['gun','gun','gun','gun','gun','gun','gun','gun','gun','gun'];   // v26.xx (wheel4): was four guns, two throwables, two medical and a plate; the items moved to the wheel
'@

SubRx @'
#root #hub #hotplanwrap>div>div>div>div:first-child{display:grid!important;grid-template-columns:repeat(9,minmax(0,1fr));gap:8px!important;width:100%;}
'@ @'
#root #hub #hotplanwrap>div>div>div>div:first-child{display:grid!important;grid-template-columns:repeat(10,minmax(0,1fr));gap:8px!important;width:100%;}
'@

SubRx @'
  mig739:1,mig945:1,beltV:5,   // v21.93: beltV, the four-gun belt plan, born set (beltSlidePlan)
'@ @'
  mig739:1,mig945:1,beltV:5,hotbarV:10,   // v21.93: beltV, the four-gun belt plan, born set (beltSlidePlan)
'@

SubRx @'
    var dn=(code==='Digit0')?9:parseInt(code.slice(5),10);   // v28.xx (cw-gunkeys0): key 0 is the ninth gun key
'@ @'
    var dn=(code==='Digit0')?10:parseInt(code.slice(5),10); // v28.xx (cw-cx-hotbar9): 0 is the tenth cell.
'@

SubRx @'
    if(dn>=1&&dn<=9&&code!=='Digit9'){
'@ @'
    if(dn>=1&&dn<=HOTBAR_N){ // v28.xx (cw-cx-hotbar9): 9 is the new cell; 0 remains last.
'@

SubRx @'
function slotKeyCode(i){ return i===8?'Digit0':'Digit'+(i+1); }   // v28.xx (cw-gunkeys0): the ninth cell is key 0
'@ @'
function slotKeyCode(i){ return i===9?'Digit0':'Digit'+(i+1); } // v28.xx (cw-cx-hotbar9): keys 1-9 then 0.
'@

SubRx @'
function slotKeyName(i){ return i===8?'0':String(i+1); }
'@ @'
function slotKeyName(i){ return i===9?'0':String(i+1); }
'@

SubRx @'
var GUN_CLASSES=['pistol','smg','rifle','carbine','lmg','shotgun','sniper','energy','rocket'];
'@ @'
var GUN_CLASSES=['pistol','smg','rifle','carbine','lmg','shotgun','sniper','energy',null,'rocket']; // v28.xx (cw-cx-hotbar9): key 9 starts without a class; rocket keeps 0.
'@

SubRx @'
// Marksman class is off the keys: 7 sniper, 8 energy, and the Rocket Launcher class sits on key 0 (the ninth cell, after 8). Key 9 does nothing.
'@ @'
// v28.xx (cw-cx-hotbar9): 7 sniper, 8 energy, 9 unassigned, 0 rocket launcher; old assignments keep their printed key.
'@

SubRx @'
function gunKeysMigrate(a){   // a saved table that still holds the Marksman class loses it and gains the Rocket class, so no one's saved order is thrown away
  if(!Array.isArray(a)||a.indexOf('marksman')<0) return a;
  var o=a.filter(function(c){ return c!=='marksman'; });
  if(o.indexOf('rocket')<0) o.push('rocket');
  return o;
}
'@ @'
// v28.xx (cw-cx-hotbar9): retain the saved class order, including the class on key 0.
function gunKeysMigrate(a){
  if(!Array.isArray(a)) return a;
  var o=a.slice();
  if(o.indexOf('marksman')>=0){ o=o.filter(function(c){ return c!=='marksman'; }); if(o.indexOf('rocket')<0) o.push('rocket'); }
  if(o.length===9) o.splice(8,0,null);
  return o;
}
'@

SubRx @'
function applyLoadedProfile(r){
'@ @'
// v28.xx (cw-cx-hotbar9), his order 10-28: add 9 between 8 and 0; never move an existing key 0 assignment to 9.
function hotbarProfileTen(p){
  if(!p||typeof p!=='object'||p.hotbarV===10) return;
  [p.hotAssign,p.hotBeforeFree,p.kitSaved&&p.kitSaved.hot].forEach(function(h){
    if(!h||typeof h!=='object') return;
    if(Object.prototype.hasOwnProperty.call(h,8)){ h[9]=h[8]; delete h[8]; }
    if(Array.isArray(h)&&h.length===9) h.length=10;
  });
  if(Array.isArray(p.gunKeys)) p.gunKeys=gunKeysMigrate(p.gunKeys);
  if(p.keymap&&typeof p.keymap==='object') for(var k in p.keymap) if(Object.prototype.hasOwnProperty.call(p.keymap,k)&&p.keymap[k]==='Digit9') delete p.keymap[k];
  if(typeof KEYS==='object'&&KEYS) KEYS.inv=null;
  p.hotbarV=10;
}
function applyLoadedProfile(r){
'@

SubRx @'
  if(!P.menuZoom) P.menuZoom=1.3;
'@ @'
  hotbarProfileTen(P); // v28.xx (cw-cx-hotbar9): loaded and first-run profiles share the same in-place stamp.
  if(!P.menuZoom) P.menuZoom=1.3;
'@

SubRx @'
  var d=(ev.key==='0')?8:ev.key.charCodeAt(0)-49;                 // v31.xx (cw-gunkeys19): '1' -> 0 up to '8' -> 7, and '0' is the ninth gun key (the rocket launcher, cw-gunkeys0); '9' does nothing
'@ @'
  var d=(ev.key==='0')?9:ev.key.charCodeAt(0)-49; // v28.xx (cw-cx-hotbar9): stash digits follow the ten-cell belt.
'@

SubRx @'
  if(ev.key.length!==1||d<0||d>8||ev.key==='9') return;
'@ @'
  if(ev.key.length!==1||!/^[0-9]$/.test(ev.key)||d<0||d>=HOTBAR_N) return; // v28.xx (cw-cx-hotbar9): all ten stash digit keys.
'@

SubRx @'
        <div><kbd>1-8, 0</kbd> bind to key</div>
'@ @'
        <div><kbd>1-9, 0</kbd> bind to key</div>
'@

SubRx @'
  if(KEYS_FIXED[physical]||/^Digit[0-8]$/.test(physical)){ KEYS.note={t:'clash',s:keyName(physical)+' KEEPS ITS OWN JOB. ESC, TAB, P, BACKSPACE, F9, F11, THE KEY LEFT OF 1, 1-8 AND 0 CANNOT BE REBOUND.'}; return false; }   // v25.xx (keyremap): the pause key and its kin are reserved
'@ @'
  if(KEYS_FIXED[physical]||/^Digit[0-9]$/.test(physical)){ KEYS.note={t:'clash',s:keyName(physical)+' KEEPS ITS OWN JOB. ESC, TAB, P, BACKSPACE, F9, F11, THE KEY LEFT OF 1, 1-9 AND 0 CANNOT BE REBOUND.'}; return false; }   // v25.xx (keyremap): the pause key and its kin are reserved
'@

SubRx @'
var KEYS_LOCKED=[['SELECT A GUN','1 - 8, 0'],['PAUSE','P'],['PAUSE, OR BACK OUT','TAB'],['CLOSE A WINDOW','ESC'],['PUT THE CURSOR BACK','BACKSPACE'],['timelord mode','LEFT OF 1'],['FULLSCREEN','F11']];
'@ @'
var KEYS_LOCKED=[['SELECT A GUN','1 - 9, 0'],['PAUSE','P'],['PAUSE, OR BACK OUT','TAB'],['CLOSE A WINDOW','ESC'],['PUT THE CURSOR BACK','BACKSPACE'],['timelord mode','LEFT OF 1'],['FULLSCREEN','F11']];
'@

SubRx @'
    s('ControlLeft')+' / '+s('KeyC')+' crouch toggle &nbsp; '+s('KeyE')+' search / use &nbsp; '+s('KeyX')+' extraction &nbsp; '+s('KeyR')+' reload &nbsp; '+s('KeyV')+' melee &nbsp; '+s('KeyQ')+' item wheel (hold) &nbsp; '+s('KeyF')+' next gun &nbsp; '+k('1-8, 0')+' guns &nbsp; '+s('KeyB')+' / '+s('KeyI')+' backpack &nbsp; '+
'@ @'
    s('ControlLeft')+' / '+s('KeyC')+' crouch toggle &nbsp; '+s('KeyE')+' search / use &nbsp; '+s('KeyX')+' extraction &nbsp; '+s('KeyR')+' reload &nbsp; '+s('KeyV')+' melee &nbsp; '+s('KeyQ')+' item wheel (hold) &nbsp; '+s('KeyF')+' next gun &nbsp; '+k('1-9, 0')+' guns &nbsp; '+s('KeyB')+' / '+s('KeyI')+' backpack &nbsp; '+
'@

SubRx @'
  return cls==='gun'?'GUNS GO ON KEYS 1 TO 8 AND 0':'ITEMS GO ON THE WHEEL';   // v31.xx (cw-gunkeys19): the gun keys are 1 to 8 and 0 (key 9 does nothing); the other two refusals say this word too   // v26.xx (wheel4): the belt takes guns only
'@ @'
  return cls==='gun'?'GUNS GO ON KEYS 1 TO 9 AND 0':'ITEMS GO ON THE WHEEL';   // v31.xx (cw-gunkeys19): the gun keys are 1 to 8 and 0 (key 9 is assignable); the other two refusals say this word too   // v26.xx (wheel4): the belt takes guns only
'@

SubRx @'
  ['GEAR',[['1-8, 0','a gun for each kind, set in the stash'],['HOLD Q','item wheel: aim at a grenade, heal or plate and let go'],['FIRE','use the item in hand, or fire'],['B / I','backpack'],['ENTER','equip gun from backpack'],['BKSP','reset cursor']]],
'@ @'
  ['GEAR',[['1-9, 0','a gun for each kind, set in the stash'],['HOLD Q','item wheel: aim at a grenade, heal or plate and let go'],['FIRE','use the item in hand, or fire'],['B / I','backpack'],['ENTER','equip gun from backpack'],['BKSP','reset cursor']]],
'@

SubRx @'
  ['1-8, 0','guns'],['B / I','backpack'],['LMB','use item'],['M','map'],
'@ @'
  ['1-9, 0','guns'],['B / I','backpack'],['LMB','use item'],['M','map'],
'@

SubRx @'
  ['WEAPONS','keys 1 to 8 and 0 bring up'],
'@ @'
  ['WEAPONS','keys 1 to 9 and 0 bring up'],
'@

SubRx @'
          say2(padOn()?padB('TACTICAL BELT \u00b7 PICK UP AN ITEM WITH A, THEN A HERE'):'TACTICAL BELT \u00b7 HOVER AN ITEM + PRESS 1-8 OR 0');   // v22.51: the shooter HUD voice, his name for the belt kept (v10.26)   // v16.80: a pad player is told the pad way
'@ @'
          say2(padOn()?padB('TACTICAL BELT \u00b7 PICK UP AN ITEM WITH A, THEN A HERE'):'TACTICAL BELT \u00b7 HOVER AN ITEM + PRESS 1-9 OR 0');   // v22.51: the shooter HUD voice, his name for the belt kept (v10.26)   // v16.80: a pad player is told the pad way
'@

SubRx @'
    ['RELOAD',kn('KeyR'),padB(pbn(2))],['SWITCH GUN','1-8, 0',padB(pbn(4))+' / '+padB(pbn(5))],['ITEMS','HOLD '+kn('KeyQ'),'HOLD '+padB(pbn(13))],   // v23.46 (arcade23): the quick heal
'@ @'
    ['RELOAD',kn('KeyR'),padB(pbn(2))],['SWITCH GUN','1-9, 0',padB(pbn(4))+' / '+padB(pbn(5))],['ITEMS','HOLD '+kn('KeyQ'),'HOLD '+padB(pbn(13))],   // v23.46 (arcade23): the quick heal
'@

SubRx @'
    if(!G.sim) say(('Gun slot '+(i+1)+' empty').toUpperCase());
'@ @'
    if(!G.sim) say(('Gun slot '+slotKeyName(i)+' empty').toUpperCase());
'@

SubRx @'
  if(s2.vacant){ if(!G.sim) say(('Gun slot '+(i+1)+' empty').toUpperCase()); _hinted=true; }   // v14.09, HUD audit: not written over by the cell line below
'@ @'
  if(s2.vacant){ if(!G.sim) say(('Gun slot '+slotKeyName(i)+' empty').toUpperCase()); _hinted=true; }   // v14.09, HUD audit: not written over by the cell line below
'@

SubRx @'
  for(i=0;i<gl.length;i++) h+='<div class="kst" data-gk="'+i+'" title="KEY '+slotKeyName(i)+' \u00b7 '+GUN_CLASS_NAME[gl[i]]+' \u00b7 DRAG ONTO ANOTHER KEY TO SWAP"><b>'+slotKeyName(i)+'</b>'+iconImgHTML(GUN_CLASS_ICON[gl[i]],30,1)+'<span>'+GUN_CLASS_NAME[gl[i]]+'</span></div>';
'@ @'
  for(i=0;i<gl.length;i++) h+='<div class="kst" data-gk="'+i+'" title="KEY '+slotKeyName(i)+' \u00b7 '+GUN_CLASS_NAME[gl[i]]+' \u00b7 DRAG ONTO ANOTHER KEY TO SWAP"><b>'+slotKeyName(i)+'</b>'+(gl[i]?iconImgHTML(GUN_CLASS_ICON[gl[i]],30,1):'')+'<span>'+GUN_CLASS_NAME[gl[i]]+'</span></div>';
'@

SubRx @'
var GUN_CLASS_NAME={pistol:'PISTOL',smg:'SMG',rifle:'RIFLE',carbine:'CARBINE',lmg:'LMG',shotgun:'SHOTGUN',sniper:'SNIPER',energy:'ENERGY',rocket:'ROCKET'};
'@ @'
var GUN_CLASS_NAME={pistol:'PISTOL',smg:'SMG',rifle:'RIFLE',carbine:'CARBINE',lmg:'LMG',shotgun:'SHOTGUN',sniper:'SNIPER',energy:'ENERGY',rocket:'ROCKET',null:'empty'};
'@

SubRx @'
      s=+from.slice(3); if(!(s>=0&&s<9)||s===ix) return;
'@ @'
      s=+from.slice(3); if(!(s>=0&&s<gl.length)||s===ix) return; // v28.xx (cw-cx-hotbar9): class swaps include key 0 and the empty key 9.
'@

SubRx @'
  var sl=hotbarSlots(), n=sl.length, i=hotSel(), k;
'@ @'
  var sl=hotbarSlots(), n=sl.length, i=(G.player&&G.player.hand&&G.player.hand.slot!==undefined)?G.player.hand.slot:hotSel(), k;
'@

SubRx @'
  for(k=0;k<n;k++){ i=(i+dir+n)%n; if(!(sl[i]&&(sl[i].vacant||sl[i].kind==='empty'||(i<GUNKEYS&&sl[i].kind!=='gun')))) break; }   // v25.xx (belt7): and a key with nothing on it (a throwable, medical or armour key with none of its kind); cw-hotfix1: and an item he put on a gun key
'@ @'
  for(k=0;k<n;k++){ i=(i+dir+n)%n; if(!(sl[i]&&(sl[i].vacant||sl[i].kind==='empty'))) break; }   // v25.xx (belt7): and a key with nothing on it (a throwable, medical or armour key with none of its kind); cw-hotfix1: and an item he put on a gun key
'@

SubRx @'
  if(bagGunCell(sl[i])){
'@ @'
  if(sl[i]&&/^(throw|heal|stim|armor)$/.test(sl[i].kind)){ beltEquip(i); return; } // v28.xx (cw-cx-hotbar9): pad bumpers can reach an item on 9 as well as a gun.
  if(bagGunCell(sl[i])){
'@

SubRx @'
var VER='36.36';
'@ @'
var VER='36.37';
'@

$pat = "(?m)^  now:'v36\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.37: the hotbar has a 9 key Check 36.37 fails on v36.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
