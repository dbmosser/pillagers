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

# PUNCHY GUNS: SNAP CLOSE, THUMP FAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function blip(type,d,pan){
'@ @'
// v23.77, HIS ORDER 2026-10-12 (his #45, punchy arcade sound like CoD and Fortnite): PUNCHY GUNS. A gun sounded the same at 50
// and at 800, only quieter, and the same in a shed as in the open street. Now the distance shapes the shot: close (under 250) a
// bright 4 kHz snap rides on top of the crack, the thing that makes a gun in your hands feel like it kicks; far off (over 650) the
// crack is dulled to 800 Hz and pulled down, and a low thump carries instead, the way a distant shot really arrives. And the place
// it is fired in answers: inside a building two quick slaps off the walls, in the open a short low roll, in the woods a soft
// wash, in a vault a ring, over water a hiss. HIS NOTE of v10.58 still holds: a tail is a tenth of the crack or less and short,
// never the long wash he could hear "wayy later". Your own shots are tailed at half. Every layer is a fixed count of nodes and no
// buffer is over 6000 samples (the v10.56 and v10.58 rules), and nothing here draws from a seeded stream.
function gunLayers(d,space){
  var L={click:0,crackK:1,farLp:0,thump:0,tailKind:'roll',tailG:0};
  L.tailKind=space==='inside'?'slap':(space==='woods'?'soft':(space==='vault'?'ring':(space==='water'?'hiss':'roll')));
  if(!(d>0)) d=0;
  if(d<250){ L.click=0.25+0.55*(1-d/250); L.tailG=0.5; }
  else if(d>650){ L.crackK=0.6; L.farLp=800; L.thump=0.55; L.tailG=1; }
  else L.tailG=0.75;
  return L;
}
function sndSpaceN(){
  try{
    if(typeof SND_CTX!=='undefined'&&SND_CTX&&isFinite(SND_CTX.x)&&isFinite(SND_CTX.y)) return spaceAt(SND_CTX.x,SND_CTX.y).n;
    if(G&&G.player) return spaceAt(G.player.x,G.player.y).n;
  }catch(e){}
  return 'open';
}
function gunTail(a,OUT,kind,k,t){
  var i, n, b, c, s, f, g, s2, g2, o, og;
  if(!(k>0)) return;
  if(kind==='slap'){
    n=900; b=a.createBuffer(1,n,a.sampleRate); c=b.getChannelData(0);
    for(i=0;i<n;i++) c[i]=(Math.random()*2-1)*Math.pow(1-i/n,3);
    f=a.createBiquadFilter(); f.type='bandpass'; f.frequency.value=1700; f.Q.value=0.9; f.connect(OUT);
    s=a.createBufferSource(); s.buffer=b; g=a.createGain(); g.gain.value=0.22*k; s.connect(g); g.connect(f); s.start(t+0.045);
    s2=a.createBufferSource(); s2.buffer=b; g2=a.createGain(); g2.gain.value=0.11*k; s2.connect(g2); g2.connect(f); s2.start(t+0.09);
    return;
  }
  if(kind==='ring'){
    o=a.createOscillator(); og=a.createGain(); o.type='triangle';
    o.frequency.setValueAtTime(610,t+0.02); o.frequency.exponentialRampToValueAtTime(560,t+0.45);
    og.gain.setValueAtTime(0.0001,t); og.gain.setValueAtTime(0.06*k,t+0.02); og.gain.exponentialRampToValueAtTime(0.0005,t+0.45);
    o.connect(og); og.connect(OUT); o.start(t+0.02); o.stop(t+0.47);
    return;
  }
  // roll (the open), soft (the woods), hiss (water): one stretched noise each
  var TP=kind==='soft'?{n:2400,ft:'lowpass',fq:900,rate:0.5,g:0.05}:(kind==='hiss'?{n:3600,ft:'highpass',fq:2500,rate:0.6,g:0.05}:{n:4800,ft:'lowpass',fq:420,rate:0.2,g:0.08});
  b=a.createBuffer(1,TP.n,a.sampleRate); c=b.getChannelData(0);
  for(i=0;i<TP.n;i++) c[i]=(Math.random()*2-1)*Math.pow(1-i/TP.n,1.5);
  s=a.createBufferSource(); s.buffer=b; if(s.playbackRate) s.playbackRate.value=TP.rate;
  f=a.createBiquadFilter(); f.type=TP.ft; f.frequency.value=TP.fq;
  g=a.createGain(); g.gain.value=TP.g*k;
  s.connect(f); f.connect(g); g.connect(OUT); s.start(t+0.03);
}
function blip(type,d,pan){
'@

SubRx @'
    var V=FV[arguments[3]]||FV.rifle;
'@ @'
    var V=FV[arguments[3]]||FV.rifle;
    var GL=gunLayers(d,sndSpaceN());   // v23.77 (his #45): near, mid or far, and the place it is fired in
'@

SubRx @'
    f.frequency.value=(V.lp||(650+1900*vol))*J;
'@ @'
    f.frequency.value=(GL.farLp?Math.min(GL.farLp,V.lp||GL.farLp):(V.lp||(650+1900*vol)))*J;
'@

SubRx @'
    var g=a.createGain(); g.gain.value=V.g*vol*J2;
'@ @'
    var g=a.createGain(); g.gain.value=V.g*vol*J2*GL.crackK;
'@

SubRx @'
    s.connect(fh); fh.connect(f); f.connect(g); g.connect(OUT); s.start(t);
'@ @'
    s.connect(fh); fh.connect(f); f.connect(g); g.connect(OUT); s.start(t);
    if(GL.click>0){
      // v23.77 (his #45): the snap of a gun close by, a bright 4 kHz click on top of the crack
      var kb=a.createBuffer(1,160,a.sampleRate),kc=kb.getChannelData(0);
      for(var ki=0;ki<160;ki++) kc[ki]=(Math.random()*2-1)*Math.pow(1-ki/160,4);
      var ks=a.createBufferSource(); ks.buffer=kb;
      var kf=a.createBiquadFilter(); kf.type='highpass'; kf.frequency.value=4000*J;
      var kg=a.createGain(); kg.gain.value=V.g*vol*GL.click*0.9;
      ks.connect(kf); kf.connect(kg); kg.connect(OUT); ks.start(t);
    }
    if(GL.thump>0){
      // v23.77 (his #45): far off, the low thump that carries when the crack does not
      var fo=a.createOscillator(),fog=a.createGain();
      fo.type='sine'; fo.frequency.setValueAtTime(72*J,t); fo.frequency.exponentialRampToValueAtTime(38*J,t+0.18);
      fog.gain.setValueAtTime(V.g*vol*GL.thump,t); fog.gain.exponentialRampToValueAtTime(0.0005,t+0.22);
      fo.connect(fog); fog.connect(OUT); fo.start(t); fo.stop(t+0.24);
    }
    gunTail(a,OUT,GL.tailKind,V.g*vol*GL.tailG,t);   // v23.77 (his #45): the place answers
'@

SubRx @'
var VER='23.76';
'@ @'
var VER='23.77';
'@

$pat = "(?m)^  now:'v23\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.77: Guns snap close up and thump far off, and the room or the street answers each shot. Check 23.77 fails on v23.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
