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

# TRAUMA SHAKE MOVES THE WORLD ONLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var sk=G.shake>0?G.shake*.7:0;
  var ox=Math.round(camX+(sk?fxn(-sk,sk):0)),oy=Math.round(camY+(sk?fxn(-sk,sk):0));
  VX=ox; VY=oy;
  try{ gfxCam(dt); }catch(_gcm){}   // v23.xx (gfx2): camera hook
'@ @'
  // v23.xx (gfx38), HIS ORDER 2026-10-12 (the graphics program, item 5): TRAUMA SHAKE, WORLD ONLY. The shake was a fresh random
  // jump of up to 0.7 x G.shake world units every drawn frame, applied to the camera itself, so it buzzed rather than shook and it
  // moved everything that reads the camera: the HUD prompts and markers placed with w2s jittered with the world. Now VX/VY are the
  // steady rounded camera (w2s, the HUD and aim never shake) and gfxCam turns each rise of G.shake into trauma that decays, read as a
  // smooth wave in whole screen pixels; ox/oy carry it for every world layer, so the ground, the light and the fog stay aligned.
  VX=Math.round(camX); VY=Math.round(camY);
  try{ gfxCam(dt); }catch(_gcm){}   // v23.xx (gfx2): camera hook; (gfx38) it sets the trauma shake GFX.sx/GFX.sy in screen pixels
  var ox=VX+(+GFX.sx||0)/Z, oy=VY+(+GFX.sy||0)/Z;
'@

SubRx @'
  if(G.anchX===undefined){ G.anchX=p.x; G.anchY=p.y; G.leanSX=leanSX; G.leanSY=leanSY; }
'@ @'
  if(G.anchX===undefined){ G.anchX=p.x; G.anchY=p.y; G.leanSX=leanSX; G.leanSY=leanSY; GFX.tr=0; GFX.shL=+G.shake||0; }   // v23.xx (gfx38): a snapped camera (raid start, respawn, redrop) starts with no trauma
'@

SubRx @'
function gfxCam(dt){ if(!gfxHook('cam')) return false; GFX.emit.length=0; return true; }   // F1: trauma shake
'@ @'
// v23.xx (gfx38): THE TRAUMA SHAKE. Each rise of G.shake (the sim keeps writing it exactly as before) adds rise/14 trauma, capped at
// 1, and trauma drains at 1.4 a second of drawn time. The offset is 18 screen pixels (grown with the screen, hudRes) x trauma squared
// x EFFECT INTENSITY (CFG.fxInt: FULL 1, HALF 0.5, OFF 0), along a smooth wave of three sines per axis at fixed phases, so a rifle
// shot barely moves the picture, a frag shakes it and a Warden shell rocks it, and no frame jumps more than about a third of the
// amplitude from the last. Nothing here draws from any stream (no rnd, no fxr) and nothing feeds the sim. A new raid starts at 0.
function gfxTrauma(dt){
  var g=(typeof G!=='undefined')?G:null, d=Math.max(0,Math.min(0.1,+dt||0)), s, k, hr, A, t;
  GFX.sx=0; GFX.sy=0; GFX.shA=0;
  if(!g||g.sim) return 0;
  if(GFX.shG!==g){ GFX.shG=g; GFX.tr=0; GFX.shL=+g.shake||0; GFX.shT=0; }
  s=+g.shake||0;
  if(s>(+GFX.shL||0)+0.01) GFX.tr=Math.min(1,(+GFX.tr||0)+(s-(+GFX.shL||0))/14);
  GFX.shL=s;
  GFX.tr=Math.max(0,(+GFX.tr||0)-d*1.4);
  GFX.shT=(+GFX.shT||0)+d;
  k=(CFG.fxInt===undefined)?1:Math.max(0,Math.min(1,+CFG.fxInt||0));
  hr=(typeof hudRes==='function')?Math.max(1,+hudRes()||1):1;
  A=18*hr*GFX.tr*GFX.tr*k;
  if(!(A>0.05)) return 0;
  t=GFX.shT;
  GFX.sx=Math.round(A*(Math.sin(t*15)+0.5*Math.sin(t*23+1.7)+0.25*Math.sin(t*35+4.1))/1.75);
  GFX.sy=Math.round(A*(Math.sin(t*16+2.3)+0.5*Math.sin(t*24+0.6)+0.25*Math.sin(t*33+5.2))/1.75);
  GFX.shA=A;
  return A;
}
function gfxCam(dt){ try{ gfxTrauma(dt); }catch(_gt){ GFX.sx=0; GFX.sy=0; } if(!gfxHook('cam')) return false; GFX.emit.length=0; return true; }   // F1: trauma shake (gfx38)
'@

SubRx @'
var VER='23.96';
'@ @'
var VER='23.97';
'@

$pat = "(?m)^  now:'v23\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.97: Screen shake is now a smooth rock of the world that fades, the HUD stays steady, and EFFECT INTENSITY scales it. Check 23.97 fails on v23.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
