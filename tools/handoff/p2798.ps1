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

# THE CAREER LEADERBOARD: DATA AND BOARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var CAREER_BOARD_N=10;
function careerSettle(how,lines){
  if(!G||!G.career||G.sim||!G.cs) return 0;
  if(typeof G.careerPaid==='number') return G.careerPaid;
  var s=Math.max(0,G.cs.s|0), fin=0, B, best=false, rk=0, i, row;
  if(how==='extract'){
    fin=s*2;
    P.credits=(+P.credits||0)+fin;
    if(fin>0){
      B=P.careerBoard=Array.isArray(P.careerBoard)?P.careerBoard:[];
      row={s:fin,k:G.cs.k|0,m:P.mapIx|0,t:Date.now(),n:String(P.pname||'').slice(0,16)};
      B.push(row); B.sort(function(a,b){ return ((b.s|0)-(a.s|0))||((a.t|0)-(b.t|0)); });
      if(B.length>CAREER_BOARD_N) B.length=CAREER_BOARD_N;
      for(i=0;i<B.length;i++) if(B[i]===row){ rk=i+1; break; }
      best=(rk===1);
      if(best) P.careerBest=fin;
    }
    if(lines){
      lines.push('<span style="color:#ffc04a;font-weight:700">CAREER SCORE '+arcadeCr(s)+' x2  \u00b7  +'+arcadeN(fin)+' CR</span>');
      if(best) lines.push('<span style="color:#ffc04a;font-weight:700">CAREER BEST</span>');
      else if(rk>0) lines.push('<span style="color:#ffc04a">CAREER BOARD #'+rk+'</span>');
    }
  } else if(lines&&s>0) lines.push('<span style="color:var(--rust);font-weight:700">SCORE LOST  \u00b7  '+arcadeCr(s)+'</span>');
  G.careerPaid=fin;
  return fin;
}
function careerPostBuild
'@ @'
// v27.NN (cboard1), HIS ORDER (2026-10-15): "career mode should still have a leaderboard that is shown after every match -- figure out triple AAA way to
// integrate this into existing UI". This replaces his earlier answer of a personal best only. THE CAREER BOARD KEEPS EVERY RUN. P.careerBoard (the list the
// v24.xx payout started) now holds the top 20 runs by RAID SCORE, an extraction (o x, the score after the x2) or a death (o k, the score the death lost),
// each with its sector, time (d seconds) and date; P.careerRuns is the count of every run ever settled and P.careerAll the 300 best scores, so a run outside
// the top 20 still knows its rank. A save from before has the list only: the first run seeds the count and the scores from it. An abandon is not a run here.
// The board is RANKED BY RAID SCORE and by nothing else, here, on the run card and in the Undercroft. csTally (below) keeps the score by where it came from
// (G.cs.b), for the ledger on the run card.
var CAREER_BOARD_N=20, CAREER_ALL_N=300;
function csTally(cat,n){
  var c=G&&G.cs, b;
  if(!c||!(n||0)) return 0;
  b=c.b||(c.b={}); b[cat]=(b[cat]|0)+(n|0);
  return n;
}
function careerBoardInit(){
  var B, A, i;
  if(!Array.isArray(P.careerBoard)) P.careerBoard=[];
  B=P.careerBoard;
  if(!Array.isArray(P.careerAll)||typeof P.careerRuns!=='number'){
    A=[]; for(i=0;i<B.length;i++) A.push(Math.max(0,((B[i]&&B[i].s)||0)|0));
    A.sort(function(a,b){ return b-a; });
    P.careerAll=A; P.careerRuns=B.length;
  }
}
// one run onto the board. Returns {rank,total,row,inTop,best,score,how}: rank among every run kept, ties going to the earlier run.
function careerBoardAdd(how,score){
  careerBoardInit();
  var B=P.careerBoard, A=P.careerAll, s=Math.max(0,(+score||0)|0), i, rk, row, ix;
  for(i=0;i<A.length;i++) if(A[i]<s) break;
  rk=i+1; A.splice(i,0,s);
  if(A.length>CAREER_ALL_N) A.length=CAREER_ALL_N;
  P.careerRuns=(P.careerRuns|0)+1;
  if(i>=CAREER_ALL_N||rk>P.careerRuns) rk=P.careerRuns;
  row={s:s,k:((G&&G.cs&&G.cs.k)||0)|0,m:P.mapIx|0,t:Date.now(),n:String(P.pname||'').slice(0,16),o:(how==='extract')?'x':'k',d:Math.round(runElapsed())};
  B.push(row); B.sort(function(a,b){ return ((b.s|0)-(a.s|0))||((a.t||0)-(b.t||0)); });
  ix=B.indexOf(row);
  if(B.length>CAREER_BOARD_N) B.length=CAREER_BOARD_N;
  return {rank:rk,total:P.careerRuns,row:row,inTop:(ix>=0&&ix<CAREER_BOARD_N),best:(rk===1&&s>0),score:s,how:how};
}
// the rows as the board draws them (an old row has no outcome, which was always an extraction, and no time)
function careerBoardRows(){
  var B=Array.isArray(P.careerBoard)?P.careerBoard:[], out=[], i, r;
  for(i=0;i<B.length&&out.length<CAREER_BOARD_N;i++){
    r=B[i]; if(!r) continue;
    out.push({s:Math.max(0,r.s|0),o:(r.o==='k')?'k':'x',m:r.m|0,d:Math.max(0,r.d|0),t:+r.t||0,k:r.k|0,raw:r});
  }
  return out;
}
function careerSettle(how,lines){
  if(!G||!G.career||G.sim||!G.cs) return 0;
  if(typeof G.careerPaid==='number') return G.careerPaid;
  var s=Math.max(0,G.cs.s|0), fin=0, best=false, rk=0, R=null;
  if(how==='extract'){
    fin=s*2;
    P.credits=(+P.credits||0)+fin;
  }
  if(how==='extract'||how==='dead'){   // v27.NN (cboard1): a death is a run on the board too; an abandon is not
    try{ R=careerBoardAdd(how,(how==='extract')?fin:s); }catch(_cb){ R=null; }
    G.careerLb=R;
    if(R){ rk=R.rank; best=R.best; if(best&&how==='extract') P.careerBest=fin; }
  }
  if(how==='extract'){
    if(lines){
      lines.push('<span style="color:#ffc04a;font-weight:700">CAREER SCORE '+arcadeCr(s)+' x2  \u00b7  +'+arcadeN(fin)+' CR</span>');
      if(best) lines.push('<span style="color:#ffc04a;font-weight:700">CAREER BEST</span>');
      else if(rk>0&&R&&R.inTop) lines.push('<span style="color:#ffc04a">CAREER BOARD #'+rk+'</span>');
    }
  } else if(lines&&s>0) lines.push('<span style="color:var(--rust);font-weight:700">SCORE LOST  \u00b7  '+arcadeCr(s)+'</span>');
  G.careerPaid=fin;
  return fin;
}
// A count-up on one figure: the text rolls from 0 to data-to over durMs after delayMs (data-pre goes in front of the $). lbCountEnd lands every one of them at once.
function lbCountStart(el,to,delayMs,durMs){
  var t0=Date.now()+(delayMs||0), pre;
  if(!el) return;
  pre=el.getAttribute('data-pre')||'';
  el.setAttribute('data-to',String(to|0));
  el.textContent=pre+arcadeCr(0);
  if(el._lbIv) clearInterval(el._lbIv);
  el._lbIv=setInterval(function(){
    var k=clamp((Date.now()-t0)/(durMs||900),0,1);
    if(!el.isConnected){ clearInterval(el._lbIv); return; }
    el.textContent=pre+arcadeCr(Math.round((to|0)*(1-Math.pow(1-k,3))));
    if(k>=1) clearInterval(el._lbIv);
  },40);
}
function lbCountEnd(host){
  var els=host?host.querySelectorAll('[data-to]'):[], i, el;
  for(i=0;i<els.length;i++){ el=els[i]; if(el._lbIv) clearInterval(el._lbIv); el.textContent=(el.getAttribute('data-pre')||'')+arcadeCr(+el.getAttribute('data-to')||0); }
  return els.length;
}
// the rows the DEMO board draws, shared: one div of the class with a span a cell (the DEMO line is two cells, the CAREER line six)
function lbRow(pg,cls,cells){
  var e=document.createElement('div'), s, i;
  e.className=cls;
  for(i=0;i<cells.length;i++){ s=document.createElement('span'); s.textContent=cells[i]; e.appendChild(s); }
  pg.appendChild(e); return e;
}
function lbDate(t){
  var d=new Date(+t||0);
  if(!(+t>0)) return '--';
  return (d.getDate()<10?'0':'')+d.getDate()+' '+['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'][d.getMonth()];
}
function lbCells(r,rank){
  var mp=FIXED_MAPS[clamp(r.m|0,0,FIXED_MAPS.length-1)];
  return ['#'+rank,arcadeCr(r.s),(r.o==='k')?'KIA':'EXTRACTED',(mp&&mp.name)?String(mp.name).toUpperCase():'--',(r.d>0)?fmtClock(r.d):'--',lbDate(r.t)];
}
// THE BOARD: the DEMO board look (the TONIGHTS BEST page: gold heading, bone rows, the teal row for this run, grey column heads) for the CAREER list. o: {row (this
// run's board row), rank, inTop, best, anim}. This run's row is teal and, with anim, climbs into its rank while its score counts up; a run outside the top 20 is
// pinned under the list with its rank; NEW PERSONAL BEST is a plate under the RANK readout. Returns the page element.
function careerBoardView(host,o){
  o=o||{};
  var B=careerBoardRows(), n=Math.max(P.careerRuns|0,B.length), hl=o.row||null, rk=o.rank|0, pg, i, r, e, c, pr;
  if(!host) return null;
  host.textContent='';
  pg=document.createElement('div'); pg.className='lbp'; host.appendChild(pg);
  arcadeAttLine(pg,'aph','CAREER LEADERBOARD');
  if(rk>0) arcadeAttLine(pg,'lbrk','RANK #'+rk+' OF '+n);
  else if(n>0) arcadeAttLine(pg,'lbrk',n+(n===1?' RUN':' RUNS'));
  if(o.best){ e=document.createElement('div'); e.className='lbpb'; e.textContent='NEW PERSONAL BEST'; pg.appendChild(e); }
  if(!B.length){ arcadeAttLine(pg,'apn','NO RUNS YET'); return pg; }
  lbRow(pg,'apr apc lbh',['RANK','SCORE','OUTCOME','SECTOR','TIME','DATE']);
  for(i=0;i<B.length;i++){
    r=B[i]; c=!!(hl&&r.raw===hl);
    e=lbRow(pg,'apr apc'+(c?' hl':'')+((r.o==='k')?' kia':''),lbCells(r,i+1));
    if(c&&o.anim){ e.className+=' lbmove'; e.style.setProperty('--lbd',String(Math.max(1,B.length-i))); lbCountStart(e.children[1],r.s,500,900); }
  }
  if(hl&&o.inTop===false&&rk>0){
    pr={s:hl.s|0,o:hl.o,m:hl.m|0,d:hl.d|0,t:hl.t};
    e=lbRow(pg,'apr apc hl lbpin'+((pr.o==='k')?' kia':''),lbCells(pr,rk));
    if(o.anim) lbCountStart(e.children[1],pr.s,500,900);
  }
  return pg;
}
careerStyle('lbcss',
  '.lbp{width:100%;box-sizing:border-box;font:800 15px var(--f-cond);letter-spacing:.08em;color:#f2e6c8;text-shadow:0 2px 0 #000;text-align:center;overflow:hidden;text-transform:uppercase}'+
  '.lbp .aph{font-size:1.5em;color:#ffc04a;margin-bottom:.1em}'+
  '.lbp .lbrk{font-size:1.25em;color:#7fe3d4;letter-spacing:.16em;margin:.05em 0 .45em}'+
  '.lbp .apn{line-height:1.6;opacity:.8}'+
  '.lbp .apr{display:grid;grid-template-columns:3.4em 6.4em 6.8em 1fr 3.6em 4.2em;gap:0 .7em;line-height:1.35;padding:.12em .55em;text-align:left;position:relative}'+
  '.lbp .apr span:nth-child(2){text-align:right}.lbp .apr span:nth-child(5),.lbp .apr span:nth-child(6){text-align:right}'+
  '.lbp .apr.kia span:nth-child(3){color:#e5482f}'+
  '.lbp .apr.hl{color:#7fe3d4;background:rgba(127,227,212,.1);box-shadow:inset 3px 0 0 #7fe3d4}'+
  '.lbp .apr.hl.kia span:nth-child(3){color:#ff8a6f}'+
  '.lbp .lbh{color:#9a8f78;font-size:.8em;border-bottom:1px solid rgba(154,143,120,.35);margin-bottom:.15em}'+
  '.lbp .lbpin{margin-top:.55em;border-top:1px dashed rgba(154,143,120,.55)}'+
  '.lbp .lbpb{display:inline-block;margin:.05em auto .5em;padding:.3em 1.3em;font-size:1.25em;letter-spacing:.22em;color:#1a1408;text-shadow:none;'+
    'background:linear-gradient(180deg,#ffe69a,#f5b73b 55%,#b46c0c);clip-path:polygon(.7em 0,calc(100% - .7em) 0,100% .7em,100% calc(100% - .7em),calc(100% - .7em) 100%,.7em 100%,0 calc(100% - .7em),0 .7em);animation:lbpop .5s ease-out .9s both}'+
  '.lbp .apr.lbmove{animation:lbmove .9s cubic-bezier(.22,.8,.2,1) .5s both;z-index:2;background:#16282a}'+
  '@keyframes lbmove{0%{transform:translateY(calc(var(--lbd,1)*1.59em));opacity:0}18%{opacity:1}100%{transform:none;opacity:1}}'+
  '@keyframes lbpop{0%{transform:scale(1.5);opacity:0;filter:brightness(2)}60%{transform:scale(.96);opacity:1}100%{transform:none;opacity:1;filter:none}}');
