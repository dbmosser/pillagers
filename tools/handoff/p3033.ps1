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

# A 2 player run ends only when both players are out (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ARCADE.ext=(ARCADE.ext|0)+1;
  return arcadeX2();
'@ @'
  // v28.xx (cw-bothout), his answer Q65 (2026-10-18): "In 2P the run ends when both players are out." One player extracting no longer ends a
  // 2 player run: the host stands out (benched, as the idle bench does) and the run goes on for player 2; player 2 extracting later (arcx)
  // doubles both and ends it. A 1 player run, a host whose teammate is not up, or a host whose teammate already extracted ends as before.
  if(!ARCADE.solo&&ARCADE.xOut!=='p'&&typeof arcadeMateLive==='function'&&arcadeMateLive()){
    var _xi, _xz;
    ARCADE.ext=(ARCADE.ext|0)+1; ARCADE.xOut='h';
    for(_xi=0;_xi<(G.zones||[]).length;_xi++){ _xz=G.zones[_xi]; if(!_xz) continue; if(dist(p,_xz)<_xz.r&&typeof _xz.hold==='number'){ _xz.beaconT=null; _xz.hold=null; if(_xz===G.active){ G.beaconT=null; G.shipHold=null; } } _xz.pullT=null; _xz.boardT=0; _xz.pullFloor=0; }
    p.specOut=1; p.vx=0; p.vy=0; keys={};
    try{ say('Extracted','ally',{sub:'Player 2 is still out'}); }catch(_xs){}
    try{ arcadeScSend(); }catch(_xc){}
    try{ arcadeAttShow(); }catch(_xa){}
    return true;
  }
  ARCADE.ext=(ARCADE.ext|0)+1;
  return arcadeX2();
'@

SubRx @'
      ARCADE.mate=Math.max(ARCADE.mate|0,Math.round(+m.s||0)); ARCADE.mateK=Math.max(ARCADE.mateK|0,m.k|0); ARCADE.mateX=(ARCADE.mateX|0)+1;
      arcadeX2();
'@ @'
      ARCADE.mate=Math.max(ARCADE.mate|0,Math.round(+m.s||0)); ARCADE.mateK=Math.max(ARCADE.mateK|0,m.k|0); ARCADE.mateX=(ARCADE.mateX|0)+1;
      if(!arcadeBenched()&&arcadeMateLive()){ ARCADE.xOut='p'; try{ say('Player 2 extracted','ally',{sub:'Your run goes on'}); }catch(_xp){} return 'arcx'; }   // v28.xx (cw-bothout), his Q65: the run ends when both players are out
      arcadeX2();
'@

SubRx @'
function arcadeUnbench(){
  if(!arcadeBenched()) return false;
'@ @'
function arcadeUnbench(){
  if(!arcadeBenched()) return false;
  if(ARCADE.xOut==='h') return false;   // v28.xx (cw-bothout): he extracted; he stays out until the run ends
'@

SubRx @'
ARCADE.deaths=0; ARCADE.holdT=0;   // v23.22 (arcade3)
'@ @'
ARCADE.deaths=0; ARCADE.holdT=0; ARCADE.xOut=0;   // v23.22 (arcade3); v28.xx (cw-bothout): who has extracted
'@

SubRx @'
ext:ARCADE.ext|0,deaths:ARCADE.deaths|0}, bench=
'@ @'
ext:ARCADE.ext|0,deaths:ARCADE.deaths|0,xo:ARCADE.xOut||0}, bench=
'@

SubRx @'
ARCADE.mine=s.mine; ARCADE.mate=s.mate; ARCADE.ext=s.ext; ARCADE.deaths=s.deaths;
'@ @'
ARCADE.mine=s.mine; ARCADE.mate=s.mate; ARCADE.ext=s.ext; ARCADE.deaths=s.deaths; ARCADE.xOut=s.xo;
'@

SubRx @'
  if(G.over||!p||!netInCount()) return 0;
  // v16.96, co-op hunt
'@ @'
  if(G.over||!p||!netInCount()) return 0;
  if(G.arcade&&p.specOut&&typeof ARCADE==='object'&&ARCADE&&ARCADE.role==='p2') return 0;   // v28.xx (cw-bothout): player 2 extracted and waits for the run end; its body leaves the host's world
  // v16.96, co-op hunt
'@

SubRx @'
var VER='30.32';
'@ @'
var VER='30.33';
'@

$pat = "(?m)^  now:'v30\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.33: In a 2 player run, one player extracting no longer ends the run for the other. Check 30.33 fails on v30.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
