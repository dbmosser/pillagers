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

# THE TROPHY CASE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<div class="modal" id="codexmodal">
'@ @'
<!-- v26.xx (career4), HIS YES (2026-10-14) to suggestion 33, THE TROPHY CASE: a stash shelf of earned trophies. -->
<div class="modal" id="trophymodal">
  <h3 id="trophy_h">TROPHY CASE</h3>
  <div class="trgrid" id="trophygrid"></div>
  <div style="display:flex;gap:8px;margin-top:10px">
    <button id="closetrophy" style="padding:8px 22px">CLOSE</button>
  </div>
</div>

<div class="modal" id="codexmodal">
'@

SubRx @'
welcomemodal:'welcomeno',codexmodal:'closecodex'};
'@ @'
welcomemodal:'welcomeno',codexmodal:'closecodex',trophymodal:'closetrophy'};
'@

SubRx @'
r3.appendChild(sq); r3.appendChild(sb); r3.appendChild(cxb); tb.appendChild(r3);
'@ @'
var trb=document.createElement('div'); trb.className='invtab'; trb.id='trophybtn'; trb.style.fontSize='13px';   // v26.xx (career4): THE TROPHY CASE
      trb.textContent='TROPHIES  '+trophyCount()+'/'+TROPHIES.length; trb.onclick=function(){ trophyOpen(); };
      r3.appendChild(sq); r3.appendChild(sb); r3.appendChild(cxb); r3.appendChild(trb); tb.appendChild(r3);
'@

SubRx @'
try{ codexScan(); }catch(_cxs){}
'@ @'
try{ codexScan(); }catch(_cxs){}
  try{ trophyScan(true); }catch(_trs){}   // v26.xx (career4): the trophy case files what the profile has earned
'@

SubRx @'
try{ gunKillNote(e); }catch(_gkn){}
'@ @'
try{ gunKillNote(e); }catch(_gkn){}
        try{ trophyKill(e); }catch(_tkl){}   // v26.xx (career4): the golden enemy and the Overseer are trophies
'@

