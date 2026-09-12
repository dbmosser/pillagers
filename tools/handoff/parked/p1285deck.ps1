$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# FOUND WHILE FIXING THE CATWALK AT v12.47 and written up there rather than built,
# because narrowing the ramp test is how a deck gets sealed and that has cost
# every route onto one before.
#
# A deck's edge is four kerbs, and the kerb has to be cut where the ramp meets it
# or there is no way up. The test that finds the mouth inflates the ramp by 20 in
# ALL FOUR directions, so it also opens the kerbs it has no business touching. On
# the DOCK CATWALK the ramp arrives from the west, and the test cuts 20 units off
# the north kerb and 20 off the south kerb as well, leaving two holes at that end
# through which he walks straight off the side of a raised deck.
#
# THE RULE THAT WAS MISSING is which side the ramp is actually on. A kerb is only
# opened if the ramp lies BEYOND that kerb: a ramp to the west opens the west
# kerb and nothing else. That is a positional fact, not a guess about the ramp's
# shape, so it works for the catwalk whose ramp arrives from the side and for the
# gantry whose ramp arrives from the end, which an aspect-ratio test would have
# sealed.
#
# THE PADDING ITSELF IS NOT TOUCHED. Ramps are authored abutting a deck rather
# than overlapping it, so the 20 still has to be there or the mouth is never cut.
SubRx @'
  function rampOverlaps(ax,ay,aw,ah){
'@ @'
  // v12.85: WHICH SIDE THE RAMP IS ON. The inflate below is needed, because
  // ramps abut a deck rather than overlapping it, but applied in all four
  // directions it opened kerbs the ramp never touches: on a deck whose ramp
  // arrives from the west it cut 20 units out of the north and south kerbs as
  // well, and he walked off the side of the deck through the hole. A kerb is
  // opened only if the ramp lies BEYOND it, which is a positional fact and
  // holds for a ramp arriving at the end as well as one arriving at the side.
  function rampOnSide(R,side,PL){
    var cx=R.x+R.w/2, cy=R.y+R.h/2;
    if(side==='N') return cy< PL.y;
    if(side==='S') return cy> PL.y+PL.h;
    if(side==='W') return cx< PL.x;
    if(side==='E') return cx> PL.x+PL.w;
    return true;
  }
  function rampOverlaps(ax,ay,aw,ah,side,PL){
'@

SubRx @'
      if(ax<R.x+R.w+pad&&ax+aw>R.x-pad&&ay<R.y+R.h+pad&&ay+ah>R.y-pad) return true; }
'@ @'
      if(side&&PL&&!rampOnSide(R,side,PL)) continue;   // v12.85: not this kerb's ramp
      if(ax<R.x+R.w+pad&&ax+aw>R.x-pad&&ay<R.y+R.h+pad&&ay+ah>R.y-pad) return true; }
'@

SubRx @'
  function edgeSpan(ax,ay,aw,ah,selfIx){
    // split an edge into segments that skip any ramp mouth
    function openHere(sx2,sy2,sw2,sh2){
      return rampOverlaps(sx2,sy2,sw2,sh2)||platJunction(sx2,sy2,sw2,sh2,selfIx);
    }
'@ @'
  function edgeSpan(ax,ay,aw,ah,selfIx,side,PLself){
    // split an edge into segments that skip any ramp mouth
    function openHere(sx2,sy2,sw2,sh2){
      return rampOverlaps(sx2,sy2,sw2,sh2,side,PLself)||platJunction(sx2,sy2,sw2,sh2,selfIx);
    }
'@

SubRx @'
    edgeSpan(PL.x,PL.y,PL.w,t2,i);
    edgeSpan(PL.x,PL.y+PL.h-t2,PL.w,t2,i);
    edgeSpan(PL.x,PL.y,t2,PL.h,i);
    edgeSpan(PL.x+PL.w-t2,PL.y,t2,PL.h,i);
'@ @'
    edgeSpan(PL.x,PL.y,PL.w,t2,i,'N',PL);
    edgeSpan(PL.x,PL.y+PL.h-t2,PL.w,t2,i,'S',PL);
    edgeSpan(PL.x,PL.y,t2,PL.h,i,'W',PL);
    edgeSpan(PL.x+PL.w-t2,PL.y,t2,PL.h,i,'E',PL);
'@

# NEW IN.
SubRx @'
  'EQUIPPING A GUN TELLS YOU WHAT HAPPENED TO THE ONE IT REPLACED. That a loaner was left behind, or that a gun you own went back to the armoury rather than into your backpack, was written and then written over by the name of the gun you had just chosen, in the same frame, every time.',
'@ @'
  'EQUIPPING A GUN TELLS YOU WHAT HAPPENED TO THE ONE IT REPLACED. That a loaner was left behind, or that a gun you own went back to the armoury rather than into your backpack, was written and then written over by the name of the gun you had just chosen, in the same frame, every time.',
  'A RAISED DECK HAS NO HOLE BESIDE ITS RAMP. The test that cuts the ramp mouth out of the edge was opening the two kerbs the ramp never touches as well, leaving a gap at that end you could walk off the side through.',
'@

# STAMPS.
SubRx @'
var VER='12.84';
'@ @'
var VER='12.85';
'@
SubRx @'
var WHATSNEW_VER='12.84';
'@ @'
var WHATSNEW_VER='12.85';
'@
$cnt=([regex]::Matches($s,"now:'v12\.84:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.84 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.84:[^']*'",{ param($m) "now:'v12.85: found while fixing the catwalk at v12.47 and written up there rather than built, because narrowing the ramp test is how a deck gets sealed and that has cost every route onto one before. A deck edge is four kerbs, and the kerb has to be cut where the ramp meets it or there is no way up; the test that finds the mouth inflates the ramp by 20 in ALL FOUR directions, so it also opens the kerbs the ramp has no business touching. On the DOCK CATWALK the ramp arrives from the west and the test cut 20 units off the north kerb and 20 off the south kerb as well, leaving two holes at that end through which he walks straight off the side of a raised deck. The rule that was missing is which side the ramp is actually on: a kerb is opened only if the ramp lies BEYOND it, so a ramp to the west opens the west kerb and nothing else. That is a positional fact rather than a guess about the ramp shape, which matters because an aspect-ratio test would have sealed the gantry whose ramp arrives at the end rather than the side. The padding itself is untouched, because ramps are authored abutting a deck rather than overlapping it and the 20 still has to be there or the mouth is never cut. Check 12.85 walks every deck on both sectors and requires the kerb to be unbroken on every side the ramp is NOT on, and still open on the side it is, so a build that sealed a deck would fail as loudly as one that left a hole; fails on v12.84.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
