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

# MENU STICK AND D-PAD REPEAT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(!md){ if(PAD.focus){ padSetFocus(null); PAD.focus=null; } return false; }
'@ @'
  if(!md){ PAD.mDdir=0; PAD.mDmd=null; PAD.mrepAt=null; if(PAD.focus){ padSetFocus(null); PAD.focus=null; } return false; } // v28.xx (cw-cx-menurepeat): a closed menu releases its repeat timers.
'@

SubRx @'
  var mv=null;
  if(tap(12)) mv=[0,-1]; else if(tap(13)) mv=[0,1];
  else if(tap(14)) mv=[-1,0]; else if(tap(15)) mv=[1,0];
  // The left stick works too, on a repeat timer so one push is one step.
  var ls=padStick(PAD.ax?PAD.ax[0]||0:0,PAD.ax?PAD.ax[1]||0:0), lx=ls.x, ly=ls.y; // v28.xx (cw-cx-stickmath): menu stepping reads the physical left stick as a pair.
  // v20.77, from the whole-game bug hunt of 2026-10-08 (H47): THE STICK REPEAT IN A MENU RUNS ON THE CLOCK. It took 1/60 off a
  // timer once per drawn frame, so it stepped every 12 frames: a fifth of a second at 60 Hz, but 83 ms at 144 Hz and 50 ms at
  // 240 Hz, where one quick flick moved the highlight two or three places, and 0.4 s with the frame cap at 30. It now waits a
  // fifth of a second of real time between steps at any frame rate, as the D-UP and bumper holds already do.
  var _mnow=netPadNow();
  if(!mv&&(Math.abs(lx)>0.6||Math.abs(ly)>0.6)&&!(PAD.mrepAt!=null&&_mnow-PAD.mrepAt<0.195)){
    mv=(Math.abs(lx)>Math.abs(ly))?[lx>0?1:-1,0]:[0,ly>0?1:-1];
    PAD.mrepAt=_mnow;
  }
'@ @'
  // v28.xx (cw-cx-menurepeat): J10, D-pad steps immediately, then after 0.4 s and every 0.1 s held.
  var mv=null, _mnow=netPadNow(), _md=0;
  for(var _mi=12;_mi<=15;_mi++){ var _mh=!!pressed(_mi); PAD.prev[_mi]=_mh; if(_mh&&!_md) _md=_mi; }
  if(_md){
    if(_md!==PAD.mDdir||md!==PAD.mDmd){
      mv=_md===12?[0,-1]:_md===13?[0,1]:_md===14?[-1,0]:[1,0];
      PAD.mDAt=_mnow+0.4;
    }else if(_mnow+1e-9>=PAD.mDAt){
      mv=_md===12?[0,-1]:_md===13?[0,1]:_md===14?[-1,0]:[1,0];
      PAD.mDAt=_mnow+0.1;
    }
  }else PAD.mDAt=null;
  PAD.mDdir=_md; PAD.mDmd=md;
  // v28.xx (cw-cx-menurepeat): J10, half physical travel at every deadzone and sensitivity; the radial deadzone still rejects drift.
  var _mx=PAD.ax?PAD.ax[0]||0:0, _my=PAD.ax?PAD.ax[1]||0:0;
  var ls=padStick(_mx,_my), lx=ls.x, ly=ls.y, _mpush=Math.hypot(_mx,_my)>Math.max(0.5,padDz());
  if(!_mpush) PAD.mrepAt=null;
  if(!_md&&_mpush&&!(PAD.mrepAt!=null&&_mnow-PAD.mrepAt<0.195)){
    mv=(Math.abs(lx)>Math.abs(ly))?[lx>0?1:-1,0]:[0,ly>0?1:-1];
    PAD.mrepAt=_mnow;
  }
'@

SubRx @'
var VER='31.99';
'@ @'
var VER='32.00';
'@

$pat = "(?m)^  now:'v31\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.00: Menus respond at half stick travel. Hold the D-pad to repeat after 0.4 seconds, then every 0.1 seconds. Check 32.00 fails on v31.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
