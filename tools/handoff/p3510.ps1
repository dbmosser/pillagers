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

# HOTBAR ITEMS FIXES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
' on key '+(_hb8at+1)+
'@ @'
' on key '+slotKeyName(_hb8at)+
'@

SubRx @'
' on key '+(_hb8h+1)+
'@ @'
' on key '+slotKeyName(_hb8h)+
'@

SubRx @'
' on key '+(d.fromHot+1)).toUpperCase());
'@ @'
' on key '+slotKeyName(d.fromHot)).toUpperCase());
'@

SubRx @'
' on key '+(_H.i+1)+
'@ @'
' on key '+slotKeyName(_H.i)+
'@

SubRx @'
' on key '+(d.fromHot+1)):'')
'@ @'
' on key '+slotKeyName(d.fromHot)):'')
'@

SubRx @'
' to slot '+(_onCell+1)
'@ @'
' to slot '+slotKeyName(_onCell)
'@

SubRx @'
' to slot '+(d.fromHot+1)
'@ @'
' to slot '+slotKeyName(d.fromHot)
'@

SubRx @'
||_dit.name)+' to slot '+(HC.i+1)).toUpperCase(),'info',_gLost?
'@ @'
||_dit.name)+' to slot '+slotKeyName(HC.i)).toUpperCase(),'info',_gLost?
'@

SubRx @'
||_dit.name)+' to slot '+(HC.i+1)).toUpperCase(),'info',_gSub?
'@ @'
||_dit.name)+' to slot '+slotKeyName(HC.i)).toUpperCase(),'info',_gSub?
'@

SubRx @'
' off slot '+(d.fromHot+1)
'@ @'
' off slot '+slotKeyName(d.fromHot)
'@

SubRx @'
' to slot '+(BELTAT+1)
'@ @'
' to slot '+slotKeyName(BELTAT)
'@

SubRx @'
' to slot '+(gi+1)
'@ @'
' to slot '+slotKeyName(gi)
'@

SubRx @'
' to slot '+(at+1)).toUpperCase(); say(txt); return txt;
'@ @'
' to slot '+slotKeyName(at)).toUpperCase(); say(txt); return txt;
'@

