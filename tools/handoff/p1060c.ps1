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

# v10.60, third part. Coming down to the floor REBUILDS the people, and that
# second call passed the colliders and skipped the placement pass, so every
# visit after the first put them straight back inside the wall pictures. Found
# by the dry run: the counter holder was at 190,426 inside the south wall again
# on a fixture built with the fix in it. One shared helper now, so a third
# caller cannot get this wrong either.
SubRx @'
function hubDrawn(ws){
'@ @'
// v10.60: the only way the crowd is ever built. It places them against the
// PICTURES and then pushes anyone the room's own box put back inside one.
function hubCrowdClear(stations,dw){
  var cr=buildHubCrowd(stations,dw);
  for(var i=0;i<cr.length;i++){
    var b=cr[i];
    if(!(b.r>0)) b.r=13;
    // The room's box reaches into the south wall's picture, so the clamp goes
    // first and the push gets the last word.
    b.x=clamp(b.x,34,HUBW-34); b.y=clamp(b.y,34,HUBH-34);
    collide(b,dw);
    // A post holder walks back to where he was put, so his home moves with him.
    if(b.post){ b.px=b.x; b.py=b.y; }
  }
  return cr;
}
function hubDrawn(ws){
'@
SubRx @'
  var dw=hubDrawn(w);
  var cr=buildHubCrowd(stations,dw);
  for(var ci2=0;ci2<cr.length;ci2++){
    var bb=cr[ci2];
    if(!(bb.r>0)) bb.r=13;
    // The room's own box reaches into the south wall's picture, so the clamp
    // goes first and the push gets the last word.
    bb.x=clamp(bb.x,34,HUBW-34); bb.y=clamp(bb.y,34,HUBH-34);
    collide(bb,dw);
    // A post holder walks back to where he was put, so his home moves with him.
    if(bb.post){ bb.px=bb.x; bb.py=bb.y; }
  }
'@ @'
  var dw=hubDrawn(w);
  var cr=hubCrowdClear(stations,dw);
'@
SubRx @'
    else HB.crowd=buildHubCrowd(HB.stations,HB.walls);
'@ @'
    else HB.crowd=hubCrowdClear(HB.stations,HB.dwalls||hubDrawn(HB.walls));   // v10.60: the pictures, and placed clear of them
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
