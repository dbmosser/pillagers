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

# NET LIFETIME EARNINGS COUNT STALL MONEY CARRIED OUT. runEarnings read only the haul, the backpack as it stands at the end
# of the raid, and a stall sale had already taken the sold items out of it, so the money an extraction banked never reached
# the counter. The run row already carries the sale as pedSold, the same figure endRaid pays into Credits.
SubRx @'
function runEarnings(rec){ return ((rec.outcome==='extract')?(rec.haul||0):0)-(rec.carriedIn||0); }
'@ @'
// v15.84, trade audit finding: NET LIFETIME EARNINGS COUNT STALL MONEY CARRIED OUT. The Mainframe card promises everything
// extracted minus everything carried in, and the sum below read only the haul, the backpack as it stands at the end of the
// raid. A backpack sold at the Peddler stall has already left it (pedSellAll keeps only what he did not sell), and the money
// rides the raid on G.pedCarry until an extraction banks it into Credits (v7.62), so a run that sold at the stall and walked
// out counted nothing for the sale, and a run that sold the kit it carried up went down by the whole carried-in value while
// the money was banked. A purchase at the stall already lowers this figure through carriedIn (v13.91); a sale never raised
// it. The run row carries the sale as pedSold, written by pedSellAll together with pedCarry, so it counts here on extraction
// only: on death or abandonment the stall money is lost with him, as the outcome card says, and the row sums as before. A
// row from before the stall figure has no pedSold and sums as it did. No price, no dial and no seeded draw moved.
function runEarnings(rec){ return ((rec.outcome==='extract')?((rec.haul||0)+(rec.pedSold||0)):0)-(rec.carriedIn||0); }
'@
SubRx @'
var VER='15.83';
'@ @'
var VER='15.84';
'@

$pat = "(?m)^  now:'v15\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.84: NET LIFETIME EARNINGS COUNT STALL MONEY CARRIED OUT. The Mainframe card Net lifetime earnings promises everything extracted minus everything carried in, but money made by selling a backpack at the Peddler stall and carrying it out never counted, so a run that sold the kit it carried up went down by the full carried-in value while the money was banked. Stall money carried out now counts, and stall money lost to death or abandonment still does not. Check 15.84 sums run rows with stall money on them, then sells a backpack at the stall and extracts; it fails on v15.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
