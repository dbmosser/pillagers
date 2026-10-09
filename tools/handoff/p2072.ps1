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

# A RESTORE CODE CARRIES THE ACHIEVEMENTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function restoreMake(){
'@ @'
// v20.72, from the whole-game bug hunt of 2026-10-08 (H37): the achievements a restore code carries, by name, only the earned ones
// this build knows. The time each was earned is shown nowhere, so it stays out of the code, which keeps it short.
function achForCode(){ var o=[], i; if(typeof ACHS==='undefined'||!P||!P.ach) return o; for(i=0;i<ACHS.length;i++) if(P.ach[ACHS[i].id]) o.push(ACHS[i].id); return o; }
function restoreMake(){
'@

SubRx @'
         gh:(P.ghost&&typeof P.ghost==='object'&&P.ghost.tag)?P.ghost:null,
'@ @'
         gh:(P.ghost&&typeof P.ghost==='object'&&P.ghost.tag)?P.ghost:null,
         // v20.72 (H37): THE ACHIEVEMENTS AND THE TWO LIFETIME KILL COUNTS THEY ARE MADE OF.
         ac:achForCode(), an:{r:(P.achN&&P.achN.raider)|0,m:(P.achN&&P.achN.mach)|0},
'@

SubRx @'
  P.freeKit=0; P.kitChosen=0; P.dropKit=[]; P.wirtLotBought=null;
'@ @'
  P.freeKit=0; P.kitChosen=0; P.dropKit=[]; P.wirtLotBought=null;
  // v20.72, from the whole-game bug hunt of 2026-10-08 (H37): THE RESTORED CHARACTER'S ACHIEVEMENTS, NOT THE REPLACED ONE'S. They were
  // neither carried nor cleared, so a friend's character came up wearing LIFER and MACHINE BREAKER earned by the save it replaced,
  // and his own code on a new browser came back with none and the lifetime kill counts gone. The code's list and counts come
  // through (an older code carries none, the v15.00 rule), and the run log, left alone above, is never scanned for them again
  // (achScan), since its runs belong to the replaced character. The gamble history goes with the save it belonged to.
  var _ak={}, _ai;
  for(_ai=0;_ai<ACHS.length;_ai++) _ak[ACHS[_ai].id]=1;
  P.ach={}; P.achN={raider:Math.max(0,(o.an&&o.an.r)|0),mach:Math.max(0,(o.an&&o.an.m)|0)}; P.achScan=1; P.gambleLog=[];
  if(o.ac&&typeof o.ac.length==='number') for(_ai=0;_ai<o.ac.length&&_ai<40;_ai++) if(typeof o.ac[_ai]==='string'&&Object.prototype.hasOwnProperty.call(_ak,o.ac[_ai])) P.ach[o.ac[_ai]]=Date.now();
'@

SubRx @'
var VER='20.71';
'@ @'
var VER='20.72';
'@

$pat = "(?m)^  now:'v20\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.72: A restore code now brings your achievements with you, and never keeps those of the save it replaces. Check 20.72 fails on v20.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