SubRx @'
function careerTick(dt){
'@ @'
// v26.xx (career4), HIS YES (2026-10-14) to suggestion 33, THE TROPHY CASE: "a stash shelf with earned trophies (first extract, golden enemy kill, Overseer kill, and so on)".
// Eight trophies. Six are read from what the profile already says (so an older save has its shelf the first time the stash is drawn): FIRST OUT (an extraction), GHOST
// (the achievement for walking out unspotted), MOTHERLODE (the $20,000 haul), CENTURION (100 kills with one gun, career1), FORGED (a MK III gun kept in the armoury, which
// only an extraction brings home) and FULL ARMORY (every gun in the codex, career2). Two are earned on the spot: GOLD HUNTER for killing the golden enemy and OVERSEER DOWN
// for killing the Overseer, with a TROPHY EARNED callout and a save at once. The profile keeps P.trophies, trophy id to the time it was earned (an old save has none). A
// trophy is kept for good. The case is a button beside ARMORY on the stash (TROPHIES n/N): earned plaques are lit in their tier colour (bronze, silver, gold) with the day
// they were earned; the rest are dark with what it takes, in caps. CLOSE and ESC shut it. No trophy changes any number in the game.
var TROPHIES=[
  {id:'firstout',n:'FIRST OUT',d:'EXTRACT ONCE',t:'b'},
  {id:'ghost',n:'GHOST',d:'EXTRACT UNSPOTTED',t:'s'},
  {id:'motherlode',n:'MOTHERLODE',d:'EXTRACT WITH $20,000',t:'s'},
  {id:'centurion',n:'CENTURION',d:'100 KILLS WITH ONE GUN',t:'s'},
  {id:'forged',n:'FORGED',d:'KEEP A MK III GUN',t:'s'},
  {id:'armory',n:'FULL ARMORY',d:'FILE EVERY GUN',t:'g'},
  {id:'golden',n:'GOLD HUNTER',d:'KILL THE GOLDEN ENEMY',t:'g'},
  {id:'overseer',n:'OVERSEER DOWN',d:'KILL THE OVERSEER',t:'g'}
];
var TROPHY_COL={b:'#c88a4a',s:'#c9d1d8',g:'#ffc72e'};
function trophyOf(id){ var i; for(i=0;i<TROPHIES.length;i++) if(TROPHIES[i].id===id) return TROPHIES[i]; return null; }
function trophyHas(id){ return !!(P&&P.trophies&&typeof P.trophies==='object'&&P.trophies[id]); }
function trophyCount(){ var i, n=0; for(i=0;i<TROPHIES.length;i++) if(trophyHas(TROPHIES[i].id)) n++; return n; }
function trophyGive(id){
  if(!P||!trophyOf(id)) return false;
  if(!P.trophies||typeof P.trophies!=='object'||Array.isArray(P.trophies)) P.trophies={};
  if(P.trophies[id]) return false;
  P.trophies[id]=Date.now();
  return true;
}
function trophyKill(e){
  var id, T;
  if(!G||G.sim||G.arcade||!e||!P) return 0;
  id=(e.kind==='warden'&&(e.boss||e.name===BOSS_NAME))?'overseer':(e.golden?'golden':'');
  if(!id||!trophyGive(id)) return 0;
  T=trophyOf(id);
  try{ saveProfile(); }catch(_sv){}
  try{ say('TROPHY EARNED','ext',{sub:T.n}); }catch(_sy){}
  return 1;
}
function trophyScan(announce){
  var nw=[], k;
  function give(id){ if(trophyGive(id)) nw.push(id); }
  if(!P) return 0;
  if((+P.ext||0)>0||(P.ach&&P.ach.firstout)) give('firstout');
  if(P.ach&&P.ach.ghost) give('ghost');
  if(P.ach&&P.ach.haul20k) give('motherlode');
  if(P.gunKills&&typeof P.gunKills==='object') for(k in P.gunKills) if((+P.gunKills[k])>=100){ give('centurion'); break; }
  if(P.forged&&typeof P.forged==='object') for(k in P.forged) if(P.forged[k]&&P.forged[k].fk===2&&(P.weapons||[]).indexOf(k)>=0){ give('forged'); break; }
  if(codexFound()>=codexGuns().length) give('armory');
  if(nw.length){
    try{ saveProfile(); }catch(_sv){}
    if(announce){ try{ say2('TROPHY EARNED  \u00b7  '+trophyOf(nw[0]).n+(nw.length>1?'  +'+(nw.length-1):'')); }catch(_s2){} }
  }
  return nw.length;
}
careerStyle('careercss4',
  '#trophymodal .trgrid{display:grid;grid-template-columns:repeat(auto-fill,minmax(236px,1fr));gap:14px 12px;flex:1;min-height:0;overflow-y:auto;padding:6px 4px 10px 2px;align-content:start}'+
  '.trp{position:relative;display:flex;flex-direction:column;align-items:center;text-align:center;padding:14px 12px 14px;background:linear-gradient(rgba(255,255,255,.035),rgba(0,0,0,.34));border:1px solid var(--ui-line-hi);border-bottom:6px solid var(--tc,#55524c);clip-path:polygon(12px 0,100% 0,100% 100%,0 100%,0 12px)}'+
  '.trp svg{width:66px;height:66px;margin-bottom:6px}'+
  '.trp.no svg{opacity:.26}'+
  '.trp .trn{font-family:var(--f-cond);font-weight:700;font-size:21px;letter-spacing:.06em;text-transform:uppercase;color:var(--tx-1);line-height:1.1}'+
  '.trp.no .trn{color:var(--tx-3)}'+
  '.trp .trd{font-family:var(--f-cond);font-weight:600;font-size:14px;letter-spacing:.1em;text-transform:uppercase;color:var(--tx-2);margin-top:4px}'+
  '.trp .trw{font-family:var(--f-cond);font-weight:700;font-size:13px;letter-spacing:.14em;text-transform:uppercase;color:var(--tc,#55524c);margin-top:7px}');
function trophyCup(col){
  return '<svg viewBox="0 0 48 48" aria-hidden="true"><path d="M14 6h20v10c0 8-4 13-10 14-6-1-10-6-10-14z" fill="'+col+'"/><path d="M14 9H7c0 7 3 11 8 12M34 9h7c0 7-3 11-8 12" fill="none" stroke="'+col+'" stroke-width="3"/><rect x="21" y="30" width="6" height="7" fill="'+col+'"/><rect x="13" y="37" width="22" height="5" fill="'+col+'"/></svg>';
}
function renderTrophies(){
  var gr=document.getElementById('trophygrid'), hd=document.getElementById('trophy_h'), h='', i, T, has, ts, col;
  if(hd) hd.textContent='TROPHY CASE  \u00b7  '+trophyCount()+' OF '+TROPHIES.length;
  if(!gr) return 0;
  for(i=0;i<TROPHIES.length;i++){
    T=TROPHIES[i]; has=trophyHas(T.id); col=has?(TROPHY_COL[T.t]||'#c9d1d8'):'#55524c';
    ts=has?new Date(+P.trophies[T.id]):null;
    h+='<div class="trp '+(has?'yes':'no')+'" data-trophy="'+T.id+'" style="--tc:'+col+'">'+trophyCup(col)+
       '<div class="trn">'+escHtml(T.n)+'</div><div class="trd">'+escHtml(T.d)+'</div>'+
       '<div class="trw">'+(has?(ts&&isFinite(ts.getTime())?escHtml(ts.toLocaleDateString(undefined,{month:'short',day:'numeric'})).toUpperCase():'EARNED'):'LOCKED')+'</div></div>';
  }
  gr.innerHTML=h;
  return TROPHIES.length;
}
function trophyOpen(){
  trophyScan(false);
  renderTrophies();
  openModal('trophymodal');
  try{ sndUi('open'); }catch(_su){}
  try{ var b=document.getElementById('closetrophy'); if(b&&!b._tr){ b._tr=1; b.onclick=function(){ document.getElementById('trophymodal').classList.remove('on'); try{ renderHub(); }catch(_rh){} }; } }catch(_cb){}
}
function careerTick(dt){
'@

SubRx @'
var VER='27.00';
'@ @'
var VER='27.01';
'@

$pat = "(?m)^  now:'v27\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.01: The stash has a trophy case of eight plaques, lit when earned. Check 27.01 fails on v27.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
