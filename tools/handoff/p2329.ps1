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

# ARCADE: COMBINED TEAM SCORE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// The arcade layer of the HUD, drawn from drawHUD. For now the EXTRACTED! banner: 3 seconds in the centre, on game time.
'@ @'
// v23.29, HIS ORDER (2026-10-11), build 8 of 20 (arcade8): COMBINED TEAM SCORE. Each window scores only its own player into
// ARCADE.mine, inside a run id the host owns (made at every arcadeDeploy, kept through arcadeRebuild). A credited kill scores by
// kind: crawler 50, snitch 75, sentry 100, raider 150, listener and howler 200, bulwark 300, warden 400, the Pillbox 500 and the
// Overseer 2,000, an elite counting double. The host scores at its kill credit in updateEnts, player 2 at its kill word
// (netKillTake). Each window tells the other its score with arcsc {run,s,k,x,ev} on every change (at most 4 a second, flushed
// by the attract tick) and again every 2 s while its arcade raid is up, and keeps the other score in ARCADE.mate: the team score
// is mine plus mate. A word for another run id is ignored by the host; player 2 takes the run id of the host (a new one starts its
// score over, and a player 2 who joins mid-run starts at 0 under it). An extraction tells the teammate PLAYER 1 EXTRACTED +3,340.
// In the arcade the clock spot shows TEAM SCORE over the sum, with YOU and the teammate score beside it. Nothing is saved, and
// every line is behind G.arcade or ARCADE.on, so a normal raid is unchanged.
var ARCADE_KILLPTS={crawler:50,snitch:75,sentry:100,raider:150,listener:200,howler:200,bulwark:300,warden:400,choir:500}, ARCADE_BOSSPTS=2000;
var ARCADE_SC_MS=250, ARCADE_SC_BEAT=2000;
function arcadeTeam(){ return Math.max(0,ARCADE.mine|0)+Math.max(0,ARCADE.mate|0); }
function arcadeRunId(){ ARCADE.runN=(ARCADE.runN|0)+1; return 'r'+Date.now().toString(36)+'_'+ARCADE.runN; }
function arcadeKillPts(k,el,boss){ var n=boss?ARCADE_BOSSPTS:(ARCADE_KILLPTS[k]|0); return el?n*2:n; }
// A kill this window credited to its own player. Returns the points.
function arcadeKill(k,el,boss){
  if(!ARCADE.on||!G||!G.arcade||G.sim||G.over) return 0;
  var n=arcadeKillPts(k,el,boss);
  if(!(n>0)) return 0;
  ARCADE.mine=(ARCADE.mine|0)+n; ARCADE.kills=(ARCADE.kills|0)+1;
  arcadeScSend();
  return n;
}
// The score changed: tell the other window now, or on the next flush inside the 250 ms limit. ev x (with n) is an extraction.
function arcadeScSend(ev,n){
  if(!ARCADE.on) return false;
  if(ev){ ARCADE.scEv=ev; ARCADE.scN=(ARCADE.scN|0)+(n|0); }
  ARCADE.scDirty=1;
  return arcadeScFlush(Date.now());
}
function arcadeScFlush(now){
  if(!ARCADE.on||!ARCADE.run||!ARCADE.run.id) return false;
  if(!ARCADE.scDirty){
    if(G&&G.arcade&&!G.over&&now-(+ARCADE.scAt||0)>=ARCADE_SC_BEAT) ARCADE.scDirty=1;
    else return false;
  }
  if(now-(+ARCADE.scAt||0)<ARCADE_SC_MS) return false;
  var m={t:'arcsc',pair:NET.pair,run:ARCADE.run.id,s:Math.max(0,ARCADE.mine|0),k:Math.max(0,ARCADE.kills|0),x:Math.max(0,ARCADE.ext|0)};
  if(ARCADE.scEv){ m.ev=ARCADE.scEv; m.n=Math.max(0,ARCADE.scN|0); }
  ARCADE.scDirty=0; ARCADE.scEv=''; ARCADE.scN=0; ARCADE.scAt=now;
  netSamePost(m);
  return true;
}
// arcsc from the other window. Returns what it did.
function arcadeScTake(m){
  if(!ARCADE.on) return 'off';
  var id=(typeof m.run==='string')?m.run.slice(0,40):'';
  if(!id) return 'bad';
  if(ARCADE.role==='p2'){
    if(!ARCADE.run||ARCADE.run.id!==id){
      if(ARCADE.run){ ARCADE.mine=0; ARCADE.kills=0; ARCADE.ext=0; ARCADE.deaths=0; }
      ARCADE.run={id:id}; ARCADE.scDirty=1; ARCADE.scAt=0;
    }
  } else if(!ARCADE.run||ARCADE.run.id!==id) return 'ignored';
  ARCADE.mate=Math.max(0,Math.round(+m.s||0)); ARCADE.mateK=Math.max(0,m.k|0); ARCADE.mateX=Math.max(0,m.x|0);
  if(m.ev==='x'&&(m.n|0)>0&&G&&G.arcade&&!G.over){ try{ say((ARCADE.role==='p2'?'PLAYER 1':'PLAYER 2')+' EXTRACTED +'+arcadeN(m.n|0),'ally'); }catch(_sx){} }
  if(ARCADE.role==='p2') arcadeScFlush(Date.now());
  return 'arcsc';
}
// The clock spot in the arcade: TEAM SCORE over the sum, YOU and the teammate score beside it. y is the clock line, z its scale.
function arcadeScoreHud(y,z){
  if(!G||!G.arcade||!ctx) return;
  var cx=Math.round(W/2), mine=Math.max(0,ARCADE.mine|0), mate=Math.max(0,ARCADE.mate|0), nm=arcadeN(mine+mate);
  var fb=FSz(TYPE.title,z), fs=FSz(TYPE.micro,z), mh=/([\d.]+)px/.exec(fb), h=mh?+mh[1]:20, w, gx;
  ctx.save(); ctx.textAlign='center';
  ctx.font=fs; ctx.fillStyle='#ffc04a'; hudText('TEAM SCORE',cx,Math.round(y-h*0.80));
  ctx.font=fb; ctx.fillStyle='#e8eef2'; hudText(nm,cx,y); w=ctx.measureText(nm).width;
  gx=Math.round(cx+w/2+10*z);
  ctx.font=fs; ctx.textAlign='left'; ctx.fillStyle='#cdd6dd';
  hudText('YOU '+arcadeN(mine),gx,Math.round(y-h*0.40));
  hudText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeN(mate),gx,Math.round(y+h*0.15));
  ctx.restore();
}
// The arcade layer of the HUD, drawn from drawHUD. For now the EXTRACTED! banner: 3 seconds in the centre, on game time.
'@

