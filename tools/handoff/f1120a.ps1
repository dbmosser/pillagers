$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v11.20 harness: a seeded sim trace, built the way __simSeedsFull builds, so a
# batch outcome can be replayed and the bot watched. Samples every 10 seconds of
# raid time: position, distance moved since the last sample, the building it is
# in, its route length and whether the search failed.
SubRx @'
window.__simTrace=function(){
  G=buildRaid(true);
'@ @'
window.__simTraceSeed=function(seed){
  pendSeed=seed>>>0; G=null;
  G=buildRaid(true);
  var samples=[],guard=0,cap=Math.round(CFG.raidSec/0.15)+200,next=0,B=G.map.buildings,lx=G.player.x,ly=G.player.y;
  function inB(p){ for(var i=0;i<B.length;i++){ var b=B[i]; if(p.x>b.x&&p.x<b.x+b.w&&p.y>b.y&&p.y<b.y+b.h) return i; } return -1; }
  while(!G.over&&guard<cap){
    simStep(.15); guard++;
    if(G.t>=next){
      next+=10;
      var p=G.player;
      samples.push([Math.round(G.t),Math.round(p.x),Math.round(p.y),Math.round(dist(p,{x:lx,y:ly})),inB(p),p.path?p.path.length:0,p.pathFail?1:0,Math.round(p.hp),+bagWeight().toFixed(0)]);
      lx=p.x; ly=p.y;
    }
  }
  if(!G.over){ G.tel.deathKiller='timer'; endRaid('dead'); }
  var r=G.simResult; G=null;
  return {seed:seed,outcome:r.outcome,killer:r.killer,samples:samples};
};
window.__simTrace=function(){
  G=buildRaid(true);
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
