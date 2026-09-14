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

# END-OF-RAID AUDIT OF 2026-09-14, finding 1: HAZARD PAY WAS PAID ON GEAR HE BROUGHT UP.
# The bonus was the whole backpack value times the Terms rate, and the backpack includes
# what the lift carried up from the stash, which goes straight back to the stash. Pack a
# valuable item, sign all five Terms, extract, and the run paid 140 percent of his own
# item in credits, every raid. The haul contract (v12.65) and XP (v12.69) already subtract
# what came up; hazard pay now does too.
SubRx @'
    var bonus=Math.round(haul*tPay);
'@ @'
    // v13.53, end-of-raid audit: only what the run brought home earns hazard pay. The
    // lift's own cargo goes straight back to the stash, as v12.65 and v12.69 already count.
    var bonus=Math.round(Math.max(0,haul-(G.carriedIn||0))*tPay);
'@
SubRx @'
var VER='13.52';
'@ @'
var VER='13.53';
'@

$pat = "(?m)^  now:'v13\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.53: HAZARD PAY IS PAID ONLY ON WHAT THE RUN BROUGHT HOME. End-of-raid audit of 2026-09-14, finding 1: the bonus was the whole backpack value times the Terms rate, and the backpack includes what the lift carried up from the stash, which goes straight back to the stash, so packing a valuable item and signing Terms paid up to 140 percent of his own item every raid. The haul contract (v12.65) and XP (v12.69) already subtract what came up; hazard pay now does too. Check 13.53 extracts with the same item carried up and then found, with the Terms rate stubbed: carried up pays no hazard bonus, found still pays it; it fails on v13.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
