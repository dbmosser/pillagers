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

# ARCADE: PLAYER 2 DROPS IN WITH A (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
     iss:g.issDraw?1:0,terms:netUpTerms(termsOn()),merc:(P&&typeof P.merc==='string')?P.merc:'',cfg:netUpCfgDiff(),fp:netUpFp(g)};
'@ @'
     iss:g.issDraw?1:0,terms:netUpTerms(termsOn()),merc:(P&&typeof P.merc==='string')?P.merc:'',cfg:netUpCfgDiff(),fp:netUpFp(g)};
  if(g.arcade) m.arc=1;   // v23.25 (arcade6): an arcade raid word says so; only arcade words gain the field
'@

SubRx @'
  try{ commitKit(); }catch(e0){}   // its own packed kit, as MY LOADOUT commits it, saved under its own dials
'@ @'
  if(!m.arc) try{ commitKit(); }catch(e0){}   // its own packed kit, as MY LOADOUT commits it, saved under its own dials   // v23.25 (arcade6): never for an arcade word, whose kit is the sandbox random kit
'@

SubRx @'
  m.gone=gone;
'@ @'
  m.gone=gone;
  if(G.arcade&&G.player.specOut) m.late.bench=1;   // v23.25 (arcade6): player 1 is benched, so player 2 is not stood beside him
'@

SubRx @'
  if(!netSend(peer,m)) return 'lost';
'@ @'
  if(!netSend(peer,m)) return 'lost';
  if(G.arcade){ try{ say('PLAYER 2 JOINED','ally'); }catch(_aj){} } else   // v23.25 (arcade6): the arcade callout; the line below is the normal one
'@

SubRx @'
  say('YOU JOINED THE RAID IN PROGRESS','ally');   // v22.xx (R54): a caps callout
'@ @'
  if(G.arcade&&L.bench){ try{ arcadeRedropSpot(p,G,0); }catch(_ars){} }   // v23.25 (arcade6): player 1 is benched, so player 2 starts at the map spawn farthest from live hostiles
  say('YOU JOINED THE RAID IN PROGRESS','ally');   // v22.xx (R54): a caps callout
'@

SubRx @'
  if(!want){ if(b&&b.parentNode) b.parentNode.removeChild(b); return false; }
'@ @'
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) want=false;   // v23.25 (arcade6): the arcade joins with A, never with this button
  if(!want){ if(b&&b.parentNode) b.parentNode.removeChild(b); return false; }
'@

SubRx @'
  if(typeof m.seed!=='number'||!isFinite(m.seed)) return 'bad';
'@ @'
  if(typeof m.seed!=='number'||!isFinite(m.seed)) return 'bad';
  // v23.25 (arcade6): an arcade window takes only arcade words, and only once its player pressed A (wantIn) or while it is in an
  // arcade raid already. The same raid in hand is kept; an older arcade raid is stopped first, so the new word is never refused
  // as up top already.
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on){
    if(!m.arc) return 'arc:plain';
    NET.hostSeed=m.seed>>>0;
    if(typeof G!=='undefined'&&G&&G.arcade&&!G.over){
      if((G.seed>>>0)===(m.seed>>>0)) return 'arc:have';
      arcadeRaidStop('swap');
    } else if(!ARCADE.wantIn) return 'arc:wait';
  }
'@

SubRx @'
  var _lr=netUpStart(m);
'@ @'
  var _lr=netUpStart(m);
  if(m.arc&&_lr==='up'&&typeof ARCADE==='object'&&ARCADE&&ARCADE.on){ ARCADE.wantIn=0; ARCADE.late=0; }   // v23.25 (arcade6): in; a later arcade word is taken because he is in an arcade raid
'@

SubRx @'
      if(G.arcade&&ARCADE.holdT>0){ ARCADE.holdT=Math.max(0,ARCADE.holdT-dt); netPausedStep(dt); }   // v23.22 (arcade3): the drop-in hold after an arcade respawn, he stands still while the world runs on
'@ @'
      if(G.arcade&&((+ARCADE.holdT||0)>0||(G.player&&G.player.specOut))){ ARCADE.holdT=Math.max(0,(+ARCADE.holdT||0)-dt); netPausedStep(dt); }   // v23.22 (arcade3): the drop-in hold after an arcade respawn, he stands still while the world runs on. v23.25 (arcade6): and a benched player 1
