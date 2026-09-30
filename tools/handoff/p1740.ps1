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

# ACHIEVEMENTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function renderStatCards(){
'@ @'
// v17.40, HIS PICK 18 (2026-09-30): ACHIEVEMENTS, beside the lifetime stats on the Mainframe. Earned once and kept in the
// save (P.ach, id to the time it was earned); lifetime counts for them in P.achN. A run earns them when it is committed
// (achRun from commitRun), the end card names any new one, and the Mainframe lists every one, earned or locked. The first
// time the list is drawn, the runs still in the log count too (P.achScan), so a player keeps what he already did.
var ACHS=[
  {id:'firstout',  n:'FIRST OUT',       d:'Extract for the first time.'},
  {id:'haul5k',    n:'HEAVY HAUL',      d:'Extract carrying $5,000 or more.'},
  {id:'haul20k',   n:'MOTHERLODE',      d:'Extract carrying $20,000 or more.'},
  {id:'untouched', n:'UNTOUCHED',       d:'Extract without taking a single hit.'},
  {id:'ghost',     n:'GHOST',           d:'Extract without ever being spotted.'},
  {id:'ten',       n:'BODY COUNT',      d:'Kill 10 or more in one raid.'},
  {id:'comeback',  n:'COMEBACK',        d:'Go down in a raid and still extract.'},
  {id:'pill25',    n:'PILLAGER HUNTER', d:'Kill 25 pillagers in all.'},
  {id:'mach100',   n:'MACHINE BREAKER', d:'Kill 100 machines in all.'},
  {id:'party',     n:'PARTY OF TWO',    d:'Extract from a raid your party went up on together.'},
  {id:'vet25',     n:'VETERAN',         d:'Finish 25 runs.'},
  {id:'vet100',    n:'LIFER',           d:'Finish 100 runs.'}
];
function achRun(rec,live){
  var got=[], k, v, kills=0, pr=0, mc=0, dmg=0, ex, runs;
  if(!rec||typeof P==='undefined'||!P) return got;
  P.ach=P.ach||{}; P.achN=P.achN||{};
  for(k in (rec.kills||{})){ v=rec.kills[k]|0; kills+=v; if(k==='raider') pr+=v; else mc+=v; }
  for(k in (rec.dmg||{})) dmg+=(+rec.dmg[k]||0);
  if(live){ P.achN.raider=(P.achN.raider||0)+pr; P.achN.mach=(P.achN.mach||0)+mc; }
  ex=(rec.outcome==='extract'); runs=P.runs|0;
  function e(id){ var i; if(P.ach[id]) return; P.ach[id]=Date.now(); for(i=0;i<ACHS.length;i++) if(ACHS[i].id===id) got.push(ACHS[i]); }
  if(ex) e('firstout');
  if(ex&&(rec.haul|0)>=5000) e('haul5k');
  if(ex&&(rec.haul|0)>=20000) e('haul20k');
  if(ex&&dmg<=0) e('untouched');
  if(ex&&(rec.firstContact===null||rec.firstContact===undefined)) e('ghost');
  if(kills>=10) e('ten');
  if(ex&&(rec.downs|0)>0) e('comeback');
  if((P.achN.raider||0)>=25) e('pill25');
  if((P.achN.mach||0)>=100) e('mach100');
  if(ex&&live&&typeof NET!=='undefined'&&NET&&NET.on) e('party');
  if(runs>=25) e('vet25');
  if(runs>=100) e('vet100');
  return got;
}
function achStatsDraw(g){
  var i, k, a, n=0, h='', L=P.log||[], old;
  if(!g) return '';
  P.ach=P.ach||{}; P.achN=P.achN||{};
  if(!P.achScan){
    for(i=0;i<L.length;i++){ for(k in (L[i].kills||{})){ if(k==='raider') P.achN.raider=(P.achN.raider||0)+(L[i].kills[k]|0); else P.achN.mach=(P.achN.mach||0)+(L[i].kills[k]|0); } }
    for(i=0;i<L.length;i++) achRun(L[i],false);
    P.achScan=1; try{ saveProfile(); }catch(_s){}
  }
  for(i=0;i<ACHS.length;i++){
    a=ACHS[i]; if(P.ach[a.id]) n++;
    h+='<div style="display:flex;gap:10px;font-size:11.5px;padding:2px 0;color:'+(P.ach[a.id]?'var(--amber)':'var(--ash)')+'">'+
       '<span style="width:150px">'+(P.ach[a.id]?'':'LOCKED ')+a.n+'</span><span style="flex:1">'+a.d+'</span></div>';
  }
  old=document.getElementById('achlist'); if(old&&old.parentNode) old.parentNode.removeChild(old);
  g.insertAdjacentHTML('beforeend','<div id="achlist" style="grid-column:1/-1;margin-top:10px;border-top:1px solid var(--steel-hi);padding-top:8px">'+
    '<div style="font-size:10.5px;letter-spacing:.2em;color:var(--ash);margin-bottom:6px">ACHIEVEMENTS  '+n+' OF '+ACHS.length+'</div>'+h+'</div>');
  return n+'/'+ACHS.length;
}function renderStatCards(){
'@

SubRx @'
  P.log.push(rec);
'@ @'
  P.log.push(rec);
  try{ if(typeof G!=='undefined'&&G&&!G.sim) G.achNew=achRun(rec,true); }catch(_ac){}   // v17.40: his pick 18, achievements earned by this run
'@

SubRx @'
  if(!G.sim) commitRun(pendingRun);
'@ @'
  if(!G.sim) commitRun(pendingRun);
  if(!G.sim&&G.achNew&&G.achNew.length) for(var _an=0;_an<G.achNew.length;_an++) lines.push('<span style="color:var(--amber)">ACHIEVEMENT: '+G.achNew[_an].n+'</span>  <span style="color:var(--ash)">'+G.achNew[_an].d+'</span>');   // v17.40: named on the end card
'@

SubRx @'
  if(tm) h+=card('Most raided', tm.k, tm.n+' of your '+all.n+' run'+(all.n===1?'':'s'));
  g.innerHTML=h;
'@ @'
  if(tm) h+=card('Most raided', tm.k, tm.n+' of your '+all.n+' run'+(all.n===1?'':'s'));
  g.innerHTML=h;
  try{ achStatsDraw(g); }catch(_asd){}   // v17.40: his pick 18, the achievements under the stats
'@

SubRx @'
var VER='17.39';
'@ @'
var VER='17.40';
'@

$pat = "(?m)^  now:'v17\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.40: ACHIEVEMENTS, his pick from the feature list, beside the lifetime stats on the Mainframe. Twelve of them are earned once and kept in the save; the end card names a new one, the Mainframe lists every one with how many are earned, and runs already in the log count the first time the list is drawn. Check 17.40 fails on v17.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
