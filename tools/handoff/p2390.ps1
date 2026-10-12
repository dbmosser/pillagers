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

# FOOTSTEPS: WET, GRIT, TILE, GRATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function blip(type,d,pan){
'@ @'
// v23.90, HIS ORDER 2026-10-12 (his #45, improve all sound as much as possible): FOOTSTEPS ON WHAT IS UNDER THEM. Five surfaces
// gave every street, yard and puddle the same gravel and every floor the same boards. surfFine names the ground more finely for
// the ear only: stone is wet in the rain, gritty in a landmark yard and plain concrete elsewhere; wood is tile in a locked room
// and boards elsewhere; metal is a grate. It rides a SIXTH argument, so surfAt, the five surface step and the noise your feet make
// in the world (the ping radius the Listener hears) are exactly as before; only the extra layer on top is new, with three small
// pitch variants rolled from Math.random so no two steps match. Enemy steps carry it too. Nothing here draws a seeded number.
function surfFine(x,y,base){
  var m, i, R, wr=0;
  if(base==='metal') return 'grate';
  if(base==='leaf'||base==='water') return base;
  if(!G||!G.map) return base==='wood'?'boards':'concrete';
  m=G.map;
  if(base==='wood'){
    for(i=0;i<(m.locked||[]).length;i++){ R=m.locked[i]; if(x>R.x&&x<R.x+R.w&&y>R.y&&y<R.y+R.h) return 'tile'; }
    return 'boards';
  }
  try{ wr=(typeof wx==='function'&&wx())?(wx().rain||0):0; }catch(e){ wr=0; }
  if(wr>0.3) return 'wet';
  for(i=0;i<(m.landmarks||[]).length;i++){ R=m.landmarks[i]; if(x>R.x&&x<R.x+R.w&&y>R.y&&y<R.y+R.h) return 'grit'; }
  return 'concrete';
}
function footFine(a,OUT,fine,vol,stG,t){
  var V=[0.92,1,1.09][Math.floor(Math.random()*3)], n, b, c, i, s, f, g, o, og;
  var FP={wet:{n:1300,pw:1.3,ft:'bandpass',fq:1900,q:0.9,g:0.04,at:0.05},
          grit:{n:700,pw:1.2,ft:'highpass',fq:4600,q:0.7,g:0.022,at:0.06},
          concrete:{n:380,pw:2.6,ft:'bandpass',fq:1500,q:1.4,g:0.02,at:0.045},
          tile:{n:220,pw:3.2,ft:'bandpass',fq:2600,q:5,g:0.03,at:0.045},
          boards:{n:600,pw:2.2,ft:'lowpass',fq:420,q:3,g:0.03,at:0.05},
          grate:{n:300,pw:2.4,ft:'bandpass',fq:3400,q:7,g:0.025,at:0.05},
          leaf:{n:900,pw:1.1,ft:'highpass',fq:3200,q:0.6,g:0.015,at:0.12},
          water:{n:900,pw:1.6,ft:'bandpass',fq:1200,q:1.2,g:0.02,at:0.14}}[fine];
  if(!FP) return false;
  n=FP.n; b=a.createBuffer(1,n,a.sampleRate); c=b.getChannelData(0);
  for(i=0;i<n;i++) c[i]=(Math.random()*2-1)*Math.pow(1-i/n,FP.pw);
  s=a.createBufferSource(); s.buffer=b;
  f=a.createBiquadFilter(); f.type=FP.ft; f.frequency.value=FP.fq*V; f.Q.value=FP.q;
  g=a.createGain(); g.gain.value=FP.g*vol*stG;
  s.connect(f); f.connect(g); g.connect(OUT); s.start(t+FP.at);
  if(fine==='grate'){
    // the grate rattles once under the weight
    o=a.createOscillator(); og=a.createGain(); o.type='square';
    o.frequency.setValueAtTime(95*V,t+0.06); o.frequency.exponentialRampToValueAtTime(80*V,t+0.1);
    og.gain.setValueAtTime(0.012*vol*stG,t+0.06); og.gain.exponentialRampToValueAtTime(0.0005,t+0.11);
    o.connect(og); og.connect(OUT); o.start(t+0.06); o.stop(t+0.12);
  }
  return true;
}
function blip(type,d,pan){
'@

SubRx @'
      dro.connect(drg); drg.connect(OUT); dro.start(t+.22); dro.stop(t+.34);
    }
'@ @'
      dro.connect(drg); drg.connect(OUT); dro.start(t+.22); dro.stop(t+.34);
    }
    if(arguments[5]) footFine(a,OUT,arguments[5],vol,stG,t);   // v23.90 (his #45): the finer ground under the foot
'@

SubRx @'
  (crouch?blip:blipMine)('foot',crouch?540:(G.sprinting?0:180),PSIDE?0.16:-0.16,surf,crouch?'crouch':(G.sprinting?'sprint':'walk'));
'@ @'
  (crouch?blip:blipMine)('foot',crouch?540:(G.sprinting?0:180),PSIDE?0.16:-0.16,surf,crouch?'crouch':(G.sprinting?'sprint':'walk'),surfFine(p.x,p.y,surf));   // v23.90 (his #45): the finer ground rides a sixth argument
'@

SubRx @'
  else blip('foot',ear.d*1.35,ear.pan,bsurf,best.state==='chase'?'sprint':'walk');
'@ @'
  else blip('foot',ear.d*1.35,ear.pan,bsurf,best.state==='chase'?'sprint':'walk',surfFine(best.x,best.y,bsurf));   // v23.90 (his #45)
'@

SubRx @'
function blipMine(type,a,b,c,d){
  blip(type,a,b,c,d);
'@ @'
function blipMine(type,a,b,c,d,e){
  blip(type,a,b,c,d,e);   // v23.90 (his #45): the sixth argument, the finer ground under your feet, is passed on
'@

SubRx @'
var VER='23.89';
'@ @'
var VER='23.90';
'@

$pat = "(?m)^  now:'v23\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.90: Footsteps tell wet stone, grit, concrete, tile, boards and grates apart. Check 23.90 fails on v23.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
