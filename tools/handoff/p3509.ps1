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

# HOTBAR ITEMS FOLLOW-UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function setHot(i){
  if(G&&G.player&&G.player.hand) handCancel(G.player);   // v26.xx (wheel3): a gun key puts the item away with no use
'@ @'
function setHot(i){
  if(G&&!G.hubFloor){ var _hs=hotbarSlots(); if(i>=0&&i<GUNKEYS&&_hs[i]&&/^(throw|heal|stim|armor)$/.test(_hs[i].kind)) return; }   // cw-hotfix1: an item he put on a gun key never takes the highlight (its key and a click use it)
  if(G&&G.player&&G.player.hand) handCancel(G.player);   // v26.xx (wheel3): a gun key puts the item away with no use
'@

SubRx @'
  for(k=0;k<n;k++){ i=(i+dir+n)%n; if(!(sl[i]&&(sl[i].vacant||sl[i].kind==='empty'))) break; }   // v25.xx (belt7): and a key with nothing on it (a throwable, medical or armour key with none of its kind)
'@ @'
  for(k=0;k<n;k++){ i=(i+dir+n)%n; if(!(sl[i]&&(sl[i].vacant||sl[i].kind==='empty'||(i<GUNKEYS&&sl[i].kind!=='gun')))) break; }   // v25.xx (belt7): and a key with nothing on it (a throwable, medical or armour key with none of its kind); cw-hotfix1: and an item he put on a gun key
'@

SubRx @'
  for(j in P.hotAssign) if(ITEMS[P.hotAssign[j]]&&ITEMS[P.hotAssign[j]].use==='gun') delete P.hotAssign[j];
  P.equipped='fists'; P.equippedSec='none';
'@ @'
  for(j in P.hotAssign) if(ITEMS[P.hotAssign[j]]&&ITEMS[P.hotAssign[j]].use==='gun') delete P.hotAssign[j];
  for(j in P.hotAssign) if(ITEMS[P.hotAssign[j]]&&/^(throw|med|plate)$/.test(beltClassOf(P.hotAssign[j]))) used[+j]=1;   // cw-hotfix1: a gun never takes a key he gave an item
  P.equipped='fists'; P.equippedSec='none';
'@

SubRx @'
        else if(S.kind==='armor'&&(S.count|0)>0){ _cc='KeyH'; _cpre='HOLD '; }
'@ @'
        else if(S.kind==='armor'&&(S.count|0)>0&&q>=GUNKEYS){ _cc='KeyH'; _cpre='HOLD '; }   // cw-hotfix1: not on a plate he put on a number key
'@

SubRx @'
function gunCell(){
  var i=heldGunCell(hotbarSlots());
  return i<0?0:i;
}
'@ @'
function gunCell(){
  var sl=hotbarSlots(), i=heldGunCell(sl), j;
  if(i>=0) return i;
  if(sl[0]&&/^(throw|heal|stim|armor)$/.test(sl[0].kind)){   // cw-hotfix1: never an item he put on key 1
    for(j=0;j<sl.length&&j<GUNKEYS;j++) if(sl[j]&&sl[j].kind==='gun'&&!sl[j].vacant) return j;
    for(j=0;j<sl.length&&j<GUNKEYS;j++) if(sl[j]&&!/^(throw|heal|stim|armor)$/.test(sl[j].kind)) return j;
  }
  return 0;
}
'@

SubRx @'
        G.hot=(ITEMS[d.key]&&ITEMS[d.key].use==='gun')?HC.i:gunCell();   // cw-hotitems: an item on a key leaves the gun in his hands selected
'@ @'
        if(ITEMS[d.key]&&ITEMS[d.key].use==='gun') G.hot=HC.i; else { var _hg=heldGunCell(hotbarSlots()); if(_hg>=0) G.hot=_hg; else if(hotbarSlots()[G.hot]&&/^(throw|heal|stim|armor)$/.test(hotbarSlots()[G.hot].kind)) G.hot=gunCell(); }   // cw-hotitems + cw-hotfix1: an item on a key leaves the gun in his hands selected
'@

SubRx @'
      delete G.hotAssign[d.fromHot];
      if(G.hotAuto) delete G.hotAuto[d.fromHot];
'@ @'
      delete G.hotAssign[d.fromHot];
      if(G.hotAuto) delete G.hotAuto[d.fromHot];
      if(G.hot===d.fromHot) G.hot=gunCell();   // cw-hotfix1
'@

SubRx @'
function syncSectorKit(){
  var el=document.getElementById('sectorkit');
  if(!el) return;
  try{ syncSectorPack(); }catch(_sp){}   // v28.xx (cw-preraid)
'@ @'
// cw-hotfix1: THE BELT ON THE LIFT SCREEN. v35.08 put the belt plan on the ascent check, a screen that no longer opens; the live
// pre-raid screen is the lift. A strip of the nine number keys under the pack list: drag a pack row's name or icon onto a key,
// drag a key off or click it to clear it, drag one key onto another to trade, or hover a row and press its number.
// Same rules as the stash plan (planPut and rackPut).
function syncSectorPlan(){
  var sp=document.getElementById('sectorpack'), el=document.getElementById('sectorplan'), rr;
  if(!sp) return;
  if(!el){ el=document.createElement('div'); el.id='sectorplan'; el.style.flex='0 0 auto'; }
  if(el.parentNode!==sp) sp.appendChild(el);   // inside the pack box, so the ascend plate keeps its one column gap (34.84)
  if(kitPickOf()!=='mine'){ el.style.display='none'; el.innerHTML=''; return; }
  el.style.display='';
  el.innerHTML='<div class="srph"><b>belt</b></div>'+hotPlanHTML('sector');
  rr=function(){ try{ syncSectorKit(); }catch(_r1){} try{ refreshInv(); }catch(_r2){} };
  Array.prototype.forEach.call(el.querySelectorAll('[data-plan]'),function(c){
    var ix=+c.getAttribute('data-plan'), pk=(P.hotAssign||{})[ix];
    c.onclick=function(){ if((P.hotAssign||{})[ix]!==undefined){ delete P.hotAssign[ix]; saveProfile(); try{ sfx('pick'); }catch(e){} rr(); } else say2('drag an item here'); };
    if(pk&&ITEMS[pk]) grabbable(c,pk,'plan:'+ix,ITEMS[pk].name);
    dropzone(c,function(key,from){
      if(from==='plan:'+ix){ if(P.hotAssign) delete P.hotAssign[ix]; saveProfile(); try{ sfx('pick'); }catch(e){} rr(); return; }
      var _fk=(typeof from==='string'&&from.indexOf('plan:')===0)?+from.slice(5):-1;
      var _was=(P.hotAssign||{})[ix];
      var _inHand=(_fk>=0&&String(key).indexOf('gun_')===0&&(P.equipped===String(key).slice(4)||P.equippedSec===String(key).slice(4)));
      if(!_inHand&&_fk>=0&&String(key).indexOf('gun_')===0&&(P.weapons||[]).indexOf(String(key).slice(4))>=0&&heldCount(key)===0) _inHand=true;
      var why=(from==='rack'||_inHand)?rackPut(ix,key):planPut(ix,key);
      if(why){ say2(why); try{ sfx('clank'); }catch(e){} return; }
      if(_fk>=0&&_was&&_was!==key){ P.hotAssign[_fk]=_was; saveProfile(); }
      try{ sfx('pick'); }catch(e){}
      rr();
    });
  });
  Array.prototype.forEach.call(sp.querySelectorAll('.srprow[data-pk]'),function(row){
    var k=row.getAttribute('data-pk');
    if(!k||!ITEMS[k]) return;
    Array.prototype.forEach.call(row.querySelectorAll('.nm,svg'),function(x){ grabbable(x,k,'kit',ITEMS[k].name); });
    row.addEventListener('mouseenter',function(){ INVHOVER=k; });
    row.addEventListener('mouseleave',function(){ if(INVHOVER===k) INVHOVER=null; });
  });
}
function syncSectorKit(){
  var el=document.getElementById('sectorkit');
  if(!el) return;
  try{ syncSectorPack(); }catch(_sp){}   // v28.xx (cw-preraid)
  try{ syncSectorPlan(); }catch(_spl){}   // cw-hotfix1: the belt plan on the lift screen
'@

SubRx @'
  var _ihHub=document.getElementById('hub'), _ihStg=document.getElementById('stagemodal');
  if(!((_ihHub&&_ihHub.classList.contains('on'))||(_ihStg&&_ihStg.classList.contains('on')))){ INVHOVER=null; return; }
'@ @'
  var _ihHub=document.getElementById('hub'), _ihStg=document.getElementById('stagemodal'), _ihSec=document.getElementById('sectormodal');   // cw-hotfix1: and the lift screen
  if(!((_ihHub&&_ihHub.classList.contains('on'))||(_ihStg&&_ihStg.classList.contains('on'))||(_ihSec&&_ihSec.classList.contains('on')))){ INVHOVER=null; return; }
'@

SubRx @'
  renderHub(); renderStage();
});
'@ @'
  renderHub(); renderStage(); try{ syncSectorKit(); }catch(_sk){}   // cw-hotfix1
});
'@

SubRx @'
var VER='35.08';
'@ @'
var VER='35.09';
'@

$pat = "(?m)^  now:'v35\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.09: the lift screen shows the belt; drag from the pack list or press a number while hovering; an item key never steals the highlight Check 35.09 fails on v35.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
