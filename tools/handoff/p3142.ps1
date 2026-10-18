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

# the gun keys are named 1-8, 0 everywhere (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<div><kbd>1-9</kbd> bind to key</div>
'@ @'
<div><kbd>1-8, 0</kbd> bind to key</div>
'@

SubRx @'
  var d=ev.key.charCodeAt(0)-49;                 // '1' -> 0
  if(ev.key.length!==1||d<0||d>8) return;
'@ @'
  var d=(ev.key==='0')?8:ev.key.charCodeAt(0)-49;                 // v31.xx (cw-gunkeys19): '1' -> 0 up to '8' -> 7, and '0' is the ninth gun key (the rocket launcher, cw-gunkeys0); '9' does nothing
  if(ev.key.length!==1||d<0||d>8||ev.key==='9') return;
'@

SubRx @'
HOVER AN ITEM + PRESS 1-9'
'@ @'
HOVER AN ITEM + PRESS 1-8 OR 0'
'@

SubRx @'
hubToast('GUNS GO ON KEYS 1 TO '+GUNKEYS); return; }
'@ @'
hubToast(beltClassWord('gun')); return; }
'@

SubRx @'
say('GUNS GO ON KEYS 1 TO '+GUNKEYS,'info',null);
'@ @'
say(beltClassWord('gun'),'info',null);
'@

SubRx @'
return cls==='gun'?('GUNS GO ON KEYS 1 TO '+GUNKEYS):'ITEMS GO ON THE WHEEL';
'@ @'
return cls==='gun'?'GUNS GO ON KEYS 1 TO 8 AND 0':'ITEMS GO ON THE WHEEL';   // v31.xx (cw-gunkeys19): the gun keys are 1 to 8 and 0 (key 9 does nothing); the other two refusals say this word too
'@

SubRx @'
['GEAR',[['1-9','a gun for each kind, set in the stash']
'@ @'
['GEAR',[['1-8, 0','a gun for each kind, set in the stash']
'@

SubRx @'
  ['1-9','guns'],['B / I','backpack']
'@ @'
  ['1-8, 0','guns'],['B / I','backpack']
'@

SubRx @'
k('1-9')+' guns &nbsp; '
'@ @'
k('1-8, 0')+' guns &nbsp; '
'@

SubRx @'
['SWITCH GUN','1-9',padB(pbn(4))
'@ @'
['SWITCH GUN','1-8, 0',padB(pbn(4))
'@

SubRx @'
var VER='31.41';
'@ @'
var VER='31.42';
'@

$pat = "(?m)^  now:'v31\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.42: Every list names the gun keys 1-8, 0, a gun on the wrong key is told guns go on keys 1 to 8 and 0, and in the stash key 0 binds the gun under the cursor to the rocket launcher key while key 9 does nothing. Check 31.42 fails on v31.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
