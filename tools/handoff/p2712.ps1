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

# PLAYER 2 BREACHES AND IS FENCED BY THE STRONGHOLDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // FLOW-NET-OUT (the next coop builds add their keys above this line)
'@ @'
  o.s=shNetOut();   // v27.12 (coop4): and the strongholds
  // FLOW-NET-OUT (the next coop builds add their keys above this line)
'@

SubRx @'
  // FLOW-NET-IN (the next coop builds take their keys above this line)
'@ @'
  if(fl.s&&typeof fl.s.length==='number') shNetTake(fl.s);   // v27.12 (coop4): the strongholds
  // FLOW-NET-IN (the next coop builds take their keys above this line)
'@

SubRx @'
function shTick(dt){
  var SS=shS(), i, j, k, s, e, p=G.player, gp, d, near, alive;
'@ @'
function shTick(dt){
  var SS=shS(), i, j, k, s, e, p=G.player, gp, d, near, alive;
  if(flowPeer()){ shPeerTick(dt); return; }   // v27.12 (coop4): a linked player 2 window lays out and fills no stronghold, it keeps the host ones (shNetTake)
'@

SubRx @'
    if(!s.open&&p&&!p.downed&&!p.dying){
      gp=shGatePt(s); d=Math.hypot(p.x-gp.x,p.y-gp.y);
      near=(d<SH.reach)&&(p.shS&&p.shS[s.i]===2);
'@ @'
    if(!s.open&&p&&((!p.downed&&!p.dying)||(G.t||0)-(+s.p2at||-9)<0.6)){   // v27.12 (coop4): or a partner is at the gate
      gp=shGatePt(s); d=Math.hypot(p.x-gp.x,p.y-gp.y);
      near=((d<SH.reach)&&(p.shS&&p.shS[s.i]===2)&&!p.downed&&!p.dying)||((G.t||0)-(+s.p2at||-9)<0.6);
'@

SubRx @'
  if(m.t==='cont') return netContWord(peer,m);   // v15.91: a container arrived, is held, is free, opened or shut, from the host
'@ @'
  if(m.t==='cont') return netContWord(peer,m);   // v15.91: a container arrived, is held, is free, opened or shut, from the host
  if(m.t==='fl') return flowNetWord(peer,m);   // v27.12 (coop4): a raid flow word between the windows (the gate, and the later builds)
'@

SubRx @'
    for(i=0;i<G.containers.length;i++){ c=G.containers[i]; if(c&&c.tag&&EV_WRECK_TAGS[c.tag]&&!c.opened&&!c.fwk){ c.fwk=1; E.wrecks.push(c); } }
'@ @'
    for(i=0;i<G.containers.length;i++){
      c=G.containers[i];
      if(!c||!c.tag||!EV_WRECK_TAGS[c.tag]||c.opened||c.fwk) continue;
      if(c.tag==='STRONGHOLD CACHE'&&!(shAt(c.x,c.y,30)||{}).open) continue;   // v27.12 (coop4): the compound cache is on the maps once the gate is open, as on the host
      c.fwk=1; E.wrecks.push(c);
    }
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v27.12 (coop4), HIS ORDER (2026-10-14), the two player first: THE STRONGHOLDS COME TO PLAYER 2. The compounds were laid out by every window for itself: player 2 built a second set
// of defenders that only his window knew (bodies the host does not have), and the fence, the gate and the clear were the host's alone. The host now lists its compounds in the world
// word (key s: the number, the place, the angle of the gate, whether it is open, how far the breach is, whether it is cleared); the linked window lays out and fills none (shTick),
// keeps what the host says, and its player is fenced in or out of each compound like the host player (shKeep, on the side he first stood). The defenders are the host bodies and come
// over in the body words. THE BREACH IS FOR BOTH: standing at the gate from outside for the breach time fills the ring, and player 2's window tells the host so every quarter second
// he does (a raid flow word, t fl, k gate, reliable), which the host counts beside its own player; so either of them, or the two together, open it. The cache shows on the maps once
// the gate is open, as it does on the host, and the open gate and the clear are said on his window too. No new channel: the compounds ride in the world word and the gate in the flow word.
function flowNetPost(m){
  var q;
  if(!flowPeer()||typeof netPeerOfSeat!=='function') return false;
  q=netPeerOfSeat(0); if(!q) return false;
  m.t='fl'; return netSend(q,m);
}
function flowNetWord(peer,m){
  var SS, i, s;
  if(!peer||peer.state!=='in'||!m||typeof m.k!=='string') return 'ignored';
  if(m.k==='gate'){
    if(NET.role!=='host'||!netEntsHost()||!flowOn()) return 'ignored';
    SS=shS();
    for(i=0;SS.sites&&i<SS.sites.length;i++){ s=SS.sites[i]; if(s.i===(m.i|0)){ if(!s.open) s.p2at=G.t||0; return 'gate'; } }
    return 'gone';
  }
  // FLOW-NET-WORD (the next coop builds take their words above this line)
  return 'bad';
}
function shNetOut(){
  var SS=G.flow&&G.flow.sh, a=[], i, s;
  if(!SS||!SS.sites) return a;
  for(i=0;i<SS.sites.length&&i<3;i++){ s=SS.sites[i]; a.push([s.i|0,Math.round(s.x),Math.round(s.y),+(+s.ga).toFixed(3),s.open?1:0,+(+s.prog).toFixed(2),s.clear?1:0]); }
  return a;
}
function shNetTake(rows){
  var SS=shS(), i, j, r, s, wasOpen, wasClear;
  if(!SS.sites) SS.sites=[];
  for(i=0;i<rows.length&&i<3;i++){
    r=rows[i];
    if(!r||typeof r.length!=='number'||r.length<7||!isFinite(+r[1])||!isFinite(+r[2])||!isFinite(+r[3])) continue;
    s=null; for(j=0;j<SS.sites.length;j++) if(SS.sites[j].i===(r[0]|0)){ s=SS.sites[j]; break; }
    if(!s){ s={i:r[0]|0,x:0,y:0,r:SH.r,ga:0,gw:SH.gw,open:0,prog:0,w2:0,clear:0,def:[],def2:[],cache:null}; SS.sites.push(s); }
    wasOpen=s.open; wasClear=s.clear;
    s.x=+r[1]; s.y=+r[2]; s.ga=+r[3]; s.open=r[4]?1:0; s.clear=r[6]?1:0;
    s.prog=s.open?1:Math.max(+r[5]||0,(wasOpen?0:s.prog));
    if(s.open&&!wasOpen&&s.fresh){ try{ var gp=shGatePt(s); sfx('boom',gp.x,gp.y); spark(gp.x,gp.y,'#ffcf7a',24,300); say('GATE BREACHED','warn',{sub:'THEY ARE COMING'}); }catch(_so){} }
    if(s.clear&&!wasClear&&s.fresh){ try{ say('STRONGHOLD CLEARED','ext',{sub:'STRONGHOLD'}); }catch(_sc){} }
    s.fresh=1;
  }
  if(SS.sites.length&&!SS.told){ SS.told=1; try{ say('STRONGHOLD','info',{sub:SS.sites.length+' ON THE MAP'}); }catch(_st){} }
  return SS.sites.length;
}
function shPeerTick(dt){
  var SS=shS(), i, s, p=G.player, gp, d, near, t=G.t||0;
  if(!SS.sites||!p) return;
  for(i=0;i<SS.sites.length;i++){
    s=SS.sites[i];
    if(!p.specOut) shKeep(s,p,p.r||11);
    if(s.open||p.downed||p.dying){ continue; }
    gp=shGatePt(s); d=Math.hypot(p.x-gp.x,p.y-gp.y);
    near=(d<SH.reach)&&(p.shS&&p.shS[s.i]===2);
    s.prog=near?Math.min(0.999,s.prog+dt/SH.breach):Math.max(0,s.prog-dt*2/SH.breach);   // looks only: the host counts the real breach
    if(near&&(t-(+s.gateAt||-9)>=0.25||t<(+s.gateAt||0))){ s.gateAt=t; flowNetPost({k:'gate',i:s.i}); }
  }
}
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='27.11';
'@ @'
var VER='27.12';
'@

$pat = "(?m)^  now:'v27\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.12: Player 2 now sees the strongholds, is fenced by them, and can breach the gate with player 1. Check 27.12 fails on v27.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
