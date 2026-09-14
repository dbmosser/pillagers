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

# END-OF-RAID AUDIT OF 2026-09-14, finding 3: ISSUED BANDAGES WERE BANKED. A raid that
# lands with no medical is given two Bandages, described as issued kit on the same deal
# as the loaner sidearm, and the loaner is never banked. The bandages were plain backpack
# items, so every extraction banked them into the stash: two free Bandages a raid. The
# raid now counts how many it issued, a bandage used counts one of those off first
# (bandages are all alike), and the extraction banks only the bandages beyond that count.
SubRx @'
    while(carried<ISSUED_HEALS){ g.bag.push('bandage'); carried++; }
'@ @'
    g.issuedBandages=0;   // v13.54: issued kit, like the loaner sidearm, is never banked
    while(carried<ISSUED_HEALS){ g.bag.push('bandage'); carried++; g.issuedBandages++; }
'@
SubRx @'
function startPrep(kind,key){
'@ @'
function startPrep(kind,key){
  // v13.54: a Bandage used spends an issued one first; they are all alike, so what is
  // left over at the extraction is what he found.
  if(kind==='heal'&&key==='bandage'&&G&&G.issuedBandages>0) G.issuedBandages--;
'@
SubRx @'
    for(i=0;i<G.bag.length;i++){ var bm=bankItem(G.bag[i]); if(bm) lines.push(bm); }
'@ @'
    var _issB=G.issuedBandages||0;   // v13.54: the issued Bandages still carried go back to the quartermaster, not the stash
    for(i=0;i<G.bag.length;i++){ if(_issB>0&&G.bag[i]==='bandage'){ _issB--; continue; } var bm=bankItem(G.bag[i]); if(bm) lines.push(bm); }
'@
SubRx @'
var VER='13.53';
'@ @'
var VER='13.54';
'@

$pat = "(?m)^  now:'v13\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.54: ISSUED BANDAGES ARE NO LONGER BANKED. End-of-raid audit of 2026-09-14, finding 3: a raid landing with no medical is given two Bandages as issued kit, on the same deal as the loaner sidearm that is never banked, but they were plain backpack items and every extraction banked them, two free Bandages a raid. The raid now counts what it issued, a Bandage used counts one of those off first, and the extraction banks only the Bandages beyond that count. Check 13.54 extracts with the issued pair and nothing found, which must add no Bandage to the stash, and with one Bandage found, which must add exactly one; it fails on v13.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
