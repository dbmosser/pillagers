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

# Ctrl drag asks how many to move (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
GRAB={key:key,from:from,el:el,x:ev.clientX,y:ev.clientY}; GRABSKIP=null;
'@ @'
GRAB={key:key,from:from,el:el,x:ev.clientX,y:ev.clientY,ctrl:!!(ev.ctrlKey||ev.metaKey)}; GRABSKIP=null;   // v28.xx (cw-stashqty): Ctrl held at the press counts too
'@

SubRx @'
  if(z&&typeof z.__grabDrop==='function') z.__grabDrop(held.key,held.from);
});
function renderStage(prefill){
'@ @'
  // v28.xx (cw-stashqty), HIS NOTE (2026-10-18): "in the stash, if I ctrl drag an item to the backpack, i should get a prompt asking me how many
  // I want to transfer". Ctrl and a drag of a stack, stash to backpack or back, asks how many (qtyAsk). A plain drag is unchanged.
  if(held.moved&&(ev.ctrlKey||ev.metaKey||held.ctrl)&&z&&typeof qtyDrag==='function'){ var _qd=false; try{ _qd=qtyDrag(held.key,held.from,z); }catch(_qe){} if(_qd) return; }
  if(z&&typeof z.__grabDrop==='function') z.__grabDrop(held.key,held.from);
});
function renderStage(prefill){
'@

SubRx @'
document.addEventListener('mousemove',function(ev){
  if(!GRAB) return;
'@ @'
// v28.xx (cw-stashqty), HIS NOTE (2026-10-18): "in the stash, if I ctrl drag an item to the backpack, i should get a prompt asking me how many
// I want to transfer". The prompt: a number and a slider with the most preselected, - and + and Half and All buttons for a pad, Enter moves, Esc cancels.
var QTY=null;
function qtyOpen(){ return !!(QTY&&QTY.md&&QTY.md.classList.contains('on')); }
function qtyClose(){ if(QTY&&QTY.md) QTY.md.classList.remove('on'); }
function qtyVal(){ var v=Math.round(+(QTY.num.value)||0); return Math.max(1,Math.min(QTY.max,v)); }
function qtySet(v){ if(!QTY) return; v=Math.max(1,Math.min(QTY.max,Math.round(+v||0))); QTY.num.value=v; QTY.rng.value=v; }
function qtyGo(){
  if(!qtyOpen()) return;
  var n=qtyVal(), fn=QTY.fn; qtyClose();
  try{ if(fn) fn(n); }catch(_qg){}
}
function qtyAsk(title,name,max,fn){
  var md=document.getElementById('qtymodal'), root=document.getElementById('root')||document.body;
  if(!md){
    md=document.createElement('div'); md.className='modal'; md.id='qtymodal';
    md.style.cssText='z-index:80;align-items:center;justify-content:center';
    md.innerHTML='<div class="panel" style="min-width:340px;max-width:92%;padding:18px 22px;text-align:center">'+
      '<h3 id="qtyh" style="justify-content:center;font-size:24px"></h3><div class="msub" id="qtyname" style="margin-bottom:10px"></div>'+
      '<div style="display:flex;gap:8px;justify-content:center;align-items:center;margin-bottom:10px">'+
      '<button id="qtym" style="padding:4px 14px">-</button><input id="qtyn" type="number" min="1" step="1" style="width:84px;text-align:center;font-size:18px">'+
      '<button id="qtyp" style="padding:4px 14px">+</button></div>'+
      '<input id="qtyr" type="range" min="1" step="1" style="margin-bottom:12px">'+
      '<div style="display:flex;gap:8px;justify-content:center"><button id="qtyhalf">Half</button><button id="qtyall">All</button>'+
      '<button id="qtyok">Move</button><button id="qtyno">Cancel</button></div></div>';
    root.appendChild(md);
  }
  QTY={md:md,max:Math.max(1,max|0),fn:fn,num:document.getElementById('qtyn'),rng:document.getElementById('qtyr')};
  document.getElementById('qtyh').textContent=title;
  document.getElementById('qtyname').textContent=name+'  x'+QTY.max;
  QTY.num.max=QTY.max; QTY.rng.max=QTY.max;
  QTY.num.oninput=function(){ if(QTY) QTY.rng.value=qtyVal(); };
  QTY.num.onchange=function(){ if(QTY) qtySet(qtyVal()); };
  QTY.rng.oninput=function(){ if(QTY) QTY.num.value=QTY.rng.value; };
  document.getElementById('qtym').onclick=function(){ qtySet(qtyVal()-1); };
  document.getElementById('qtyp').onclick=function(){ qtySet(qtyVal()+1); };
  document.getElementById('qtyhalf').onclick=function(){ qtySet(Math.max(1,Math.floor(QTY.max/2))); };
  document.getElementById('qtyall').onclick=function(){ qtySet(QTY.max); };
  document.getElementById('qtyok').onclick=function(){ qtyGo(); };
  document.getElementById('qtyno').onclick=function(){ qtyClose(); };
  qtySet(QTY.max);
  md.classList.add('on');
  try{ QTY.num.focus(); QTY.num.select(); }catch(_qf){}
}
try{ window.addEventListener('keydown',function(ev){
  if(!qtyOpen()) return;
  var c=ev.code, t=ev.target, isBtn=!!(t&&t.tagName==='BUTTON');
  if(c==='Escape'){ ev.preventDefault(); ev.stopImmediatePropagation(); qtyClose(); return; }
  if((c==='Enter'||c==='NumpadEnter')&&!isBtn){ ev.preventDefault(); ev.stopImmediatePropagation(); qtyGo(); return; }
  if(c==='ArrowLeft'||c==='ArrowDown'){ ev.preventDefault(); ev.stopImmediatePropagation(); qtySet(qtyVal()-1); return; }
  if(c==='ArrowRight'||c==='ArrowUp'){ ev.preventDefault(); ev.stopImmediatePropagation(); qtySet(qtyVal()+1); return; }
  if(c==='Tab'){ ev.stopImmediatePropagation(); return; }
  ev.stopImmediatePropagation();   // no game key reaches the screen behind the prompt
},true); }catch(_qk){}
// What the backpack grid shows of one item: packed copies, less one per belt key on it (renderKitCol's rule).
function kitShownCount(key){
  var K=stageKitLive(), ha=P.hotAssign||{}, sk, kk, at, c=0, i;
  for(sk in ha){ kk=ha[sk]; if(!kk) continue;
    if(kk.indexOf('gun_')===0&&(P.equipped===kk.slice(4)||P.equippedSec===kk.slice(4))) continue;
    at=K.indexOf(kk); if(at>=0) K.splice(at,1); }
  for(i=0;i<K.length;i++) if(K[i]===key) c++;
  return c;
}
// Ctrl drag of a stack: true when it opened the prompt, false to let the plain drop run (one item, or a refusal to word).
function qtyDrag(key,from,z){
  var it=ITEMS[key], max, bq, onKey=false;
  if(!it||!z||!P) return false;
  if(from==='stash'&&z.id==='kitcol'){
    max=Math.min(DEPLOY_SLOTS-stageKitLive().length,heldCount(key)-packedCount(key));
    for(bq in (P.hotAssign||{})) if(P.hotAssign[bq]===key) onKey=true;
    if(onKey&&packedCount(key)<1) return false;   // the belt route of the plain drop
    if(max<2) return false;
    qtyAsk('Move to backpack',it.name,max,function(n){
      var room=Math.min(n,DEPLOY_SLOTS-stageKitLive().length,heldCount(key)-packedCount(key));
      if(room<1){ say2('Backpack is full.'); return; }
      packSome(key,room);
      try{ sfx('pick'); }catch(_s){}
      say2('Moved '+room+' '+it.name+' to the backpack.');
      refreshInv();
    });
    return true;
  }
  if(from==='kit'&&z.id==='stashgrid'){
    max=kitShownCount(key);
    if(max<2) return false;
    qtyAsk('Move to stash',it.name,max,function(n){
      var have=Math.min(n,kitShownCount(key));
      if(have<1) return;
      unpackSome(key,have);
      try{ sfx('pick'); }catch(_s){}
      say2('Moved '+have+' '+it.name+' to the stash.');
      refreshInv();
    });
    return true;
  }
  return false;
}
document.addEventListener('mousemove',function(ev){
  if(!GRAB) return;
'@

SubRx @'
var VER='29.09';
'@ @'
var VER='29.10';
'@

$pat = "(?m)^  now:'v29\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.10: Ctrl and drag a stack between the stash and the backpack to choose how many move. Enter confirms, Esc cancels. Check 29.10 fails on v29.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
