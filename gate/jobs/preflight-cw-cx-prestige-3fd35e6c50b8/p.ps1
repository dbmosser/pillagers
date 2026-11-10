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

# LEVEL 20 PRESTIGE ROSTER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
mig0p:1,lifeEarn:0,mig1x:1,mig2n:1,
'@ @'
mig0p:1,lifeEarn:0,mig1x:1,mig2n:1,mig8p:1,roster:[],pilRest:null,
'@

SubRx @'
          try{ seasonZeroMig(P); }catch(_szm){}
'@ @'
          try{ seasonZeroMig(P); }catch(_szm){}
          pilRosterClean(P);   // v28.xx (cw-cx-prestige): old saves get an empty roster, once, without moving account contents.
'@

SubRx @'
  if(!Array.isArray(p.hall)) p.hall=[];
  if(typeof p.lifeEarn
'@ @'
  if(!Array.isArray(p.hall)) p.hall=[];
  pilRosterClean(p);   // v28.xx (cw-cx-prestige): additive save repair, no account rewards or gear moved.
  if(typeof p.lifeEarn
'@

SubRx @'
if(p.hall.length) p.pil=null; else
'@ @'
if(p.hall.length||p.roster.length||p.pilRest) p.pil=null; else
'@

SubRx @'
function pilNow(){ return acctEnsure(P); }
'@ @'
// v28.xx (cw-cx-prestige), answer 32: only level 20, three prestige lives, level and picks kept. Benching never ends a life.
function pilRosterClean(p){
  if(!Array.isArray(p.roster)) p.roster=[];
  p.roster=p.roster.filter(function(r){ return r&&typeof r==='object'&&!Array.isArray(r)&&r.prestige===1&&r.lvl===20&&!r.end; });
  p.roster.forEach(function(r){ pilClean(r); });
  if(!p.pilRest||typeof p.pilRest!=='object'||Array.isArray(p.pilRest)||p.pilRest.end) p.pilRest=null;
  else pilClean(p.pilRest);
  p.mig8p=1;
}
function pilRosterCount(){ return P.roster.length+((P.pil&&P.pil.prestige===1)?1:0); }
function pilPrestigeOk(){ var q=pilNow(); return !!(pilHome()&&q&&q.lvl===20&&!q.prestige&&pilRosterCount()<3); }
function pilPrestige(){
  var q,i;
  if(!pilPrestigeOk()) return null;
  q=P.pil; q.prestige=1;
  for(i=0;i<WORN_SLOTS.length;i++) wornOff(P,WORN_SLOTS[i]);
  P.roster.push(q); P.pil=null; delete P.heirs; pilHeirs(P); BIRTH=null;
  saveProfile(); document.getElementById('opmodal').classList.remove('on'); birthOpen();
  return q;
}
function pilPrestigeAsk(){
  if(!pilPrestigeOk()) return;
  document.getElementById('askq').textContent='prestige '+pilName(P.pil)+'?';
  document.getElementById('asksub').textContent='level 20 kept / gear to stash / new heir';
  ASKYES=pilPrestige; ASKALT=null; ASKBACK='opmodal'; kitExtraHide();
  document.getElementById('askyes').textContent='prestige'; document.getElementById('askalt').style.display='none'; document.getElementById('askno').textContent='not yet';
  openModal('askmodal'); try{ if(padOn()) padSetFocus(document.getElementById('askno')); }catch(_psa){}
}
// v28.xx (cw-cx-prestige): the ordinary heir rests separately, never occupies a prestige slot, and is restored after a veteran ends.
function pilRestRestore(p){ if(!p.pil&&p.pilRest){ p.pil=p.pilRest; p.pilRest=null; delete p.heirs; return true; } return false; }
function pilRosterTake(ix){
  var q,r;
  if(!pilHome()) return null;
  acctEnsure(P); q=P.pil;
  if(ix===-1){ if(!q||q.prestige!==1) return null; r=P.pilRest; }
  else { if(ix!==(ix|0)||ix<0||ix>=P.roster.length) return null; r=P.roster[ix]; }
  if(ix!==-1) P.roster.splice(ix,1);
  if(q){ if(q.prestige===1) P.roster.push(q); else P.pilRest=q; }
  P.pil=r||null;
  if(ix===-1) P.pilRest=null;
  saveProfile(); renderHall();
  if(!P.pil){ document.getElementById('opmodal').classList.remove('on'); birthOpen(); }
  return P.pil;
}
function pilRosterDraw(){
  var e=document.getElementById('hallprestige'),q,i,h,b;
  if(!e) return;
  e.style.display=pilHome()?'':'none'; if(!pilHome()) return;
  q=pilNow();
  h='<div class="prhead"><div><b>prestige roster '+pilRosterCount()+'/3</b><span>level 20 / picks kept / death ends prestige</span></div>';
  if(q&&q.prestige===1) h+='<button class="deploy ghost" data-proster="-1">bench '+escHtml(pilName(q))+'</button>';
  else h+='<button class="deploy ghost" id="hallprestigego"'+(pilPrestigeOk()?'':' disabled')+'>'+(pilRosterCount()>=3?'roster full':(q&&q.lvl===20?'prestige '+escHtml(pilName(q)):'prestige at level 20'))+'</button>';
  h+='</div>';
  for(i=0;i<P.roster.length;i++){ b=P.roster[i]; h+='<div class="prrow"><div><b>'+escHtml(pilName(b))+'</b><span>level 20 / '+(b.raids|0)+' raids lived</span></div><button class="deploy ghost" data-proster="'+i+'">play as '+escHtml(pilName(b))+'</button></div>'; }
  if(P.pilRest) h+='<div class="prrest">heir resting: '+escHtml(pilName(P.pilRest))+' / level '+P.pilRest.lvl+'</div>';
  e.innerHTML=h;
  b=document.getElementById('hallprestigego'); if(b) b.onclick=pilPrestigeAsk;
  e.querySelectorAll('[data-proster]').forEach(function(btn){ btn.onclick=function(){ pilRosterTake(+btn.getAttribute('data-proster')); }; });
}
function pilNow(){ return acctEnsure(P); }
'@

SubRx @'
  p.hall.push(r); p.pil=null;
'@ @'
  // v28.xx (cw-cx-prestige): a dead or abandoned veteran loses the star as well as its roster place.
  if(r.prestige===1&&r.end&&(r.end.how==='dead'||r.end.how==='quit')) r.prestige=0;
  p.hall.push(r); p.pil=null;
'@

SubRx @'
return (r.num|0)>=2?n+' '+pilRoman(r.num):n; }
'@ @'
return ((r.num|0)>=2?n+' '+pilRoman(r.num):n)+(r.prestige===1?' \u2605':''); }
'@

