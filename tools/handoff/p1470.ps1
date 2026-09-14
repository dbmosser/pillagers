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
    if(c&&c.kind===k&&cosOwned(c)) P[COSKEY[k]]=c.id;
'@ @'
    // v14.70, wardrobe audit finding 4: A SAVED LOOK IS WORN WHOLE. A kind missing from the look (every look saved before v10.54
    // has no outfit) or locked since it was saved was skipped, so the piece already worn stayed, and the result was part saved
    // look and part what he had on, at worst a suit over all of it. A missing or locked kind goes to its default, which is what
    // an old look had in that slot.
    if(c&&c.kind===k&&cosOwned(c)) P[COSKEY[k]]=c.id;
    else P[COSKEY[k]]=COSDEF[k];
'@
SubRx @'
var VER='14.69';
'@ @'
var VER='14.70';
'@

$pat = "(?m)^  now:'v14\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.70: A SAVED LOOK IS WORN WHOLE. A kind missing from a saved look, or locked since it was saved, kept the piece already worn, so an old look worn over a suit stayed hidden under the suit. A missing or locked kind now goes to its default. Check 14.70 wears a look saved with no outfit over a suit; it fails on v14.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
