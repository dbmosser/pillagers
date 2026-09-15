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
  var b=document.getElementById('gamblebtn');
  b.textContent='Gamble $'+GAMBLE_PRICE;
'@ @'
  var b=document.getElementById('gamblebtn');
  // v15.05, wirt audit finding: THE GAMBLE BUTTON READS ITS PRICE WITH A COMMA. The money line and the empty roll list above
  // it print GAMBLE_PRICE through toLocaleString, and so does the Buy button of the Limited Time Offer, but this button printed
  // the bare number, so the panel read $2,500 per roll over a button reading Gamble $2500. Display only: the price stays 2500.
  b.textContent='Gamble $'+GAMBLE_PRICE.toLocaleString();
'@
SubRx @'
var VER='15.04';
'@ @'
var VER='15.05';
'@

$pat = "(?m)^  now:'v15\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.05: THE GAMBLE BUTTON READS ITS PRICE WITH A COMMA. The Gamble button in the Wirt panel read Gamble 2500, while the money line above it, the empty roll list and the Buy button of the limited offer all print prices with a comma, as in 2,500 per roll. The button now prints its price the same way, and the price itself does not change. Check 15.05 draws the Wirt panel and reads the button against the money line; it fails on v15.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
