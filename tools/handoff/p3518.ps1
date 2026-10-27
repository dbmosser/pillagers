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

# UNDERCROFT FIXES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  while(_sa&&_sa!==document.body&&_sa.id!=='sectormodal'){ _sk.push([_sa,_sa.scrollTop]); _sa=_sa.parentElement; }
  host.innerHTML=h;
'@ @'
  while(_sa&&_sa!==document.body&&_sa.id!=='sectormodal'){ _sk.push([_sa,_sa.scrollTop]); _sa=_sa.parentElement; }
  var _spl=document.getElementById('sectorplan');   // cw-beltfix (review 10-27): the belt strip lives in this box; without it the list is taller and the restored scroll was clamped
  host.innerHTML=h;
  if(_spl&&_spl.parentNode!==host) host.appendChild(_spl);
'@

SubRx @'
function hubZoomEase(){
'@ @'
function hubZoomEase(){
  var _ht=document.getElementById('title'); if(_ht&&_ht.classList.contains('on')) HZT=1;   // cw-beltfix (review 10-27): the character screen over the floor shows the whole room
'@

SubRx @'
  var ox=Math.round(hubCam(p.x-vw/2,vw,HUBW));
  var oy=Math.round(hubCam(p.y-vh*.55,vh,HUBH));
'@ @'
  var _hsd=S*(DPR||1);   // cw-beltfix (review 10-27): snapped to screen pixels, not room units (up to 2.2 times coarser zoomed in), so walking does not judder
  var ox=Math.round(hubCam(p.x-vw/2,vw,HUBW)*_hsd)/_hsd;
  var oy=Math.round(hubCam(p.y-vh*.55,vh,HUBH)*_hsd)/_hsd;
'@

SubRx @'
  if(typeof hubBagG!=='undefined'&&hubBagG) hubBagG.drag=null;
'@ @'
  if(typeof hubBagG!=='undefined'&&hubBagG) hubBagG.drag=null;
  if(typeof HUBFD!=='undefined') HUBFD=null;   // cw-beltfix (review 10-27): and the floor belt drag with the backpack shut (v35.13)
'@

SubRx @'
    if(!hubBagG) hubBagG=hubBagState();
    hubBagOpen=true;
'@ @'
    if(!hubBagG) hubBagG=hubBagState();
    hubBagOpen=true;
    HUBFD=null;   // cw-beltfix (review 10-27): a floor belt drag held while the backpack opens is let go, not dropped on the next click
'@

SubRx @'
(!hubBagOpen&&HUBFD&&HUBFD.st.drag))){
'@ @'
(!hubBagOpen&&HUBFD&&HUBFD.st.drag&&e.button===0))){   /* cw-beltfix: a right release does not drop the floor belt drag */
'@

SubRx @'
            if(_hb8t&&(_hb8t.k==='gunA'||_hb8t.k==='gunB')&&_hb8t.k!==d.gunSlot){
              var _hb8a=P.equipped, _hb8b=P.equippedSec;
              if(!(_hb8a&&_hb8a!=='fists'&&WEAPONS[_hb8a]&&_hb8b&&_hb8b!=='none'&&_hb8b!=='fists'&&WEAPONS[_hb8b])){ hubToast('ONLY ONE GUN'); return; }
              P.equipped=_hb8b; P.equippedSec=_hb8a;
              G.player=hubBagState().player;
              // v19.18, from the review (2026-10-07): name the key the gun really shows on, as in a raid.
              var _hb8z=hotbarSlots(), _hb8at=-1, _hb8id=d.key.slice(4), _hb8o=(_hb8t&&_hb8t.name)||'the other gun', _hb8q;
              if(_hb8z[_H.i]&&_hb8z[_H.i].kind==='gun'&&_hb8z[_H.i].icon===_hb8id) _hb8at=_H.i;
              else for(_hb8q=0;_hb8q<_hb8z.length;_hb8q++) if(_hb8z[_hb8q]&&_hb8z[_hb8q].kind==='gun'&&_hb8z[_hb8q].icon===_hb8id){ _hb8at=_hb8q; break; }
              blip('pick'); hubToast(((_hb8at>=0)?(_hb8n+' on key '+slotKeyName(_hb8at)+((_hb8at===_H.i)?'':(' \u00b7 swapped with '+_hb8o))):('swapped with '+_hb8o)).toUpperCase());
              return;
            }

'@ @'
            // cw-beltfix (review 10-27, his ask 10-27 "swap them on the hotbar"): the belt places each gun in his hands on its class key,
            // so trading hands (v18.91) left the belt as it was and only changed the gun he ascends holding. The two keys trade, as on the
            // stash screen, and the guns stay in his hands. With one gun the second weapon cell is an empty key and takes it (below).
            var _hb8o2=(_hb8t&&(_hb8t.k==='gunA'||_hb8t.k==='gunB')&&_hb8t.k!==d.gunSlot&&_hb8t.icon&&_hb8t.icon!=='fists'&&WEAPONS[_hb8t.icon])?('gun_'+_hb8t.icon):null;
            if(_hb8o2&&_hb8o2!==d.key){
              G.hotAssign=G.hotAssign||{};
              for(var _hb8k in G.hotAssign) if(G.hotAssign[_hb8k]===d.key||G.hotAssign[_hb8k]===_hb8o2) delete G.hotAssign[_hb8k];
              G.hotAssign[_H.i]=d.key; if(d.fromHot!==undefined&&d.fromHot!==_H.i) G.hotAssign[d.fromHot]=_hb8o2;
              blip('pick'); hubToast((_hb8n+' on key '+slotKeyName(_H.i)+((d.fromHot!==undefined)?(' \u00b7 '+((WEAPONS[_hb8t.icon]&&WEAPONS[_hb8t.icon].name)||'the other gun')+' on key '+slotKeyName(d.fromHot)):'')).toUpperCase());
              return;
            }
'@

SubRx @'
function rackPut(slot,key){
'@ @'
// cw-beltfix (review 10-27): a dimmed gun the stash belt shows by itself (a gun in his hands, no key bound) drags with 'plan:N' since
// v35.13. Only the belt takes it; dropped on the stash, the backpack or DROP HERE it stays in his hands and says where guns are put away.
function ghostGunDrag(key,from){
  if(typeof from!=='string'||from.indexOf('plan:')!==0||String(key).indexOf('gun_')!==0) return false;
  if((P.hotAssign||{})[+from.slice(5)]===key) return false;
  var g=String(key).slice(4); return P.equipped===g||P.equippedSec===g;
}
function rackPut(slot,key){
'@

SubRx @'
      var _bs=+from.slice(5);
      if(!P.hotAssign||P.hotAssign[_bs]!==key){ say2('That item is no longer on that key.'); return; }
'@ @'
      if(ghostGunDrag(key,from)){ say2('unequip in armory'); try{ sfx('clank'); }catch(e){} return; }   // cw-beltfix
      var _bs=+from.slice(5);
      if(!P.hotAssign||P.hotAssign[_bs]!==key){ say2('That item is no longer on that key.'); return; }
'@

SubRx @'
    if(typeof from==='string'&&from.indexOf('plan:')===0){
      var _ps=+from.slice(5);
'@ @'
    if(ghostGunDrag(key,from)){ say2('unequip in armory'); try{ sfx('clank'); }catch(e){} return; }   // cw-beltfix: it never left his hands
    if(typeof from==='string'&&from.indexOf('plan:')===0){
      var _ps=+from.slice(5);
'@

SubRx @'
dropzone(document.getElementById('floordrop'),function(key,from){ if(from==='rack'){
'@ @'
dropzone(document.getElementById('floordrop'),function(key,from){ if(ghostGunDrag(key,from)){ say2('unequip in armory'); try{ sfx('clank'); }catch(e){} return; } /* cw-beltfix */ if(from==='rack'){
'@

SubRx @'
var VER='35.17';
'@ @'
var VER='35.18';
'@

$pat = "(?m)^  now:'v35\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.18: the pack list stays put when you pack a row near the bottom; the character screen shows the whole floor; walking on a zoomed floor is smooth; a floor hotbar drag is let go on alt tab or when the backpack opens; dragging one gun onto the other trades their keys; a dimmed gun dropped off the stash hotbar says unequip in armory Check 35.18 fails on v35.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
