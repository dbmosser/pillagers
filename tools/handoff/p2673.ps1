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

# RUN GOALS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(!ARCADE.on||!G||!G.arcade||G.sim||G.over) return 0;
  var n=arcadeKillPts(k,el,boss), s, t=+G.t||0, mx, c;
'@ @'
  if(!ARCADE.on||!G||!G.arcade||G.sim||G.over) return 0;
  try{ flowKill(k,el,boss); }catch(_fk1){}   // v26.xx (flow3): the run goals count what died
  var n=arcadeKillPts(k,el,boss), s, t=+G.t||0, mx, c;
'@

SubRx @'
  if(!G||!G.career||!G.cs||G.sim||G.over) return 0;
  var n=scoreKill(G.cs,k,el,boss,x,y);
'@ @'
  if(!G||!G.career||!G.cs||G.sim||G.over) return 0;
  try{ flowKill(k,el,boss); }catch(_fk2){}   // v26.xx (flow3): the run goals count what died
  var n=scoreKill(G.cs,k,el,boss,x,y);
'@

SubRx @'
  airScan(); airTick(dt);
  // FLOW-TICKS (the next flow builds add their ticks above this line)
'@ @'
  airScan(); airTick(dt);
  goalsTick(dt);
  // FLOW-TICKS (the next flow builds add their ticks above this line)
'@

SubRx @'
  if(HUDBOX.cond) HUDBOX.cond=hudZoomRect('cond',W,0,HUDBOX.cond);
