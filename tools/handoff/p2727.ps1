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

# THE RUN GOALS ARE THE PARTY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // FLOW-NET-OUT (the next coop builds add their keys above this line)
'@ @'
  o.r=goalsNetOut();   // v27.27 (coop8): and the run goals
  // FLOW-NET-OUT (the next coop builds add their keys above this line)
'@

SubRx @'
  // FLOW-NET-IN (the next coop builds take their keys above this line)
'@ @'
  if(fl.r) goalsNetTake(fl.r);   // v27.27 (coop8): the run goals
  // FLOW-NET-IN (the next coop builds take their keys above this line)
'@

SubRx @'
function goalsTick(dt){
  var S=flowS(), i, gl, v;
'@ @'
function goalsTick(dt){
  var S=flowS(), i, gl, v;
  if(flowPeer()) return;   // v27.27 (coop8): a linked player 2 window counts nothing and pays no chip, the goals are the host (goalsNetTake)
'@

SubRx @'
  if(id==='air1') return (S.air&&S.air.used)|0;
'@ @'
  if(id==='air1') return ((S.air&&S.air.used)|0)+(S.pAir|0);   // v27.27 (coop8): a strike either player called
'@

SubRx @'
    if(NET.role==='host') for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSend(NET.peers[i],m);
'@ @'
    if(NET.role==='host'){
      flowS().pAir=(flowS().pAir|0)+1;   // v27.27 (coop8): and it counts for the run goal
      for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSend(NET.peers[i],m);
    }
'@

SubRx @'
  if(how==='dead'&&e.bySeat>0&&!e.byPlayer){ q=netPeerOfSeat(e.bySeat); if(q) netSend(q,{t:'kill',seat:e.bySeat,id:e.nid,k:e.kind,el:e.elite?1:0}); }
'@ @'
  if(how==='dead'&&e.bySeat>0&&!e.byPlayer){ q=netPeerOfSeat(e.bySeat); if(q) netSend(q,{t:'kill',seat:e.bySeat,id:e.nid,k:e.kind,el:e.elite?1:0}); try{ flowKill(e.kind,e.elite?1:0,!!(e.boss||e.name===BOSS_NAME)); }catch(_nfk){} }   // v27.27 (coop8): and a kill of player 2 counts for the run goals
'@

SubRx @'
      if(e.byPlayer!==false){ flowChip(BOUNTY.pay,'BOUNTY CLAIMED','BOUNTY PILLAGER'); ev.d.won=1; }
'@ @'
      if(e.byPlayer!==false||(e.bySeat|0)>0){ flowChip(BOUNTY.pay,'BOUNTY CLAIMED','BOUNTY PILLAGER'); ev.d.won=1; }   // v27.27 (coop8): player 2's kill claims it too
'@

SubRx @'
  T.push({l:'EXTRACTION',v:z?zoneBadge(z):(tz?'NONE CALLED':'ALL CLOSED'),c:z?HUDC.extract:(tz?'#cdd6dd':HUDC.danger),s:nz?('NEAREST '+extLetter(nz)+'  '+metres(bd)+'M '+compass8(nz.x-p.x,nz.y-p.y)):'',rail:z?HUDC.extract:'#4a5257'});
'@ @'
  T.push({l:'EXTRACTION',v:z?zoneBadge(z):(tz?'NONE CALLED':'ALL CLOSED'),c:z?HUDC.extract:(tz?'#cdd6dd':HUDC.danger),s:nz?('NEAREST '+extLetter(nz)+'  '+metres(bd)+'M '+compass8(nz.x-p.x,nz.y-p.y)):'',rail:z?HUDC.extract:'#4a5257'});
  try{ goalsTiles(T); }catch(_gtl){}   // v27.27 (coop8): the run goals, a tile each
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v27.27 (coop8), HIS ORDER (2026-10-14), the two player first: THE RUN GOALS ARE THE PARTY'S. Each window drew its own three goals and counted its own kills, crates and strikes, so the
// two lists drifted apart and a goal one player finished paid its chip twice (once from each window). The host now owns the goals: it says the three (key r: which, how far, done) in the world
// word, the linked window draws exactly those and says GOAL DONE when one is met, and counts and pays nothing (goalsTick). What counts is the PARTY'S: a kill of player 2 reaches the run goals
// (the host reports it where it credits the kill to his seat), his strike counts for AIR STRIKE, his kill of the bounty pillager claims the bounty, and the crates and vault doors he opens
// are the host's boxes and doors already. The goals are in the hold Alt raid status too, a tile each, with the figure or DONE.
function goalsNetOut(){
  var S=G.flow, a=[], i, gl;
  if(!S||!S.goals) return 0;
  for(i=0;i<S.goals.length&&i<3;i++){ gl=S.goals[i]; a.push([GOAL_IDS.indexOf(gl.id),gl.v|0,gl.done?1:0]); }
  return a;
}
function goalsNetTake(a){
  var S=flowS(), i, r, id, gl, first, was;
  if(!a||typeof a.length!=='number') return 0;
  first=!S.goals;
  if(first) S.goals=[];
  for(i=0;i<a.length&&i<3;i++){
    r=a[i]; if(!r||typeof r.length!=='number') continue;
    id=GOAL_IDS[r[0]|0]; if(!id||!GOALS[id]) continue;
    gl=S.goals[i];
    if(!gl||gl.id!==id){ gl={id:id,t:GOALS[id].t,n:GOALS[id].n,chip:GOALS[id].chip,v:0,done:0}; S.goals[i]=gl; }
    was=gl.done; gl.v=Math.min(gl.n,r[1]|0); gl.done=r[2]?1:0;
    if(gl.done&&!was&&!first){ try{ say('GOAL DONE','ext',{sub:gl.t}); }catch(_gd){} }
  }
  if(first&&!S.gtoldP){ S.gtoldP=1; try{ say('RUN GOALS','obj',{sub:'THREE SMALL GOALS'}); }catch(_rg){} }
  return S.goals.length;
}
// the goals as tiles of the raid status plate (the plate calls this; T is its list)
function goalsTiles(T){
  var S=G&&G.flow, i, gl;
  if(!S||!S.goals||!flowOn()) return 0;
  for(i=0;i<S.goals.length;i++){
    gl=S.goals[i];
    T.push({l:'RUN GOAL  '+gl.t,v:gl.done?'DONE':((gl.n>1)?(gl.v+' / '+gl.n):'NOT YET'),c:gl.done?'#7fc4a0':'#e8eef2',s:gl.done?'':('+'+arcadeCr(gl.chip)),rail:gl.done?'#7fc4a0':'#f5b73b'});
  }
  return S.goals.length;
}
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='27.26';
'@ @'
var VER='27.27';
'@

$pat = "(?m)^  now:'v27\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.27: The run goals are now shared by both players, and they show in the hold Alt raid status. Check 27.27 fails on v27.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
