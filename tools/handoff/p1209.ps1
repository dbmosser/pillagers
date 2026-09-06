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

# FIRST TEN MINUTES AUDIT, 2026-09-06: with the backpack open the arrow keys
# move the selection AND walk the operator, because raidKey sets keys[code]
# true for every key before the bag branch and the movement reads the arrows
# unconditionally. The comment above the bag branch promises the opposite.
# Browsing the bag walked you off the spot you stopped on.
SubRx @'
  if(G&&!G.over&&G.bagOpen&&G.bag.length&&bagStacks().length){
    // GRID NAVIGATION, v2.87: the selection is a STACK index now, and the four
'@ @'
  // v12.09: AND THEY DO NOT WALK. keys[code] was set true at the top of this
  // function for every key, so an arrow both moved the selection and moved the
  // operator; browsing the bag walked you off the spot you stopped on. Cleared
  // here for the arrows while the bag is open; WASD still walks, as promised.
  if(G&&!G.over&&G.bagOpen&&G.bag.length&&bagStacks().length&&code.indexOf('Arrow')===0) keys[code]=false;
  if(G&&!G.over&&G.bagOpen&&G.bag.length&&bagStacks().length){
    // GRID NAVIGATION, v2.87: the selection is a STACK index now, and the four
'@

SubRx @'
  if((code==='Tab'||code==='KeyI')&&G&&!G.over&&!repeat){ G.bagOpen=!G.bagOpen; G.bagSel=0; }
'@ @'
  if((code==='Tab'||code==='KeyI')&&G&&!G.over&&!repeat){
    G.bagOpen=!G.bagOpen; G.bagSel=0;
    // v12.09: an arrow still held when the bag opens stops walking too.
    if(G.bagOpen){ keys['ArrowUp']=false; keys['ArrowDown']=false; keys['ArrowLeft']=false; keys['ArrowRight']=false; }
  }
'@

# STAMPS.
SubRx @'
var VER='12.08';
'@ @'
var VER='12.09';
'@
SubRx @'
var WHATSNEW_VER='12.08';
'@ @'
var WHATSNEW_VER='12.09';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE ARROW KEYS BROWSE THE OPEN BACKPACK WITHOUT WALKING YOU; WASD still walks.',
'@
$cnt=([regex]::Matches($s,"now:'v12\.08:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.08 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.08:[^']*'",{ param($m) "now:'v12.09: from the 2026-09-06 first-ten-minutes audit, the arrow keys moved the backpack selection and walked the operator at the same time, against the comment that promised otherwise. The arrows are cleared from the movement state while the backpack is open. Check 12.09 opens the backpack, presses an arrow through raidKey and one real player update, and requires the selection moved and the operator still; fails on v12.08.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