SubRx @'
  ARCADE.mine=0; ARCADE.mate=0; ARCADE.pot=0; ARCADE.ext=0; ARCADE.banner=null;   // v23.23 (arcade4)
'@ @'
  ARCADE.mine=0; ARCADE.mate=0; ARCADE.pot=0; ARCADE.ext=0; ARCADE.banner=null;   // v23.23 (arcade4)
  ARCADE.kills=0; ARCADE.mateK=0; ARCADE.mateX=0; ARCADE.scEv=''; ARCADE.scN=0; ARCADE.scAt=0; ARCADE.scDirty=(ARCADE.role!=='p2')?1:0;   // v23.29 (arcade8)
  if(ARCADE.role!=='p2') ARCADE.run={id:arcadeRunId()};   // v23.29 (arcade8): the host owns the run id
'@

SubRx @'
  ok=arcadeDeploy({role:'host',mapIx:P.mapIx});
  ARCADE.mine=s.mine; ARCADE.mate=s.mate; ARCADE.ext=s.ext; ARCADE.deaths=s.deaths;
'@ @'
  var run0=ARCADE.run, k0=ARCADE.kills|0;   // v23.29 (arcade8): the same run, so the team score carries on
  ok=arcadeDeploy({role:'host',mapIx:P.mapIx});
  ARCADE.mine=s.mine; ARCADE.mate=s.mate; ARCADE.ext=s.ext; ARCADE.deaths=s.deaths;
  if(run0) ARCADE.run=run0; ARCADE.kills=k0;
'@

SubRx @'
        T.kills[e.kind]++; contractKill(e.kind);
        if(e.elite) T.eliteKills=(T.eliteKills||0)+1;
'@ @'
        T.kills[e.kind]++; contractKill(e.kind);
        if(e.elite) T.eliteKills=(T.eliteKills||0)+1;
        if(G.arcade) arcadeKill(e.kind,e.elite,e.boss);   // v23.29 (arcade8): the arcade score, by kind
'@

SubRx @'
  if(m.el||(e&&e.elite)) T.eliteKills=(T.eliteKills||0)+1;
'@ @'
  if(m.el||(e&&e.elite)) T.eliteKills=(T.eliteKills||0)+1;
  if(G.arcade) arcadeKill(k,!!(m.el||(e&&e.elite)),!!(e&&e.boss));   // v23.29 (arcade8): the arcade score of player 2
'@

SubRx @'
function arcadeOnMsg(m){
  if(!m||typeof m.t!=='string') return 'bad';
'@ @'
function arcadeOnMsg(m){
  if(!m||typeof m.t!=='string') return 'bad';
  if(m.t==='arcsc') return arcadeScTake(m);   // v23.29 (arcade8): the teammate score, both ways
'@

SubRx @'
function arcadeAttTick(){
  if(!ARCADE.on) return;
'@ @'
function arcadeAttTick(){
  if(!ARCADE.on) return;
  try{ arcadeScFlush(Date.now()); }catch(_sf){}   // v23.29 (arcade8): a held score word, and the 2 s repeat
'@

SubRx @'
  ARCADE.banner={t0:G.t,bonus:ARCADE_XBONUS,haul:pot,team:(ARCADE.mine|0)+(ARCADE.mate|0)};
'@ @'
  ARCADE.banner={t0:G.t,bonus:ARCADE_XBONUS,haul:pot,team:(ARCADE.mine|0)+(ARCADE.mate|0)};
  arcadeScSend('x',ARCADE_XBONUS+pot);   // v23.29 (arcade8): the teammate sees PLAYER 1 EXTRACTED
'@

SubRx @'
    ARCADE.mapIx=clamp(mi|0,0,FIXED_MAPS.length-1);   // his last sector
'@ @'
    ARCADE.mapIx=clamp(mi|0,0,FIXED_MAPS.length-1);   // his last sector
    ARCADE.run=null; ARCADE.mine=0; ARCADE.mate=0; ARCADE.kills=0;   // v23.29 (arcade8)
'@

SubRx @'
  hudText(mm+':'+(ss<10?'0':'')+ss,W/2,_yClk);
'@ @'
  if(G.arcade) arcadeScoreHud(_yClk,_tz); else hudText(mm+':'+(ss<10?'0':'')+ss,W/2,_yClk);   // v23.29 (arcade8): in the arcade, TEAM SCORE in place of the clock
'@

SubRx @'
var VER='23.28';
'@ @'
var VER='23.29';
'@

$pat = "(?m)^  now:'v23\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.29: In the arcade every kill scores by kind, both windows share the score, and TEAM SCORE replaces the raid clock. Check 23.29 fails on v23.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
