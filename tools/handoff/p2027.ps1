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

# WEAK POINTS REGISTER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function weakHit(e,bx,by){
  var L=weakOf(e); if(!L) return null;
  var best=null,bd=1e9;
  for(var i=0;i<L.length;i++){
    var W=L[i],pt=weakPos(e,W);
    var dx=bx-pt.x,dy=by-pt.y,d=Math.sqrt(dx*dx+dy*dy);
'@ @'
// v20.27, from the whole-game bug hunt of 2026-10-08 (H1): a round is tested at the first 8 unit step inside the body circle, and
// every opening sits wholly inside that circle, so a dead-centre shot on a Sentry vent paid about half the time at 60 Hz, a Warden
// seam almost never at 144 Hz, and the Overseer's openings never at all. Given the round's direction (ux,uy), the test now follows
// its path on into the body as far as the centre line and takes its nearest pass to each opening. An opening on the far side of
// the centre is still out of reach, so the vent on a machine's back still needs a flank.
function weakHit(e,bx,by,ux,uy){
  var L=weakOf(e); if(!L) return null;
  var best=null,bd=1e9, ray=(typeof ux==='number'&&typeof uy==='number'&&(ux!==0||uy!==0)), tc=0;
  if(ray){ tc=(e.x-bx)*ux+(e.y-by)*uy; if(tc<0) tc=0; }
  for(var i=0;i<L.length;i++){
    var W=L[i],pt=weakPos(e,W), qx=bx, qy=by, t;
    if(ray){ t=(pt.x-bx)*ux+(pt.y-by)*uy; if(t<0) t=0; else if(t>tc) t=tc; qx=bx+ux*t; qy=by+uy*t; }
    var dx=qx-pt.x,dy=qy-pt.y,d=Math.sqrt(dx*dx+dy*dy);
'@

SubRx @'
var WK=weakHit(en,b.x,b.y);
'@ @'
var WK=weakHit(en,b.x,b.y,ux,uy);   // v20.27 (H1): along the round's path
'@

SubRx @'
var VER='20.26';
'@ @'
var VER='20.27';
'@

$pat = "(?m)^  now:'v20\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.27: Shots on a machine vent, optic or core seam now count as weak point hits, including on THE OVERSEER. Check 20.27 fails on v20.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
