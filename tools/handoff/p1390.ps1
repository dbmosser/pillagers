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

# SEARCHING AND LOOT AUDIT OF 2026-09-14, finding 6, an edge of my own v13.67: DROPPING THE ISSUED
# BANDAGES AND SEARCHING THEM BACK UP TURNED THEM INTO FOUND LOOT. v13.67 counts the issued
# Bandages down whenever the backpack holds fewer, and a rise counts as a find. Drop both issued
# Bandages and the count falls to zero; search the two piles back up and the backpack rises by
# two finds, so the stall bought them and the extraction banked them. The pile now remembers
# that it holds an issued Bandage: the drop takes one off the issued count on the spot, and
# picking that pile back up puts it back.
SubRx @'
  // v13.89, loot audit: never inside a wall, where no search could reach it. At his feet instead.
  if(G.vseg&&!losClear(p.x,p.y,c.x,c.y,G.vseg)){ c.x=p.x; c.y=p.y; }
'@ @'
  // v13.89, loot audit: never inside a wall, where no search could reach it. At his feet instead.
  if(G.vseg&&!losClear(p.x,p.y,c.x,c.y,G.vseg)){ c.x=p.x; c.y=p.y; }
  // v13.90, loot audit: an issued Bandage stays issued on the ground. The drop spends it from the
  // count now (and from what the count last saw, so the frame tick does not spend it twice), and
  // the pile carries it back when it is searched up.
  if(key==='bandage'&&(G.issuedBandages||0)>0){
    G.issuedBandages--; c.issuedB=1;
    if(G.bandSeen!==undefined) G.bandSeen--;
  }
'@
SubRx @'
    var key=keys[l],itm=ITEMS[key];
    T.items++; T.rar[itm.r]++;
'@ @'
    var key=keys[l],itm=ITEMS[key];
    T.items++; T.rar[itm.r]++;
    if(ct.issuedB&&key==='bandage'){ ct.issuedB=0; G.issuedBandages=(G.issuedBandages||0)+1; }   // v13.90: an issued Bandage picked back up is still issued
'@
SubRx @'
var VER='13.89';
'@ @'
var VER='13.90';
'@

$pat = "(?m)^  now:'v13\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.90: AN ISSUED BANDAGE PICKED BACK UP IS STILL ISSUED. Searching and loot audit of 2026-09-14, finding 6, an edge of v13.67: the issued count falls when the backpack holds fewer Bandages and a rise counts as a find, so dropping the issued pair and searching it back up turned both into found loot the stall bought and the extraction banked. A dropped issued Bandage now comes off the count at the drop and marks its pile, and picking that pile up puts it back. Check 13.90 drops both issued Bandages, searches both piles up and requires the issued count back at two, with a found Bandage dropped and picked up staying found as the guard; it fails on v13.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
