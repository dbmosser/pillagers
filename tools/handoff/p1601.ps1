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

# THE STORM SAYS WHAT THE LIGHTNING DOES. Weather audit finding 9 (audit-wwhovd0n0.json), its correctedFix: fix the words, not the machines.

SubRx @'
   line:'Storm. The lightning will show you to everything out there.'}
'@ @'
   line:'Storm. Lightning strikes, and every flash shows you the whole map for a moment.'}   // v16.01, weather audit finding: the old line promised the flash shows you to everything out there, and nothing on the map reads it
'@

SubRx @'
    if(MW.lightning) wv.push('lightning shows you');
'@ @'
    if(MW.lightning) wv.push('lightning strikes, and a flash shows you the map');   // v16.01: the flash lifts the fog for you; nothing on the map reads it
'@

SubRx @'
      // a hard flash that shows the whole street for a moment, which cuts both
      // ways: it reveals the map to you and you to anything looking
'@ @'
      // a hard flash that shows the whole street for a moment: it lifts the fog sheet
      // for you (above). Nothing on the map reads it; whether it should is his call (v16.01)
'@

SubRx @'
var VER='16.00';
'@ @'
var VER='16.01';
'@

$pat = "(?m)^  now:'v16\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.01: THE STORM SAYS WHAT THE LIGHTNING DOES. Weather audit finding 9. The storm line said the lightning will show you to everything out there and the CONDITIONS row said lightning shows you, and no sight rule reads the flash: it lifts the fog for you and nothing more. The two lines now say what it does (every flash shows you the whole map for a moment). Neither is a TXSHIP key. Whether a flash should show you to the machines is parked as a question for him. No number moved. Check 16.01 fails on v16.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