function careerPostBuild
'@

SubRx @'
function arcadeAttLine(pg,cls,a,b){
  var e=document.createElement('div'), s;
  e.className=cls;
  if(b===undefined) e.textContent=a;
  else { s=document.createElement('span'); s.textContent=a; e.appendChild(s); s=document.createElement('span'); s.textContent=b; e.appendChild(s); }
  pg.appendChild(e); return e;
}
function arcadeAttBoard
'@ @'
function arcadeAttLine(pg,cls,a,b){
  var e;
  if(b===undefined){ e=document.createElement('div'); e.className=cls; e.textContent=a; pg.appendChild(e); return e; }
  return lbRow(pg,cls,[a,b]);   // v27.NN (cboard1): the same row builder the CAREER board uses
}
function arcadeAttBoard
'@

SubRx @'
G.cs.s=(G.cs.s|0)+n; G.cs.k=(G.cs.k|0)+1;
'@ @'
G.cs.s=(G.cs.s|0)+n; G.cs.k=(G.cs.k|0)+1; csTally('kill',n);
'@

SubRx @'
else if(G.career&&G.cs){ G.cs.s=(G.cs.s|0)+n; }
'@ @'
else if(G.career&&G.cs){ G.cs.s=(G.cs.s|0)+n; csTally('style',n); }
'@

SubRx @'
else if(G.career&&G.cs) G.cs.s=(G.cs.s|0)+n;
'@ @'
else if(G.career&&G.cs){ G.cs.s=(G.cs.s|0)+n; csTally(/^GOAL/.test(head)?'goal':(/^BOUNTY/.test(head)?'bounty':'strong'),n); }
'@

SubRx @'
G.cs.s=(G.cs.s|0)+ARCADE_VAULT_PAY;
'@ @'
G.cs.s=(G.cs.s|0)+ARCADE_VAULT_PAY; csTally('vault',ARCADE_VAULT_PAY);
'@

SubRx @'
else G.cs.s=(G.cs.s|0)-n;
'@ @'
else{ G.cs.s=(G.cs.s|0)-n; csTally('forge',-n); }
'@

SubRx @'
var VER='27.97';
'@ @'
var VER='27.98';
'@

$pat = "(?m)^  now:'v27\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.98: Your CAREER board now keeps your twenty best runs, deaths included. Check 27.98 fails on v27.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
