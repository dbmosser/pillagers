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

# THE PIXEL UNDERCROFT FLOOR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var g=document.createElement('canvas'); g.width=HUBW; g.height=HUBH;
'@ @'
  var _hp=pixOn(), g=document.createElement('canvas'); g.width=_hp?Math.ceil(HUBW/PIX_ENV):HUBW; g.height=_hp?Math.ceil(HUBH/PIX_ENV):HUBH;   // v28.xx (cw-cx-pixhub), his pixel pass (10-20): the Undercroft floor is baked at 2 world units a pixel, from the same code, and snapped to two ramps
'@

SubRx @'
  var c=g.getContext('2d'),i;
'@ @'
  var c=g.getContext('2d',_hp?{willReadFrequently:true}:undefined),i;
  if(_hp) c.scale(1/PIX_ENV,1/PIX_ENV);
'@

SubRx @'
  c.strokeStyle='rgba(0,0,0,.26)'; c.lineWidth=1;
'@ @'
  c.strokeStyle='rgba(0,0,0,.26)'; c.lineWidth=_hp?PIX_ENV:1;
'@

SubRx @'
  return g;
}
function hubModalOpen(){
'@ @'
  return _hp?pixHubSnap(g):g;
}
// v28.xx (cw-cx-pixhub): the Undercroft floor in the pixel look. Two ramps of 4 tones, the cool plating and the warm glow of the lift; every pixel goes to the nearest of the 8 (the family by colour, the tone by lightness), so the glow and the shadows fall in steps. The result is copied to a plain canvas for the per frame draw. No random number is drawn here.
var PIXHUB=null;
function pixHubSnap(g){
  var P=PIXHUB, c, id, p, k, v, f, r, q, e;
  if(!P){
    P={rgb:[],luma:[],refs:[],lut:new Uint16Array(32768).fill(65535)};
    [pixRamp('#141a34'),pixRamp('#3a2a18')].forEach(function(rm,fi){ for(q=0;q<4;q++){ e=pixGroundHex(rm[q]); P.rgb.push(e); P.luma.push(e[0]*0.3+e[1]*0.59+e[2]*0.11); P.refs.push([e,fi]); } });
    PIXHUB=P;
  }
  c=g.getContext('2d'); id=c.getImageData(0,0,g.width,g.height); p=id.data;
  for(k=0;k<p.length;k+=4){ v=pixGroundNear(P,p[k],p[k+1],p[k+2]); r=P.rgb[v]; p[k]=r[0]; p[k+1]=r[1]; p[k+2]=r[2]; p[k+3]=255; }
  c.putImageData(id,0,0);
  f=document.createElement('canvas'); f.width=g.width; f.height=g.height; f.getContext('2d').drawImage(g,0,0); f._pe=PIX_ENV;
  return f;
}
function hubModalOpen(){
'@

SubRx @'
    if(!hubGround) hubGround=bakeHubGround();
'@ @'
    if(!hubGround||(hubGround._pe>1)!==pixOn()) hubGround=bakeHubGround();   // v28.xx (cw-cx-pixhub): latch the ground look at hub entry
'@

SubRx @'
  wc.drawImage(hubGround,0,0);
'@ @'
  if(hubGround._pe>1){   // v28.xx (cw-cx-pixhub): 2 world units a pixel, nearest when that is a whole number of screen pixels
    var _hsm=wc.imageSmoothingEnabled; wc.imageSmoothingEnabled=Math.abs(S*DPR*hubGround._pe-Math.round(S*DPR*hubGround._pe))>0.001;
    wc.drawImage(hubGround,0,0,hubGround.width*hubGround._pe,hubGround.height*hubGround._pe);
    wc.imageSmoothingEnabled=_hsm;
  } else wc.drawImage(hubGround,0,0);
'@

SubRx @'
var VER='34.46';
'@ @'
var VER='34.47';
'@

$pat = "(?m)^  now:'v34\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.47: With the pixel look on (the default), the Undercroft floor is chunky pixel art in 8 stepped tones. With the look off, nothing changes. Check 34.47 fails on v34.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
