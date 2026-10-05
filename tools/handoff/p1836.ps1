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

# GROUND SHADOWS ARE STAMPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function shadowE(x,y,rx,ry,a){
  wc.fillStyle='rgba(0,0,0,'+a+')';
  wc.beginPath(); wc.ellipse(x,y,rx,ry,0,0,6.2832); wc.fill();
}
'@ @'
// v18.36, THE FRAME COST (2026-10-04): A GROUND SHADOW IS A STAMP. Every body, tree, box and wreck laid a soft ellipse every frame,
// about 160 path fills a frame. The ellipse depends only on its size and darkness, so each one is painted once into a small
// sprite at the screen scale and stamped after that. Sizes round to whole units, darkness to hundredths; the store empties when
// it passes 300. CFG.wallBake 0 paints them live, as the walls do.
var SHADSPR={m:{},n:0,ss:0};
function shadowE(x,y,rx,ry,a){
  var ss, k, e, R, cv2, c2;
  if(CFG.wallBake!==0&&rx>0&&ry>0&&rx<400&&ry<400&&typeof wallSpriteScale==='function'){
    ss=wallSpriteScale();
    if(SHADSPR.ss!==ss){ SHADSPR.m={}; SHADSPR.n=0; SHADSPR.ss=ss; }
    R=[Math.round(rx),Math.round(ry),Math.round(a*100)]; k=R.join(',');
    e=SHADSPR.m[k];
    if(!e&&R[0]>0&&R[1]>0){
      if(SHADSPR.n>300){ SHADSPR.m={}; SHADSPR.n=0; }
      cv2=document.createElement('canvas'); cv2.width=Math.ceil(R[0]*2*ss)+2; cv2.height=Math.ceil(R[1]*2*ss)+2; c2=cv2.getContext('2d');
      if(c2){ c2.fillStyle='rgba(0,0,0,'+(R[2]/100)+')'; c2.beginPath(); c2.ellipse(cv2.width/2,cv2.height/2,R[0]*ss,R[1]*ss,0,0,6.2832); c2.fill(); e={c:cv2,ss:ss}; SHADSPR.m[k]=e; SHADSPR.n++; }
    }
    if(e){ wc.drawImage(e.c,x-e.c.width/(2*e.ss),y-e.c.height/(2*e.ss),e.c.width/e.ss,e.c.height/e.ss); return; }
  }
  wc.fillStyle='rgba(0,0,0,'+a+')';
  wc.beginPath(); wc.ellipse(x,y,rx,ry,0,0,6.2832); wc.fill();
}
'@

SubRx @'
var VER='18.35';
'@ @'
var VER='18.36';
'@

$pat = "(?m)^  now:'v18\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.36: Ground shadows are painted once and stamped, a little more frame rate in busy places. Check 18.36 fails on v18.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
