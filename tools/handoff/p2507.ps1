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

# THE DOWNED NOISE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v23.73, HIS ORDER 2026-10-12 (his #45, improve all sound as much as possible): WALLS AND DISTANCE.
'@ @'
// v24.xx, HIS ORDER 2026-10-12 (about 21:30): "have a 'downed noise' -- anywhere that you added player speech, replace with a distinct
// noise". THE DOWNED NOISE. Going down was told by a spoken I AM DOWN (v24.57), a voice he hears as killing the vibe, and to the rest of
// the party by no sound at all. Going down now has a sound of its own that is never taken for a hit: a heavy body drop (a short burst of
// low noise and a thump falling from 110 to 34 Hz), a short dull ring like a concussion (two close sines near 1.5 kHz beating, gone by
// 1.35 s), and the world dips: everything in the world mix runs through a lowpass that falls to 380 Hz at once, holds a moment and
// opens again over about a second. The noise rides the sting bus, so the dip never muffles it and the split speakers carry it (player
// 1 left, player 2 right; player 2 hears his own fall in his own window). A teammate going down is heard where he fell: the drop and
// the thump only, panned and quieter with distance, no ring and no dip. Cosmetic only: Math.random fills the noise buffer, no seeded
// draw, no game state, never under G.sim or in the spectating host window.
var SND_DOWN={n:0,mine:0,mate:0,at:-1};
function sndDipOf(a){
  var S=SND, f, src;
  if(!S||!S.out||!a) return null;
  if(S.dip) return S.dip;
  src=S.trim||S.world; if(!src) return null;
  try{ f=a.createBiquadFilter(); f.type='lowpass'; f.frequency.value=a.sampleRate/2; f.Q.value=0.5; src.disconnect(); src.connect(f); f.connect(S.out); S.dip=f; }
  catch(e){ try{ src.connect(S.out); }catch(_e){} return null; }
  return f;
}
function sndDowned(mine,wx,wy){
  var a, out, t, e, vol=1, pan, pn, b, d, i, n, src, f, g, o, og, r1, r2, rg, dip, ny;
  if(G&&G.sim) return false;
  if(typeof NET==='object'&&NET&&NET.specTick) return false;
  a=ac(); if(!a) return false;
  out=sndBus('sting'); if(!out) return false;
  t=a.currentTime;
  if(!mine){
    if(wx===undefined||wy===undefined||!isFinite(wx)||!isFinite(wy)) return false;
    e=earsOf(wx,wy); vol=0.65*clamp(1-e.d/1400,0,1); if(vol<0.04) return false; pan=e.pan;
  }
  try{
    if(pan!==undefined&&PAN_OK&&a.createStereoPanner){ pn=a.createStereoPanner(); pn.pan.value=clamp(pan,-1,1); pn.connect(out); out=pn; }
    n=Math.floor(a.sampleRate*0.22); b=a.createBuffer(1,n,a.sampleRate); d=b.getChannelData(0);
    for(i=0;i<n;i++) d[i]=(Math.random()*2-1)*Math.pow(1-i/n,3);
    src=a.createBufferSource(); src.buffer=b;
    f=a.createBiquadFilter(); f.type='lowpass'; f.frequency.value=520; f.Q.value=0.9;
    g=a.createGain(); g.gain.value=0.28*vol;
    src.connect(f); f.connect(g); g.connect(out); src.start(t);
    o=a.createOscillator(); og=a.createGain(); o.type='sine';
    o.frequency.setValueAtTime(110,t); o.frequency.exponentialRampToValueAtTime(34,t+0.32);
    og.gain.setValueAtTime(0.0001,t); og.gain.exponentialRampToValueAtTime(0.26*vol,t+0.008); og.gain.exponentialRampToValueAtTime(0.0001,t+0.42);
    o.connect(og); og.connect(out); o.start(t); o.stop(t+0.45);
    if(mine){
      r1=a.createOscillator(); r2=a.createOscillator(); rg=a.createGain(); r1.type='sine'; r2.type='sine';
      r1.frequency.setValueAtTime(1480,t); r2.frequency.setValueAtTime(1486,t);
      rg.gain.setValueAtTime(0.0001,t+0.04); rg.gain.exponentialRampToValueAtTime(0.028,t+0.12); rg.gain.exponentialRampToValueAtTime(0.0001,t+1.3);
      r1.connect(rg); r2.connect(rg); rg.connect(out); r1.start(t+0.04); r2.start(t+0.04); r1.stop(t+1.35); r2.stop(t+1.35);
      dip=sndDipOf(a);
      if(dip){
        ny=a.sampleRate/2;
        dip.frequency.cancelScheduledValues(t); dip.frequency.setValueAtTime(ny,t);
        dip.frequency.exponentialRampToValueAtTime(380,t+0.05); dip.frequency.setValueAtTime(380,t+0.35);
        dip.frequency.exponentialRampToValueAtTime(ny,t+1.25);
      }
      SND_DOWN.mine++;
    } else SND_DOWN.mate++;
  }catch(err){ return false; }
  SND_DOWN.n++; SND_DOWN.at=t;
  return true;
}
// v23.73, HIS ORDER 2026-10-12 (his #45, improve all sound as much as possible): WALLS AND DISTANCE.
'@

SubRx @'
  if(!G.sim){ try{ voxBark('DOWN'); }catch(_vb){} }   // v24.57 (his #45): I AM DOWN
'@ @'
  if(!G.sim){ try{ sndDowned(1); }catch(_dn){} }   // v24.xx (his order 2026-10-12): the downed noise, where the spoken I AM DOWN was
'@

SubRx @'
padRumble(0.55,420); }catch(_md){} }
'@ @'
padRumble(0.55,420); try{ sndDowned(0,x,y); }catch(_dn){} }catch(_md){} }   // v24.xx (his order 2026-10-12): and heard, where he fell
'@

SubRx @'
var VER='25.06';
'@ @'
var VER='25.07';
'@

$pat = "(?m)^  now:'v25\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.07: Going down now lands with a heavy thump, a dull ring and a muffled world, and a teammate going down is heard where he fell. Check 25.07 fails on v25.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
