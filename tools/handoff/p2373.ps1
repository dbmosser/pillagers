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

# SOUND THROUGH WALLS IS MUFFLED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// ---------------------------------------------------------------- the room
'@ @'
// v23.73, HIS ORDER 2026-10-12 (his #45, improve all sound as much as possible): WALLS AND DISTANCE. A shot in the next room
// sounded exactly like a shot in the open at the same range, only quieter, so the ear could not tell a fight behind a wall from
// one across the street. Every positioned sound now asks where it is: behind a wall (the same line of sight test the game uses
// for seeing, cached per spot until the next frame) it is played through a lowpass, 1500 Hz close falling to 900 Hz far, muffled
// the way a wall muffles; a sound right beside you is placed wider in the stereo field and a far one narrower, so near reads near.
// Your own sounds (your gun, your feet) are where you stand and are untouched. Cosmetic only: no random draw, no game state.
var SND_CTX=null, SND_OCC={}, SND_OCC_N=0;
function sndPlace(x,y){
  var R={x:x,y:y,occ:0,lp:0,panK:1,d:0}, p, dx, dy, d, k, o;
  if(!G||!G.player||!G.map||x===undefined||x===null||y===undefined||y===null||!isFinite(x)||!isFinite(y)) return R;
  p=G.player; dx=x-p.x; dy=y-p.y; d=Math.sqrt(dx*dx+dy*dy); R.d=d;
  if(d>24&&typeof losClear==='function'&&G.map.segs){
    k=Math.round(x/12)+','+Math.round(y/12)+','+Math.round(p.x/12)+','+Math.round(p.y/12);
    o=SND_OCC[k];
    if(o===undefined){ if(SND_OCC_N>300){ SND_OCC={}; SND_OCC_N=0; } o=SND_OCC[k]=losClear(p.x,p.y,x,y,G.map.segs)?0:1; SND_OCC_N++; }
    R.occ=o;
  }
  if(R.occ) R.lp=Math.round(clamp(1500-600*d/900,900,1500));
  R.panK=d<150?1.4:(d>700?0.7:1);
  return R;
}
// ---------------------------------------------------------------- the room
'@

SubRx @'
function sndMixTick(dt){
  if(!isFinite(dt)||dt<=0) return;
'@ @'
function sndMixTick(dt){
  if(SND_OCC_N){ SND_OCC={}; SND_OCC_N=0; }   // v23.73 (his #45): what the walls hide is asked again each frame
  if(!isFinite(dt)||dt<=0) return;
'@

SubRx @'
  var e=earsOf(wx,wy);
  blip(type,e.d,e.pan,wid);
'@ @'
  var e=earsOf(wx,wy);
  SND_CTX=sndPlace(wx,wy);   // v23.73 (his #45): behind a wall it is muffled, beside you it is wide
  try{ blip(type,e.d,e.pan,wid); }finally{ SND_CTX=null; }
'@

SubRx @'
    pn.pan.value=clamp(pan,-1,1);
    pn.connect(OUT); OUT=pn;
  }
'@ @'
    pn.pan.value=clamp(pan*(SND_CTX?SND_CTX.panK:1),-1,1);   // v23.73 (his #45): wider beside you, narrower far off
    pn.connect(OUT); OUT=pn;
  }
  if(SND_CTX&&SND_CTX.lp>0){ var olp=a.createBiquadFilter(); olp.type='lowpass'; olp.frequency.value=SND_CTX.lp; olp.Q.value=0.7; olp.connect(OUT); OUT=olp; }   // v23.73 (his #45): through the wall
'@

SubRx @'
var VER='23.72';
'@ @'
var VER='23.73';
'@

$pat = "(?m)^  now:'v23\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.73: Sounds behind a wall are muffled, and sounds beside you are placed wider left and right. Check 23.73 fails on v23.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
