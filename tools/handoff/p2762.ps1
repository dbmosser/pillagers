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

# THE HAUL REVEAL STOPS WITH ITS CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
document.getElementById('oc_btn').onclick=function(){
'@ @'
document.getElementById('oc_btn').onclick=function(){
  HAUL_REV=null;   // v27.62 (cloud-menus-haul-reveal-stops), CLOUD HUNT 2026-10-15: a card closed mid reveal (the party lift, netCardOff) ends the reveal, so no pick sound plays in the Undercroft
'@

SubRx @'
var VER='27.61';
'@ @'
var VER='27.62';
'@

$pat = "(?m)^  now:'v27\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.62: Leaving the EXTRACTED card mid reveal no longer plays pick sounds in the Undercroft. Check 27.62 fails on v27.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
