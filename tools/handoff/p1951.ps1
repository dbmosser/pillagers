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

# ENTER IN THE BACKPACK LEAVES THE CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if((e.code==='Enter'||e.code==='NumpadEnter')&&!WNSEEN&&!e.repeat&&!_titleUp){
'@ @'
    // v19.51, from the review (2026-10-08): not while the floor backpack is open. The card waits behind the bag (v19.28), so ENTER there
    // (equip from the backpack) took the card away unseen for the rest of the load.
    if((e.code==='Enter'||e.code==='NumpadEnter')&&!WNSEEN&&!e.repeat&&!_titleUp&&!(typeof hubBagOpen!=='undefined'&&hubBagOpen)){
'@

SubRx @'
var VER='19.50';
'@ @'
var VER='19.51';
'@

$pat = "(?m)^  now:'v19\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.51: Pressing ENTER in the Undercroft backpack no longer throws away the what is new card. Check 19.51 fails on v19.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