SubRx @'
  txt=(it.name+' to slot '+(at+1)).toUpperCase();
  if(!quiet){ say(txt); if(BELTDISP){
'@ @'
  txt=(it.name+' to slot '+slotKeyName(at)).toUpperCase();   // cw-hotfix2: key 0 reads 0
  if(!quiet){ say(txt); if(BELTDISP){
'@

SubRx @'
('Key '+(i+1)+': '+it.name+', click to clear'):(_fg?('Key '+(i+1)+': '+_fg.name):('Key '+(i+1)+', free'))
'@ @'
('Key '+slotKeyName(i)+': '+it.name+', click to clear'):(_fg?('Key '+slotKeyName(i)+': '+_fg.name):('Key '+slotKeyName(i)+', free'))
'@

SubRx @'
font-size:14px">'+(i+1)+'</span>'
'@ @'
font-size:14px">'+slotKeyName(i)+'</span>'
'@

SubRx @'
font-size:12px;color:var(--ash)">'+(i+1)+'</span>':'')
'@ @'
font-size:12px;color:var(--ash)">'+slotKeyName(i)+'</span>':'')
'@

SubRx @'
  el.style.display='';
  el.innerHTML='<div class="srph"><b>belt</b></div>'+hotPlanHTML('sector');
'@ @'
  el.style.display=''; el.setAttribute('data-pan','b');   // cw-hotfix2: the belt is its own pad panel
  el.innerHTML='<div class="srph"><b>belt</b><span id="srplanmsg"></span></div>'+hotPlanHTML('sector');
'@

SubRx @'
    c.onclick=function(){ if((P.hotAssign||{})[ix]!==undefined){ delete P.hotAssign[ix]; saveProfile(); try{ sfx('pick'); }catch(e){} rr(); } else say2('drag an item here'); };
'@ @'
    c.onclick=function(){ if((P.hotAssign||{})[ix]!==undefined){ delete P.hotAssign[ix]; saveProfile(); try{ sfx('pick'); }catch(e){} rr(); return; } if(!padOn()){ say2('drag an item here'); return; } var _pv=Object.keys(P.hotAssign||{}).map(function(q){ return P.hotAssign[q]; }), _pc=packList().filter(function(q){ return /^(throw|med|plate)$/.test(beltClassOf(q))&&_pv.indexOf(q)<0&&beltDropRefusal(q,ix)===''; })[0], _pw; if(!_pc){ say2('drag an item here'); return; } _pw=planPut(ix,_pc); if(_pw){ say2(_pw); try{ sfx('clank'); }catch(e){} return; } saveProfile(); try{ sfx('pick'); }catch(e){} rr(); };   // cw-hotfix2: on a pad, A on an empty key pins the first listed item
'@

SubRx @'
    row.addEventListener('mouseleave',function(){ if(INVHOVER===k) INVHOVER=null; });
  });
}
function syncSectorKit(){
'@ @'
    row.addEventListener('mouseleave',function(){ if(INVHOVER===k) INVHOVER=null; });
  });
  dropzone(sp,function(key,from){ if(typeof from!=='string'||from.indexOf('plan:')!==0) return; var fk=+from.slice(5); if((P.hotAssign||{})[fk]===key){ delete P.hotAssign[fk]; saveProfile(); try{ sfx('pick'); }catch(e){} rr(); } });   // cw-hotfix2: drag a key off onto the pack to clear it
}
function syncSectorKit(){
'@

SubRx @'
// (left and right change a pack row by one); X packs all and Y clears. Panels are marked data-pan: c conditions, k kit, p pack, a ascend.
'@ @'
// (left and right change a pack row by one); X packs all and Y clears. Panels are marked data-pan: c conditions, k kit, p pack, a ascend, b belt.
'@

SubRx @'
  var order=['c','k','p'], cur=PAD.focus, pan=srPan(cur)
'@ @'
  var order=['c','k','p','b'], cur=PAD.focus, pan=srPan(cur)
'@

SubRx @'
    if(mv[1]<0){ sub=list.filter(function(x){ return srPan(x)==='p'; }); if(!sub.length) sub=list.filter(function(x){ return srPan(x)==='k'; }); nx=PAD.srLast&&PAD.srLast.p&&sub.indexOf(PAD.srLast.p)>=0?PAD.srLast.p:sub[sub.length-1]; if(nx) padSetFocus(nx); }
'@ @'
    if(mv[1]<0){ sub=list.filter(function(x){ return srPan(x)==='b'; }); nx=PAD.srLast&&PAD.srLast.b&&sub.indexOf(PAD.srLast.b)>=0?PAD.srLast.b:sub[sub.length-1]; if(!sub.length){ sub=list.filter(function(x){ return srPan(x)==='p'; }); if(!sub.length) sub=list.filter(function(x){ return srPan(x)==='k'; }); nx=PAD.srLast&&PAD.srLast.p&&sub.indexOf(PAD.srLast.p)>=0?PAD.srLast.p:sub[sub.length-1]; } if(nx) padSetFocus(nx); }   // cw-hotfix2: up from ascend reaches the belt
'@

SubRx @'
  if(nx){ padSetFocus(nx); if(!PAD.srLast) PAD.srLast={}; PAD.srLast[pan]=nx; }
  else if(mv[1]>0&&pan!=='c'){
'@ @'
  if(nx){ padSetFocus(nx); if(!PAD.srLast) PAD.srLast={}; PAD.srLast[pan]=nx; }
  else if(mv[1]>0&&pan==='p'&&(sub=list.filter(function(x){ return srPan(x)==='b'; })).length){ nx=PAD.srLast&&PAD.srLast.b&&sub.indexOf(PAD.srLast.b)>=0?PAD.srLast.b:sub[0]; if(!PAD.srLast) PAD.srLast={}; PAD.srLast.p=cur; padSetFocus(nx); }   // cw-hotfix2: the pack runs down into the belt
  else if(mv[1]<0&&pan==='b'&&(sub=list.filter(function(x){ return srPan(x)==='p'; })).length){ nx=PAD.srLast&&PAD.srLast.p&&sub.indexOf(PAD.srLast.p)>=0?PAD.srLast.p:sub[sub.length-1]; if(!PAD.srLast) PAD.srLast={}; PAD.srLast.b=cur; padSetFocus(nx); }
  else if(mv[1]>0&&pan!=='c'){
'@

SubRx @'
function say2(t){ HUBSAY=t; HUBSAY_T=5; hubToast(t); }
'@ @'
function say2(t){ var _sm=document.getElementById('sectormodal'), _pm=document.getElementById('srplanmsg'), _s; if(_sm&&_sm.classList.contains('on')&&_pm){ _s=String(t).toLowerCase(); _pm.textContent=_s; setTimeout(function(){ if(_pm.textContent===_s) _pm.textContent=''; },4000); return; } HUBSAY=t; HUBSAY_T=5; hubToast(t); }   // cw-hotfix2: lift words show by the belt
'@

SubRx @'
document.getElementById('sectordeploy').onclick=function(){
  // v7.42: choosing the sector leads to the loadout question, not straight up.
'@ @'
document.getElementById('sectordeploy').onclick=function(){
  try{ if(HUBTOAST_T) clearTimeout(HUBTOAST_T); HUBTOAST_T=null; HUBTOAST_UNTIL=0; var _ht=document.getElementById('hubtoast'); if(_ht) _ht.classList.remove('on'); }catch(_t){}   // cw-hotfix2: no stale toast after the lift
  // v7.42: choosing the sector leads to the loadout question, not straight up.
'@

SubRx @'
document.getElementById('closesector').onclick=function(){
  document.getElementById('sectormodal').classList.remove('on');
'@ @'
document.getElementById('closesector').onclick=function(){
  try{ if(HUBTOAST_T) clearTimeout(HUBTOAST_T); HUBTOAST_T=null; HUBTOAST_UNTIL=0; var _ht=document.getElementById('hubtoast'); if(_ht) _ht.classList.remove('on'); }catch(_t){}   // cw-hotfix2: no stale toast after the lift
  document.getElementById('sectormodal').classList.remove('on');
'@

SubRx @'
var VER='35.09';
'@ @'
var VER='35.10';
'@

$pat = "(?m)^  now:'v35\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.10: key 0 reads 0; drag a belt key off on the lift; pad reaches the lift belt; lift words show by the belt Check 35.10 fails on v35.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
