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

# ONE GUNFIRE TAIL: TAKE OUT THE DUPLICATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v28.xx (cw-guntail), HIS YES (100 picks, 69 "space-aware gunfire", ARC Raiders and Hunt): a shot now has a TAIL that says where it was fired. It is built on
// the v23.73 wall muffling, not beside it: the tail goes onto the same OUT the shot uses, so it is panned, faded with distance and muffled through a wall
// exactly like the shot. The place is the one the room reverb already knows (spaceAt, where the SHOT is, yours at your own feet). INDOORS (a building, a
// locked room, the undercroft): a short bright room tail, 0.22 s (0.34 s in a vault), a lowpass falling from 2.6 kHz to 0.9 kHz, almost on the shot
// (18 ms). OUTSIDE (the street, water): a crack and then a thump, a lowpassed rumble (520 Hz down to 140 Hz) over a short falling sine, 0.42 s long,
// coming later the farther the shot is (50 ms plus up to 300 ms) and a little quieter. IN THE WOODS: none, the leaves eat it. The tails are small
// (noise at 0.04 to 0.045 of the shot's level, a thump at 0.9 of that), with at least 90 ms between two, so a spinning LMG cannot pile them up.
// Cosmetic only: Math.random picks where in the shared noise it starts, no seeded draw, no game state, never in a sim.
var SND_TAIL_AT=-9;
function gunTailSpec(space,d){
  d=+d||0;
  if(space==='inside'||space==='vault'||space==='undercroft') return {k:'room',delay:0.018,dur:(space==='vault'?0.34:0.22),lp0:2600,lp1:900,g:0.04};
  if(space==='woods') return null;
  return {k:'thump',delay:0.05+Math.min(0.3,d/2600),dur:0.42,lp0:520,lp1:140,g:0.045*(1-0.5*Math.min(1,d/1500))};
}
function gunTailMake(a,OUT,t,vol,sp){
  var s=a.createBufferSource(), f=a.createBiquadFilter(), g=a.createGain(), at=t+sp.delay, G0=Math.max(0.0001,sp.g*vol), o, og;
  s.buffer=spkNz(a);
  f.type='lowpass'; f.Q.value=0.7; f.frequency.setValueAtTime(sp.lp0,at); f.frequency.exponentialRampToValueAtTime(sp.lp1,at+sp.dur);
  g.gain.setValueAtTime(0.0001,at); g.gain.exponentialRampToValueAtTime(G0,at+0.006); g.gain.exponentialRampToValueAtTime(0.0001,at+sp.dur);
  s.connect(f); f.connect(g); g.connect(OUT); s.start(at,Math.random()*2,sp.dur+0.05);
  if(sp.k==='thump'){
    o=a.createOscillator(); og=a.createGain(); o.type='sine';
    o.frequency.setValueAtTime(95,at); o.frequency.exponentialRampToValueAtTime(48,at+0.25);
    og.gain.setValueAtTime(0.0001,at); og.gain.exponentialRampToValueAtTime(G0*0.9,at+0.01); og.gain.exponentialRampToValueAtTime(0.0001,at+0.3);
    o.connect(og); og.connect(OUT); o.start(at); o.stop(at+0.32);
  }
  return true;
}
function sndGunTail(a,OUT,t,vol,d,ctx){
  var p=(ctx&&isFinite(ctx.x)&&isFinite(ctx.y))?ctx:((G&&G.player)?G.player:null), sp;
  if(!p||!G||!G.map||!(vol>=0.08)) return false;
  if(t>=SND_TAIL_AT&&t-SND_TAIL_AT<0.09) return false;
  sp=gunTailSpec(spaceAt(p.x,p.y).n,d);
  if(!sp) return false;
  SND_TAIL_AT=t;
  return gunTailMake(a,OUT,t,vol,sp);
}

'@ @'

'@

SubRx @'
  if(type==='shot'){ try{ sndGunTail(a,OUT,t,vol,d,SND_CTX); }catch(_gt){} }   // v28.xx (cw-guntail): the room or the street answers the shot

'@ @'

'@

SubRx @'
var VER='33.31';
'@ @'
var VER='33.32';
'@

$pat = "(?m)^  now:'v33\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.32: Gunfire is back to its one tail per place (v23.77). The extra tail of the last build is gone. Check 33.32 fails on v33.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
