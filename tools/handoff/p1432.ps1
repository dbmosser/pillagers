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

SubRx @'
  if(WX.lightning){
    G.lightning-=dt;
'@ @'
  // v14.32, weather audit finding 2: THE FLASH RUNS OUT EVEN WHEN THE STORM DOES NOT. The countdown ran only while the
  // weather had lightning, and a storm turning into another weather hands that flag over halfway through the turn, so a bolt
  // in the last third of a second before that left G.lightning above zero for good: the flash and the lifted fog stayed on
  // for the rest of the raid. It now counts down on every drawn frame.
  if(G.lightning>0) G.lightning=Math.max(0,G.lightning-dt);
  if(WX.lightning){
'@
SubRx @'
var VER='14.31';
'@ @'
var VER='14.32';
'@

$pat = "(?m)^  now:'v14\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.32: THE LIGHTNING FLASH RUNS OUT AFTER THE STORM PASSES. The flash counted down only while the weather had lightning, and a storm turning into other weather drops that flag halfway through the turn, so a bolt just before it left the flash on and the fog lifted for the rest of the raid. The flash now counts down on every drawn frame. Check 14.32 draws frames with a flash left in a storm and in calm weather; it fails on v14.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