'@

SubRx @'
  ARCADE.deaths=(ARCADE.deaths|0)+1;
'@ @'
  if(why!=='bench') ARCADE.deaths=(ARCADE.deaths|0)+1;   // v23.25 (arcade6): coming off the bench is not a death
'@

SubRx @'
    if(m.t==='arcoff') return arcadeLeave()?'arcoff':'ignored';
'@ @'
    if(m.t==='arcoff') return arcadeLeave()?'arcoff':'ignored';
    // v23.25 (arcade6): the answers to arcjoin. fresh 1: wait for the raid word. fresh 0: ask to join the raid in progress (again every
    // 1.5 s from arcadeAttTick until in). arcnew: the host is building a fresh raid, wait for its word.
    if(m.t==='arcgo'){ if(!ARCADE.wantIn) return 'ignored'; ARCADE.late=m.fresh?0:1; ARCADE.askAt=Date.now(); if(ARCADE.late) netLateAsk(); return 'arcgo'; }
    if(m.t==='arcnew'){ ARCADE.late=0; ARCADE.askAt=Date.now(); return 'arcnew'; }
'@

SubRx @'
    if(m.t==='arcbusy'){ try{ say('PLAYER 2 IS IN A RAID','warn'); }catch(_sb){} return 'busy'; }
'@ @'
    if(m.t==='arcbusy'){ try{ say('PLAYER 2 IS IN A RAID','warn'); }catch(_sb){} return 'busy'; }
    if(m.t==='arcjoin') return arcadeJoinAsk();   // v23.25 (arcade6): player 2 pressed A
'@

SubRx @'
w=(ARCADE.role==='p2')?'PLAYER 2: PRESS A':'PRESS ANY BUTTON'
'@ @'
w=(ARCADE.role==='p2')?'PLAYER 2: PRESS A':(arcadeBenched()?'PLAYER 1: PRESS ANY BUTTON':'PRESS ANY BUTTON')
'@

SubRx @'
function arcadeAttTick(){
  if(!ARCADE.on) return;
  if(G&&G.arcade){ if(ATT.on) attStop(); return; }
  arcadeAttShow();
}
'@ @'
function arcadeAttTick(){
  if(!ARCADE.on) return;
  if(G&&G.arcade&&!arcadeBenched()){ if(ATT.on) attStop(); return; }   // v23.25 (arcade6): a benched player 1 keeps the attract
  // v23.25 (arcade6): player 2 asked to join and is not in yet: ask again (arcjoin every 3 s, or the raid in progress every 1.5 s after arcgo fresh 0)
  if(ARCADE.role==='p2'&&ARCADE.wantIn&&!(G&&G.arcade)){
    var nw=Date.now();
    if(nw-(+ARCADE.askAt||0)>=(ARCADE.late?1500:3000)){ ARCADE.askAt=nw; if(ARCADE.late) netLateAsk(); else netSamePost({t:'arcjoin',pair:NET.pair}); }
  }
  arcadeAttShow();
}
'@

SubRx @'
  if(G&&G.arcade) return false;            // a raid is on here: the key plays
'@ @'
  if(G&&G.arcade&&!arcadeBenched()) return false;            // a raid is on here: the key plays (v23.25, arcade6: unless player 1 is benched)
'@

SubRx @'
  arcadeDropIn();
  return true;
}
'@ @'
  if(arcadeBenched()) arcadeUnbench(); else arcadeDropIn();   // v23.25 (arcade6)
  return true;
}
'@

SubRx @'
  if(ARCADE.role==='p2'){ if(!aNew) return false; ARCADE.wantIn=1; netSamePost({t:'arcjoin',pair:NET.pair}); return true; }
  return anyNew?arcadeDropIn():false;
'@ @'
  if(ARCADE.role==='p2'){ if(!aNew) return false; ARCADE.wantIn=1; ARCADE.late=0; ARCADE.askAt=Date.now(); netSamePost({t:'arcjoin',pair:NET.pair}); return true; }   // v23.25 (arcade6): arcadeAttTick asks again until he is in
  if(anyNew&&arcadeBenched()) return arcadeUnbench();   // v23.25 (arcade6): a benched player 1 comes back beside player 2
  return anyNew?arcadeDropIn():false;