SubRx @'
  if(r) P.pilNote={t:String(r.name).toLowerCase()+' is gone  pillager '+pilNext(P),shown:0};
'@ @'
  // v28.xx (cw-cx-prestige): the resting heir survives a veteran death or quit, with no reroll.
  pilRestRestore(P);
  if(r) P.pilNote={t:String(r.name).toLowerCase()+' is gone'+(P.pil?'  '+pilName(P.pil):'  pillager '+pilNext(P)),shown:0};
'@

SubRx @'
  pilHeirs(P);
  BIRTH=null;
  try{ saveProfile(); }catch(_prt){}
'@ @'
  pilHeirs(P);
  pilRestRestore(P);   // v28.xx (cw-cx-prestige): retiring a veteran returns to its waiting heir.
  BIRTH=null;
  try{ saveProfile(); }catch(_prt){}
'@

SubRx @'
  hallMeDraw();   // v37.xx (cw-m2retire)
'@ @'
  hallMeDraw();   // v37.xx (cw-m2retire)
  pilRosterDraw();   // v28.xx (cw-cx-prestige): one roster on the existing hall tab.
'@

SubRx @'
    <div id="hallrecs"></div>
'@ @'
    <!-- v28.xx (cw-cx-prestige): the existing hall owns the roster, no second screen. -->
    <style>
    #root #hallprestige{margin:0 0 24px;border:1px solid var(--ui-line-hi);border-radius:var(--rad);background:var(--ui-panel);padding:16px 24px}
    #root #hallprestige .prhead,#root #hallprestige .prrow{display:flex;align-items:center;justify-content:space-between;gap:24px}
    #root #hallprestige .prrow{border-top:1px solid var(--ui-line);padding-top:12px;margin-top:12px}
    #root #hallprestige b{display:block;color:var(--bone);font:700 28px/1.2 var(--f-cond)}
    #root #hallprestige span,#root #hallprestige .prrest{display:block;color:var(--tx-2);font:400 20px/1.4 var(--f-body);margin-top:4px}
    #root #hallprestige button{min-height:56px;font:700 24px/1.2 var(--f-cond);padding:8px 24px;flex-shrink:0}
    #root #hallprestige .prrest{margin-top:12px}
    </style>
    <div id="hallprestige"></div>
    <div id="hallrecs"></div>
'@

SubRx @'
if(p&&p.pil&&String(p.pil.name||'').toLowerCase()===k) n++; return n; }
'@ @'
if(p&&p.pil&&String(p.pil.name||'').toLowerCase()===k) n++; if(p){ (p.roster||[]).concat(p.pilRest?[p.pilRest]:[]).forEach(function(r){ if(String(r.name||'').toLowerCase()===k) n++; }); } return n; }
'@

SubRx @'
var VER='37.67';
'@ @'
var VER='37.68';
'@

$pat = "(?m)^  now:'v37\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.68: The existing hall holds the prestige roster. Prestige sends worn gear to the stash, opens the heir choice and pays no bonus. Switch veterans on the hub floor, with the current heir kept safely. LOCAL: no linked review. Check 37.68 fails on v37.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
