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

# end run leaves only your seat (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  togglePauseBox(false); try{ arcadeRunEnd('menu'); }catch(_are){}
'@ @'
  togglePauseBox(false); try{ arcadeMenuOut(); }catch(_are){}
'@

SubRx @'
function arcadeX2(){
'@ @'
function arcadeX2(){
  // v28.xx (cw-cx-endseat): an early exit keeps the existing menu penalty; it is not a team extraction.
  if(G.arcMenuOut||ARCADE.menuMate){ G.arcEnd='menu'; return true; }
'@

SubRx @'
  ARCADE.deaths=0; ARCADE.holdT=0; ARCADE.xOut=0;
'@ @'
  ARCADE.menuMate=0; ARCADE.deaths=0; ARCADE.holdT=0; ARCADE.xOut=0;
'@

SubRx @'
    if(m.t==='arcleft'){ ARCADE.mateAt=0; if(arcadeBenched()) arcadeRunEnd('idle'); return 'arcleft'; }
'@ @'
    // v28.xx (cw-cx-endseat): the peer leaves only its own seat. Reject stale and repeated exits.
    if(m.t==='arcquit'){
      if(!G||!G.arcade||G.over||G.arcEnd||!ARCADE.run||String(m.run||'')!==ARCADE.run.id||ARCADE.menuMate||ARCADE.xOut==='p') return 'ignored';
      ARCADE.menuMate=1; ARCADE.xOut='p';
      ARCADE.mate=Math.max(0,Math.round(+m.s||0)); ARCADE.mateK=Math.max(0,m.k|0);
      if(arcadeBenched()) arcadeRunEnd('menu');
      return 'arcquit';
    }
    if(m.t==='arcleft'){ ARCADE.mateAt=0; if(arcadeBenched()) arcadeRunEnd(G&&G.arcMenuOut?'menu':'idle'); return 'arcleft'; }
'@

SubRx @'
// The run end, from idle or END RUN. Player 2 that is not the run authority goes out instead.
'@ @'
// v28.xx (cw-cx-endseat), his answer 2.23 a: end run takes out only the player who pressed it.
function arcadeMenuOut(){
  if(!ARCADE.on||!G||!G.arcade||G.over||!G.player) return false;
  if(G.arcMenuOut||G.arcX) return true;
  if(ARCADE.solo||G.netWasJoin) return arcadeRunEnd('menu');
  if(ARCADE.role==='host'&&(ARCADE.xOut==='p'||!arcadeMateLive())) return arcadeRunEnd('menu');
  var i, z;
  G.arcMenuOut=1; G.arcX=1;
  // v28.xx (cw-cx-endseat): release only this seat's boarding progress, keeping the partner's ship and clock.
  for(i=0;i<(G.zones||[]).length;i++){ z=G.zones[i]; if(z){ z.pullT=null; z.boardT=0; z.pullFloor=0; } }
  G.player.specOut=1; G.player.vx=0; G.player.vy=0; keys={}; mouse.down=false;
  if(ARCADE.role==='p2'){
    netSamePost({t:'arcquit',pair:NET.pair,run:String((ARCADE.run&&ARCADE.run.id)||''),s:Math.max(0,ARCADE.mine|0),k:Math.max(0,ARCADE.kills|0)});
  } else {
    ARCADE.xOut='h';
    try{ arcadeScSend(); }catch(_ms){}
  }
  try{ attStop(); }catch(_ma){}
  return true;
}
// The run end, from idle or END RUN. Player 2 that is not the run authority goes out instead.
'@

SubRx @'
var VER='37.66';
'@ @'
var VER='37.67';
'@

$pat = "(?m)^  now:'v37\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.67: End run keeps the world running for the other seat. Both exits settle the run with the existing early-end score penalty. Check 37.67 fails on v37.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
