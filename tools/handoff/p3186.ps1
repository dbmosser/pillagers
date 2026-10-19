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

# STICKS KEEP THEIR ANGLE AND FULL DIAGONAL SPEED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function padAxis(v){
  // Radial deadzone with rescaling, so the first millimetre past the deadzone
  // is a small input and not a jump to 0.22 of full speed.
  var dz=padDz();   // v26.xx (settings10): STICK DEADZONE
  var a=Math.abs(v);
  if(a<dz) return 0;
  return Math.sign(v)*Math.min(1,((a-dz)/(1-dz))*padSens());   // v26.xx (settings10): STICK SENSITIVITY
}
'@ @'
// v28.xx (cw-cx-stickmath): J2, one radial deadzone keeps the stick angle and full diagonal travel.
function padStick(x,y){
  var m=Math.hypot(x,y), dz=padDz();
  if(m<=dz) return {x:0,y:0};
  var n=Math.min(1,((m-dz)/(1-dz-0.06))*padSens());
  return {x:(x/m)*n,y:(y/m)*n};
}
function padAxis(v){ return padStick(v,0).x; }
'@

SubRx @'
  var lx=padAxis((navigator.getGamepads&&PAD.ax)?PAD.ax[0]:0), ly=padAxis(PAD.ax?PAD.ax[1]:0);
'@ @'
  var ls=padStick(PAD.ax?PAD.ax[0]||0:0,PAD.ax?PAD.ax[1]||0:0), lx=ls.x, ly=ls.y; // v28.xx (cw-cx-stickmath): menu stepping reads the physical left stick as a pair.
'@

SubRx @'
  PAD.mx=padAxis(ax[0]||0); PAD.my=padAxis(ax[1]||0);
  var mgp=Math.sqrt(PAD.mx*PAD.mx+PAD.my*PAD.my);
  if(mgp>1){ PAD.mx/=mgp; PAD.my/=mgp; }
'@ @'
  var ls=padStick(ax[0]||0,ax[1]||0); PAD.mx=ls.x; PAD.my=ls.y; // v28.xx (cw-cx-stickmath): sensitivity scales length before the radial clamp.
'@

SubRx @'
  var rx=padAxis(ax[2]||0),ry=padAxis(ax[3]||0);
'@ @'
  var rs=padStick(ax[2]||0,ax[3]||0),rx=rs.x,ry=rs.y; // v28.xx (cw-cx-stickmath): aim and the item wheel share this vector.
'@

SubRx @'
    var _fU=G.forgeUI, _fn=Math.max(1,_fU.n|0), _fdx=0, _fq=padAxis(ax[0]||0), _fq2=(_fq<-0.5)?-1:((_fq>0.5)?1:0);
'@ @'
    var _fU=G.forgeUI, _fn=Math.max(1,_fU.n|0), _fdx=0, _fq=ls.x, _fq2=(_fq<-0.5)?-1:((_fq>0.5)?1:0); // v28.xx (cw-cx-stickmath): forge stepping uses the movement stick pair too.
'@

SubRx @'
var VER='31.85';
'@ @'
var VER='31.86';
'@

$pat = "(?m)^  now:'v31\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.86: Both sticks use a circular deadzone with full diagonal travel. Deadzone and sensitivity settings stay available. Check 31.86 fails on v31.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
