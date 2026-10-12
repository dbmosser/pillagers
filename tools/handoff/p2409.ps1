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

# 3, 2, 1, GO! (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function startRaid(){

'@ @'
// v23.xx, HIS ANSWERS (2026-10-12), answer 18: "3-2-1 GO countdown". EVERY RAID STARTS ON A COUNT. "Gameplay elements like you are
// asking about here should be exactly the same in demo and career", so a CAREER raid and a DEMO run both open on 3, 2, 1, GO!, big in
// the centre over a light scrim, with a low beep on each number and a high one on GO. The world is held through the count: no clock,
// no machines, no bullets and no player step, the way the pause holds it, so nothing can shoot him before he has his bearings, and
// the first fight still comes inside half a minute (answer 1). GO! stays up for 0.8 s of play. A late joiner comes up straight into
// the running raid with no count (netLateApply), and the DEMO re-drop after a death keeps its own DROPPING IN hold. The bot and the
// sim never count (G.sim), so no seeded draw moves. GO_SEC is the length; the test fixture sets it to 0 so the older checks start
// their raids as before, and the countdown check sets it back to 3.
var GO_SEC=3;
function goTick(dt){
  if(!G||!(G.goT>0)) return false;
  G.goT=Math.max(0,G.goT-(dt>0?dt:0));
  var n=Math.ceil(G.goT);
  if(n>0&&n!==G.goN){ G.goN=n; try{ blip('countgo',undefined,undefined,0); }catch(_cb){} }
  if(G.goT<=0){ G.goN=0; G.goAt=G.t||0; try{ blip('countgo',undefined,undefined,1); }catch(_cg){} }
  return true;
}
function drawGoCount(){
  if(!G||G.over||!G.player) return false;
  var s='', k=0, n, z, cx=Math.round(W/2), cy=Math.round(H*0.42), sc, al;
  if(G.goT>0){ n=Math.ceil(G.goT); s=String(n); k=G.goT-(n-1); }
  else if(typeof G.goAt==='number'&&(G.t||0)-G.goAt<0.8){ s='GO!'; k=1-((G.t||0)-G.goAt)/0.8; }
  if(!s) return false;
  z=Math.max(1,(typeof hudRes==='function')?hudRes():1);
  sc=1+0.45*Math.max(0,(k-0.80)/0.20);
  al=Math.max(0,Math.min(1,k/0.25));
  ctx.save();
  if(G.goT>0){ ctx.fillStyle='rgba(6,7,8,.28)'; ctx.fillRect(0,0,W,H); }
  ctx.globalAlpha=al; ctx.textAlign='center'; ctx.textBaseline='middle';
  ctx.translate(cx,cy); ctx.scale(sc,sc);
  ctx.font=hudFS('800 '+(s==='GO!'?92:110)+'px '+HUDF);
  ctx.fillStyle=(s==='GO!')?UIC.acc:UIC.tx_1;
  hudText(s,0,0,7*z);
  ctx.restore();
  return true;
}
function startRaid(){

'@

SubRx @'
  applyGhost();
  showScreen('raid');

'@ @'
  applyGhost();
  showScreen('raid');
  if(G&&!G.sim&&GO_SEC>0){ G.goT=GO_SEC; G.goN=0; G.goAt=null; }   // v23.xx (his answer 18): the raid opens on 3, 2, 1, GO!

'@

SubRx @'
  if((!G.paused||netPauseLive())&&!G.over&&G.deathBeat!==undefined&&G.deathBeat!==null){

'@ @'
  if(G.goT>0&&!G.over){ if(!G.paused||netPauseLive()) goTick(clamp(gap0/1000,0,.05)); }   // v23.xx (his answer 18): the world is held through 3, 2, 1, GO!
  else if((!G.paused||netPauseLive())&&!G.over&&G.deathBeat!==undefined&&G.deathBeat!==null){

'@

SubRx @'
try{ G.lateEl=elapsed(); }catch(_le){}
'@ @'
G.goT=0; G.goAt=null; try{ G.lateEl=elapsed(); }catch(_le){}
'@

SubRx @'
  if(G.arcade){ try{ arcadeHud(); }catch(_ahd){} }
'@ @'
  if(G.arcade){ try{ arcadeHud(); }catch(_ahd){} }
  try{ drawGoCount(); }catch(_gco){}   // v23.xx (his answer 18): 3, 2, 1, GO!
'@

SubRx @'
  } else if(type==='clocktick'){

'@ @'
  } else if(type==='countgo'){
    // v23.xx (his answer 18): the raid start count. A short low beep on 3, 2 and 1 and a longer high one on GO, a square through a
    // lowpass, on the ui bus so nothing ducks it.
    var cgHi=!!arguments[3], cgO=a.createOscillator(), cgF=a.createBiquadFilter(), cgG=a.createGain(), cgOut=sndBus('ui')||OUT, cgL=cgHi?.42:.16;
    cgO.type='square'; cgO.frequency.setValueAtTime(cgHi?880:440,t);
    cgF.type='lowpass'; cgF.frequency.value=cgHi?3200:2000;
    cgG.gain.setValueAtTime(.0001,t); cgG.gain.linearRampToValueAtTime(.05*vol,t+.01);
    cgG.gain.setValueAtTime(.05*vol,t+cgL-.06); cgG.gain.exponentialRampToValueAtTime(.001,t+cgL);
    cgO.connect(cgF); cgF.connect(cgG); cgG.connect(cgOut); cgO.start(t); cgO.stop(t+cgL+.02);
  } else if(type==='clocktick'){

'@

SubRx @'
var VER='24.08';
'@ @'
var VER='24.09';
'@

$pat = "(?m)^  now:'v24\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.09: Every raid and demo run opens on 3, 2, 1, GO with the world held until GO. Check 24.09 fails on v24.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
