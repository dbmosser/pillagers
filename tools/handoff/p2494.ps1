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

# A NEAR MISS WHIZZES PAST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v23.90, HIS ORDER 2026-10-12 (his #45, improve all sound as much as possible): FOOTSTEPS ON WHAT IS UNDER THEM.
'@ @'
// v24.xx (sndA1), HIS ORDER 2026-10-12 (about 21:48): "improve dsound generally, look for other actions that don't have disntinct noises
// yetr and add them". THE NEW NOISES. Each new noise is one generator in SNDA_GEN, played through blip like every other sound (so the
// bus, the pan, the distance fade, the wall muffle and the G.sim and spectating guards are the ones every sound already has), built
// the way the punchy guns are built: a transient, a short body, a short tail, a few nodes each. SNDA.at rate-limits each one so twenty
// of them in a fight never smear or clip; SNDA.n counts what was actually played. Cosmetic only: Math.random fills the noise buffers
// and nothing else, no seeded draw, no game state.
var SNDA={n:{},at:{}}, SNDA_GEN={};
function sndAGate(k,gap,t){
  var l=SNDA.at[k];
  if(gap>0&&l!==undefined&&t>=l&&t-l<gap) return false;
  SNDA.at[k]=t; SNDA.n[k]=(SNDA.n[k]||0)+1;
  return true;
}
// a noise burst: o.dur seconds, shaped (o.swell rises then falls, else it decays with power o.pw), through one filter that can sweep
// from o.f0 to o.f1, at gain o.g, starting at o.at
function sndANoise(a,OUT,o){
  var n=Math.max(16,Math.floor(a.sampleRate*o.dur)), b=a.createBuffer(1,n,a.sampleRate), c=b.getChannelData(0), i, x, s, f, g;
  for(i=0;i<n;i++){ x=i/n; c[i]=(Math.random()*2-1)*(o.swell?Math.sin(Math.PI*Math.pow(x,o.swell)):Math.pow(1-x,o.pw||2)); }
  s=a.createBufferSource(); s.buffer=b;
  f=a.createBiquadFilter(); f.type=o.ft||'bandpass'; f.Q.value=o.q||1;
  f.frequency.setValueAtTime(o.f0,o.at); if(o.f1) f.frequency.exponentialRampToValueAtTime(o.f1,o.at+o.dur);
  g=a.createGain(); g.gain.value=o.g;
  s.connect(f); f.connect(g); g.connect(OUT); s.start(o.at);
  return s;
}
// a pitched blip: f0 to f1 over dur, a 4 ms attack, gone by the end
function sndATone(a,OUT,ty,f0,f1,dur,gv,at){
  var o=a.createOscillator(), g=a.createGain(); o.type=ty;
  o.frequency.setValueAtTime(f0,at); o.frequency.exponentialRampToValueAtTime(f1,at+dur);
  g.gain.setValueAtTime(0.0001,at); g.gain.exponentialRampToValueAtTime(Math.max(0.0002,gv),at+Math.min(0.004,dur/4)); g.gain.exponentialRampToValueAtTime(0.0001,at+dur+0.01);
  o.connect(g); g.connect(OUT); o.start(at); o.stop(at+dur+0.03);
  return o;
}
// THE NEAR MISS. An enemy round that missed you narrowly flew past in silence: enemy fire was heard only at the gun. Now a round that
// passes within 40 of you without hitting whizzes past once, on the side it passed: an 85 ms band of noise sweeping down from 3.5 kHz
// to 1.2 kHz (the falling pitch of a round going by) and a tiny 4 kHz snap at the front of it. On the HUD bus, so a fight never
// buries it; one at a time in 50 ms, so a shotgun blast past you is one whizz, not eight.
SND_CAT.whizz='ui';
SNDA_GEN.whizz=function(a,OUT,vol,t){
  if(!sndAGate('whizz',0.05,t)) return;
  sndANoise(a,OUT,{dur:0.085,swell:0.6,ft:'bandpass',f0:3500,f1:1200,q:1.6,g:0.12*vol,at:t});
  sndATone(a,OUT,'triangle',4200,3000,0.014,0.05*vol,t);
};
// v23.90, HIS ORDER 2026-10-12 (his #45, improve all sound as much as possible): FOOTSTEPS ON WHAT IS UNDER THEM.
'@

SubRx @'
  if(SND_CTX&&SND_CTX.lp>0){ var olp=a.createBiquadFilter(); olp.type='lowpass'; olp.frequency.value=SND_CTX.lp; olp.Q.value=0.7; olp.connect(OUT); OUT=olp; }   // v23.73 (his #45): through the wall
'@ @'
  if(SND_CTX&&SND_CTX.lp>0){ var olp=a.createBiquadFilter(); olp.type='lowpass'; olp.frequency.value=SND_CTX.lp; olp.Q.value=0.7; olp.connect(OUT); OUT=olp; }   // v23.73 (his #45): through the wall
  if(SNDA_GEN[type]){ try{ SNDA_GEN[type](a,OUT,vol,t,arguments[3],d); }catch(_sa){} return; }   // v24.xx (sndA1): the new noises
'@

SubRx @'
          if(!_mOwn&&!p.specOut&&dist(b,p)<p.r+3){ damagePlayer(b.dmg,b.owner.kind,b.owner.name,b.x-b.vx*0.05,b.y-b.vy*0.05); spark(b.x,b.y,'#ff5a4a',10,200); hit=true; }
'@ @'
          if(!_mOwn&&!p.specOut&&dist(b,p)<p.r+3){ damagePlayer(b.dmg,b.owner.kind,b.owner.name,b.x-b.vx*0.05,b.y-b.vy*0.05); spark(b.x,b.y,'#ff5a4a',10,200); hit=true; }
          // v24.xx (sndA1), his order 2026-10-12 (distinct noises): A ROUND THAT MISSES YOU NARROWLY WHIZZES PAST, once per round, the
          // first time it comes within 40 of you on a line that will not hit you; panned to the side of you it passes. Sound only.
          if(!hit&&!_mOwn&&!b._wz&&!G.sim&&!p.specOut&&!p.downed&&trav>0){
            var _wzx=b.x-p.x, _wzy=b.y-p.y;
            if(_wzx*_wzx+_wzy*_wzy<1600){ var _wzu=_wzx*ux+_wzy*uy, _wzpx=_wzx-_wzu*ux, _wzpy=_wzy-_wzu*uy; if(_wzpx*_wzpx+_wzpy*_wzpy>=(p.r+3)*(p.r+3)){ b._wz=1; blip('whizz',undefined,clamp(_wzpx/30,-1,1)); } }
          }
'@

SubRx @'
var VER='24.93';
'@ @'
var VER='24.94';
'@

$pat = "(?m)^  now:'v24\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.94: An enemy round that just misses you now whizzes past on the side it went by. Check 24.94 fails on v24.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
