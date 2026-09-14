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
  if(e.button===0&&G&&G.drag){
'@ @'
  // v14.56, backpack audit finding 1: A DRAG HELD WHEN THE RAID ENDS WRITES NOTHING. On a death endRaid empties the belt plan
  // (coming back empty) and saves, but a drag held through the end survived it, and this release on the outcome card wrote
  // the raid's whole belt back into the plan and saved again: he came home to keys bound to everything he had just lost.
  if(e.button===0&&G&&G.drag&&!G.over){
'@
SubRx @'
  G.over=how;
  // v14.03, save audit: the raid is being settled here, and G.spliced drives the settling; the saved record of
'@ @'
  G.over=how;
  G.drag=null;   // v14.56: a drag held as the raid ends ends with it
  // v14.03, save audit: the raid is being settled here, and G.spliced drives the settling; the saved record of
'@
SubRx @'
var VER='14.55';
'@ @'
var VER='14.56';
'@

$pat = "(?m)^  now:'v14\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.56: A DRAG HELD WHEN THE RAID ENDS WRITES NOTHING. A death empties the belt plan and saves, but a backpack or belt drag held through the end of the raid survived it, and letting go on the outcome card wrote the raid belt back into the plan and saved, so he came home with keys bound to what he had lost. Ending the raid now drops the drag, and a release after the end does nothing. Check 14.56 releases a belt drag in a live raid and after it ends; it fails on v14.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