'@

SubRx @'
// Leaving the arcade: the arcade raid stops, then the sandbox out puts his profile and his dials back. v23.24: the host tells
'@ @'
// v23.25, HIS ORDER (2026-10-11), build 6 of 20 (arcade6): PLAYER 2 DROPS IN WITH A. Player 2 pressing A asks the host (arcjoin), and
// the host answers one of three ways. No arcade raid on: it builds one with player 1 BENCHED (specOut: frozen, nobody is target,
// no damage, no kill credit) under the attract, which now reads PLAYER 1: PRESS ANY BUTTON, and tells player 2 to wait for the
// raid word (arcgo fresh 1). An arcade raid on that the party was told about: arcgo fresh 0, and player 2 asks to join the raid
// in progress (netLateAsk, every 1.5 s until it is in). An arcade raid built before the link was up (no raid word went out for
// it): arcadeRebuild, a fresh raid on the same sector with player 1 keeping his score, after arcnew. With no link yet the host
// does nothing and player 2 asks again every 3 s. Player 2 takes only arcade raid words (m.arc), only after A, never commits a
// packed kit, and starts beside player 1 (or at a map spawn while he is benched). Any press from a benched player 1 brings him
// back beside player 2 with a fresh kit and the drop-in hold. Normal co-op is untouched: every line is behind ARCADE.on or G.arcade.
function arcadeBenched(){ return !!(ARCADE.on&&ARCADE.role==='host'&&G&&G.arcade&&!G.over&&G.player&&G.player.specOut); }
function arcadeUnbench(){
  if(!arcadeBenched()) return false;
  G.player.specOut=0;
  try{ attStop(); }catch(_as){}
  arcadeRespawn('bench');
  return true;
}
// The host, on arcjoin. Returns what it did.
function arcadeJoinAsk(){
  if(!ARCADE.on||ARCADE.role!=='host') return 'off';
  if(!(G&&G.arcade&&!G.over)){
    if(G&&!G.over) return 'busy';
    netSamePost({t:'arcgo',fresh:1,pair:NET.pair});
    try{ attStop(); }catch(_as){}
    if(!arcadeDeploy({role:'host'})||!G||!G.player){ try{ arcadeAttShow(); }catch(_aa){} return 'fail'; }
    G.player.specOut=1; G.player.vx=0; G.player.vy=0;
    arcadeAttShow();
    return 'bench';
  }
  if(!NET.on) return 'nolink';
  if(NET.upWord&&(NET.upWord.seed>>>0)===(G.seed>>>0)){ netSamePost({t:'arcgo',fresh:0,pair:NET.pair}); return 'go'; }
  return arcadeRebuild()?'new':'fail';
}
// A fresh arcade raid on the same sector for a player 2 who cannot join this one: player 1 keeps his score (and his bench).
function arcadeRebuild(){
  if(!ARCADE.on||ARCADE.role!=='host'||!G||!G.arcade) return false;
  var s={mine:ARCADE.mine|0,mate:ARCADE.mate|0,ext:ARCADE.ext|0,deaths:ARCADE.deaths|0}, bench=!!(G.player&&G.player.specOut), ok;
  netSamePost({t:'arcnew',pair:NET.pair});
  ok=arcadeDeploy({role:'host',mapIx:P.mapIx});
  ARCADE.mine=s.mine; ARCADE.mate=s.mate; ARCADE.ext=s.ext; ARCADE.deaths=s.deaths;
  if(!ok||!G||!G.player){ try{ arcadeAttShow(); }catch(_aa){} return false; }
  if(bench){ G.player.specOut=1; arcadeAttShow(); }
  try{ say('PLAYER 2 JOINING','ally'); }catch(_sj){}
  return true;
}
// Leaving the arcade: the arcade raid stops, then the sandbox out puts his profile and his dials back. v23.24: the host tells
'@

SubRx @'
var VER='23.24';
'@ @'
var VER='23.25';
'@

$pat = "(?m)^  now:'v23\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.25: Player 2 joins the arcade with A: player 1 waits on the bench until he presses a button. Check 23.25 fails on v23.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
