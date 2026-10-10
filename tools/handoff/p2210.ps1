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

# USED KIT NO LONGER CUTS HAZARD PAY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // A raid with no time on the clock, no distance walked, nothing searched and
'@ @'
  // v22.10, from the whole-game bug hunt of 2026-10-08 (K21): KIT CARRIED UP AND THEN USED, DROPPED OR GIVEN AWAY NO LONGER EATS WHAT
  // THE RUN FOUND. Hazard pay, the XP haul term, a haul contract, the best haul and the hire debt test all count the backpack at the
  // end less what the lift carried up (G.carriedIn), and only a sale at the stall ever lowered that (v20.47), so two Medkits used in a
  // fight still came off the haul. The carried copies are matched against the backpack by count here, before any of those readers,
  // and whatever went up and is no longer in it comes off once. Its value goes onto G.kitSold, so the lifetime earnings still count
  // everything that went up. Issued Bandages are carried copies too. No price and no seeded draw moved.
  if(G.carriedKit&&G.carriedKit.length){
    var _bc={}, _gone=0, _ckk, _cin;
    for(i=0;i<G.bag.length;i++) _bc[G.bag[i]]=(_bc[G.bag[i]]||0)+1;
    for(i=0;i<G.carriedKit.length;i++){ _ckk=G.carriedKit[i]; if(_bc[_ckk]>0) _bc[_ckk]--; else _gone+=ival(_ckk); }
    if(_gone>0){ _cin=G.carriedIn||0; G.carriedIn=Math.max(0,_cin-_gone); G.kitSold=(G.kitSold||0)+(_cin-G.carriedIn); }
  }
  // A raid with no time on the clock, no distance walked, nothing searched and
'@

SubRx @'
var VER='22.09';
'@ @'
var VER='22.10';
'@

$pat = "(?m)^  now:'v22\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.10: Kit you carry up and then use, drop or give away no longer cuts hazard pay or the haul. Check 22.10 fails on v22.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
