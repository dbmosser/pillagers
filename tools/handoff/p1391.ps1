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

# CONTRACTS, NOTORIETY AND WAVES AUDIT OF 2026-09-14, finding 4: GOODS BOUGHT FROM THE STALL COUNTED AS
# LOOT THE RUN EARNED. v10.27 stamps what the lift carried in (G.carriedIn, and at v13.55 which items,
# G.carriedKit), and every "what the run earned" measure subtracts it: hazard pay (v13.53), the haul
# card (v12.65), the item card (v13.55), the XP haul term and the best haul. pedBuy paid with banked
# Credits and put the item in the backpack with no stamp, so a gun bought from the stall completed a
# haul card, paid hazard pay on its value, and counted toward an item card, all while he kept it.
# A purchase now goes onto the same stamp as the kit the lift carried in.
SubRx @'
  else { G.bag.push(st.k); autoBelt(st.k); }
'@ @'
  else {
    G.bag.push(st.k); autoBelt(st.k);
    // v13.91, contracts audit: bought with banked Credits, so not earned by the run. It joins what the
    // lift carried in, which hazard pay, the haul and item cards and the XP haul term all subtract.
    G.carriedIn=(G.carriedIn||0)+ival(st.k); (G.carriedKit=G.carriedKit||[]).push(st.k);
  }
'@
SubRx @'
var VER='13.90';
'@ @'
var VER='13.91';
'@

$pat = "(?m)^  now:'v13\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.91: WHAT YOU BUY AT THE STALL IS NOT LOOT YOU EARNED. Contracts, notoriety and waves audit of 2026-09-14, finding 4: every measure of what the run earned subtracts what the lift carried in (hazard pay, the haul and item cards, the XP haul term, the best haul), but pedBuy put bought goods in the backpack with no stamp, so a rifle bought with banked Credits completed a haul card and paid hazard pay while he kept it. A purchase now joins G.carriedIn and G.carriedKit. Check 13.91 buys a rifle and requires a haul card worth the rifle left incomplete, with the same rifle found in the raid completing it as the control; it fails on v13.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
