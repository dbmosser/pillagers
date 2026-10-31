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

# THE FRAME LOOP MAKES LESS GARBAGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var gaps=w.map(function(f){ return f[1]; }).sort(function(a,b){ return a-b; });
  var works=w.map(function(f){ return f[2]; }).sort(function(a,b){ return a-b; });

'@ @'
  // v36.87 (cw-framegarbage): the 2 s window was copied out twice a frame (map) and sorted twice with a comparator, five new arrays a frame at 120 Hz. It now fills two reused number buffers and sorts them natively; same numbers, no garbage.
  var gaps=drsSortCol(w,1,0);
  var works=drsSortCol(w,2,1);

'@

SubRx @'
function gfxqVignette(){
  if(!(GFXQ.detail>0)) return false;
  var vg=ctx.createRadialGradient(W/2,H/2,H*.42,W/2,H/2,H*.85);
  vg.addColorStop(0,'rgba(0,0,0,0)'); vg.addColorStop(1,'rgba(0,0,0,'+(0.45*GFXQ.detail).toFixed(3)+')');
  ctx.fillStyle=vg; ctx.fillRect(0,0,W,H); return true;
}

'@ @'
// v36.87 (cw-framegarbage): the 2 s frame window sorted without garbage. drsTick used to map and sort it twice a frame with a comparator.
var DRSBUF=[new Float64Array(512),new Float64Array(512)];
function drsSortCol(w,c,b){
  var n=w.length, a=DRSBUF[b], i;
  if(a.length<n) a=DRSBUF[b]=new Float64Array(n*2);
  for(i=0;i<n;i++) a[i]=w[i][c];
  return a.subarray(0,n).sort();
}
// v36.87 (cw-framegarbage): the edge darkening gradient is built once per canvas size and strength, not every frame (a gradient and two colour stops a frame, on both windows).
var VIGC={ctx:null,w:0,h:0,d:-1,g:null};
function gfxqVignette(){
  if(!(GFXQ.detail>0)) return false;
  var vg=VIGC.g;
  if(!vg||VIGC.ctx!==ctx||VIGC.w!==W||VIGC.h!==H||VIGC.d!==GFXQ.detail){
    vg=ctx.createRadialGradient(W/2,H/2,H*.42,W/2,H/2,H*.85);
    vg.addColorStop(0,'rgba(0,0,0,0)'); vg.addColorStop(1,'rgba(0,0,0,'+(0.45*GFXQ.detail).toFixed(3)+')');
    VIGC.g=vg; VIGC.ctx=ctx; VIGC.w=W; VIGC.h=H; VIGC.d=GFXQ.detail;
  }
  ctx.fillStyle=vg; ctx.fillRect(0,0,W,H); return true;
}

'@

SubRx @'
var VER='36.88';
'@ @'
var VER='36.89';
'@

$pat = "(?m)^  now:'v36\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.89: Same picture and same auto resolution decisions, less memory churn every frame. Check 36.89 fails on v36.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
