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

# A HIRE ON AN ORDER MOVES ONCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    else if(e.state==='investigate'){
'@ @'
    else if(e.state==='investigate'&&!hireOrdered(e)){   // v21.52, from the bug hunt of 2026-10-08 (H13, second half): a hire on an order is moved by his order alone
'@

SubRx @'
function updateEnts(dt){
'@ @'
// v21.52, from the whole-game bug hunt of 2026-10-08 (H13, the second half): A HIRE ON AN ORDER MOVES ONCE A FRAME. Any loud noise, a
// Crier alarm or the siege pull put your hire into 'investigate', and the shared investigate step walked him toward the noise; then
// his FOLLOW or HOLD step walked him again in the same frame, so he moved at about twice his speed and jittered between the two. A
// hire under FOLLOW or HOLD drops the investigate state and is moved by his order alone. A hire with no order still investigates.
function hireOrdered(e){
  if(!e||!e.merc||e.downed||e.kind!=='raider') return false;
  if(G.mercOrder!=='follow'&&!(G.mercOrder==='hold'&&G.mercHold)) return false;
  e.state='loot';
  return true;
}
function updateEnts(dt){
'@

SubRx @'
var VER='21.51';
'@ @'
var VER='21.52';
'@

$pat = "(?m)^  now:'v21\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.52: Your hire on FOLLOW or HOLD no longer jitters and doubles his speed when he hears a noise. Check 21.52 fails on v21.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
