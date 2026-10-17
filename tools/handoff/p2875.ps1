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

# A CACHE NAME IS DRAWN OVER THE WALLS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      wc.font=FS(TYPE.head); wc.textAlign='center';
      wc.fillStyle=INK; wc.fillText(ct.tag,ct.x+1,ct.y-lift-d2-25);
      wc.fillStyle='#e6b4ff'; wc.fillText(ct.tag,ct.x,ct.y-lift-d2-26);
      wc.textAlign='left';

'@ @'
      // v28.xx (cachetag), HIS NOTE (2026-10-16, a picture of CHILL ROW CACHE cut in two by a wall): "text should be on top". The name was
      // drawn here with its box, in the depth-sorted world pass, so any wall drawn in front of the box covered it. It is queued now and drawn
      // in the world text pass (_wtA) beside the nameplates, after every wall.
      if(CACHETAGS.length<48) CACHETAGS.push({t:ct.tag,x:ct.x,y:ct.y-lift-d2-26});

'@

SubRx @'
function render2D(dt){

'@ @'
var CACHETAGS=[];   // v28.xx (cachetag): named cache labels queued by the world pass, drawn over the walls by _wtA
function render2D(dt){

'@

SubRx @'
  var _wtA=function(){

'@ @'
  var _wtA=function(){
  // v28.xx (cachetag): the named caches, over every wall (queued by the container pass above)
  var _ctq=CACHETAGS; CACHETAGS=[];
  if(_ctq.length){ wc.font=FS(TYPE.head); wc.textAlign='center';
    for(var _cq=0;_cq<_ctq.length;_cq++){ var _cg=_ctq[_cq]; wc.fillStyle=INK; wc.fillText(_cg.t,_cg.x+1,_cg.y+1); wc.fillStyle='#e6b4ff'; wc.fillText(_cg.t,_cg.x,_cg.y); }
    wc.textAlign='left'; }

'@

SubRx @'
var VER='28.74';
'@ @'
var VER='28.75';
'@

$pat = "(?m)^  now:'v28\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.75: A named cache shows its name over the walls instead of behind them. Check 28.75 fails on v28.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