'@ @'
  if(HUDBOX.cond) HUDBOX.cond=hudZoomRect('cond',W,0,HUDBOX.cond);
  try{ if(flowOn()) goalsHud(ctx); }catch(_gh){}   // v26.xx (flow3): the run goals, the same panel in DEMO and CAREER
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v26.xx (flow3), HIS YES (2026-10-14) to suggestion 6, RUN GOALS: "three tiny goals per raid, each paying a score chip, the same in DEMO and CAREER". Three
// goals are drawn for the raid from a pool of eight small ones (10 kills, search 6 crates, survive 3 waves, call an air strike, open a vault,
// down 3 pillagers, kill an elite, down a warden), on the side stream GOAL_TAG of the raid seed, so the same seed always gets the same three (the party
// seed shares them) and the seeded stream of the build is not touched. The vault goal is left out of a map with no vault. Progress is counted
// from what the raid already knows (the two kill doors, the opened crates, the wave count of the Director, the strikes called, the vault
// doors). A goal that is met pays its CHIP into the run score at once, in DEMO (the team score) and in CAREER (the raid score) alike, with
// GOAL DONE and the chip in the alert lane and the amount over you. The list is a panel under the CONDITIONS panel (under the minimap in the
// arcade, which has no CONDITIONS) and shows each goal with its count, DONE in green when met.
var GOAL_TAG=61;
var GOALS={
  kill10:{t:'10 KILLS',n:10,chip:200}, crate6:{t:'6 CRATES',n:6,chip:200}, wave3:{t:'3 WAVES',n:3,chip:250}, air1:{t:'AIR STRIKE',n:1,chip:300},
  vault:{t:'OPEN A VAULT',n:1,chip:400}, pill3:{t:'3 PILLAGERS',n:3,chip:400}, elite:{t:'KILL AN ELITE',n:1,chip:400}, ward:{t:'DOWN A WARDEN',n:1,chip:500}
};
var GOAL_IDS=['kill10','crate6','wave3','air1','vault','pill3','elite','ward'];
function flowKill(k,el,boss){
  var S;
  if(!flowOn()) return;
  S=flowS(); S.kills=(S.kills|0)+1; S.kinds=S.kinds||{}; S.kinds[k]=(S.kinds[k]|0)+1;
  if(el) S.elites=(S.elites|0)+1;
  if(boss) S.boss=(S.boss|0)+1; else if(k==='warden') S.wardens=(S.wardens|0)+1;
}
function goalsMake(S){
  var pool=GOAL_IDS.slice(), ids=[], ix;
  if(!(G.map&&G.map.locked&&G.map.locked.length)){ ix=pool.indexOf('vault'); if(ix>=0) pool.splice(ix,1); }
  sideStream((G.seed>>>0)||1,GOAL_TAG,function(){
    var k;
    while(ids.length<3&&pool.length){ k=Math.floor(rr()*pool.length); ids.push(pool.splice(k,1)[0]); }
  });
  S.goals=ids.map(function(id){ return {id:id,t:GOALS[id].t,n:GOALS[id].n,chip:GOALS[id].chip,v:0,done:0}; });
  return S.goals;
}
function goalProg(id,S){
  var K=S.kinds||{}, i, n=0, L, C;
  if(id==='kill10') return S.kills|0;
  if(id==='crate6'){ C=G.containers||[]; for(i=0;i<C.length;i++) if(C[i]&&C[i].opened) n++; S.crates=Math.max(S.crates|0,n); return S.crates; }
  if(id==='wave3') return (S.dir&&S.dir.waves)|0;
  if(id==='air1') return (S.air&&S.air.used)|0;
  if(id==='vault'){ L=(G.map&&G.map.locked)||[]; for(i=0;i<L.length;i++) if(L[i]&&L[i].open) n++; return n; }
  if(id==='pill3') return K.raider|0;
  if(id==='elite') return S.elites|0;
  if(id==='ward') return S.wardens|0;
  return 0;
}
function flowChip(n,head,sub){
  var p=G.player;
  if(!(n>0)) return 0;
  if(G.arcade&&typeof ARCADE==='object'&&ARCADE&&ARCADE.on){ ARCADE.mine=(ARCADE.mine|0)+n; try{ arcadeScSend(); }catch(_cs1){} }
  else if(G.career&&G.cs) G.cs.s=(G.cs.s|0)+n;
  else return 0;
  say(head,'ext',{sub:sub+'  +'+arcadeCr(n)});
  try{ if(p) label(p.x,p.y-44,'+'+arcadeCr(n),'#ffc04a',0,true); }catch(_cl){}
  return n;
}
function goalsTick(dt){
  var S=flowS(), i, gl, v;
  if(!S.goals) goalsMake(S);
  for(i=0;i<S.goals.length;i++){
    gl=S.goals[i]; if(gl.done) continue;
    v=goalProg(gl.id,S); gl.v=Math.min(gl.n,v);
    if(v>=gl.n){ gl.done=1; flowChip(gl.chip,'GOAL DONE',gl.t); }
  }
  if(!S.gtold&&(G.t||0)>=1.5){ S.gtold=1; say('RUN GOALS','obj',{sub:'THREE SMALL GOALS'}); }
}
function goalsHud(c){
  var S=G.flow, gl, i, z, U, w, lh, pad, h, x, y, hb, yy, n=0;
  if(!S||!S.goals||!S.goals.length||G.bagOpen||G.mapOpen||G.over) return 0;
  z=Math.max(1,hudRes()); U=function(v){ return LH(v)*z; };
  lh=U(15); pad=U(9); h=pad*2+lh*(S.goals.length+1);
  hb=HUDBOX.cond;
  if(hb&&isFinite(hb.y)&&isFinite(hb.x)){ x=hb.x; w=hb.w; y=hb.y+hb.h+Math.round(8*z); }
  else { w=U(176); x=W-Math.round(16*z)-w; y=(MMAP.box?mmBottom():Math.max(topRightBottom(),U(60)))+Math.round(10*z); }
  c.save();
  hudPanel(x,y,w,h,0.84);
  c.textBaseline='alphabetic'; c.textAlign='left'; c.font=hudFS(TYPE.micro);
  c.fillStyle='#ffc04a'; hudText('RUN GOALS',x+pad,y+pad+lh*0.8);
  for(i=0;i<S.goals.length;i++){
    gl=S.goals[i]; yy=y+pad+lh*(i+1)+lh*0.8;
    c.textAlign='left'; c.fillStyle=gl.done?'#7fc4a0':'#cdd6dd';
    hudText(gl.t+((!gl.done&&gl.n>1)?('  '+gl.v+'/'+gl.n):''),x+pad,yy);
    c.textAlign='right'; c.fillStyle=gl.done?'#7fc4a0':'#ffc04a';
    hudText(gl.done?'DONE':('+'+arcadeCr(gl.chip)),x+w-pad,yy);
    n++;
  }
  c.restore();
  return n;
}
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='26.72';
'@ @'
var VER='26.73';
'@

$pat = "(?m)^  now:'v26\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.73: Every raid now has three small run goals in a panel, each paying a score chip when met. Check 26.73 fails on v26.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
