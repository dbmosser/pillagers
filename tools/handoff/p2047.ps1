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

# SELLING YOUR OWN KIT KEEPS WHAT YOU FOUND (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var _cl=pedBeltClaims(), _iss=G.issuedBandages||0;
'@ @'
  var _cl=pedBeltClaims(), _iss=G.issuedBandages||0;
  // v20.47, from the whole-game bug hunt of 2026-10-08 (H18): KIT CARRIED UP AND SOLD HERE NO LONGER EATS WHAT THE RUN FOUND. Hazard
  // pay, the XP haul term, a haul card and the best haul all count the backpack at the end less what the lift carried up
  // (G.carriedIn). A sale took the kit out of the backpack but left its value in G.carriedIn, so selling 1,520 of carried Medkits
  // and Plates and then finding 1,500 counted nothing found at all. A purchase here already adds to what was carried up (v13.91);
  // a sale of a carried copy now takes it off again, and off the list of carried items, by count. The issued Bandages he keeps are
  // carried copies still in the backpack, so a found Bandage sold is never matched to one. What the sold kit was worth is kept on
  // G.kitSold, so the lifetime earnings of v15.84 still count everything that went up. No price and no seeded draw moved.
  var _ck={}, _ckOut=[], _ckV=0, _cj, _ckL=G.carriedKit||[];
  for(_cj=0;_cj<_ckL.length;_cj++) _ck[_ckL[_cj]]=(_ck[_ckL[_cj]]||0)+1;
  if(_ck.bandage) _ck.bandage=Math.max(0,_ck.bandage-_iss);
'@

SubRx @'
    tot+=Math.round(ival(k)*pedBuyRate()); full+=ival(k); n++; if(k==='bandage') _soldB++;   // v15.36, peddler audit finding 8: a found Bandage he buys
'@ @'
    tot+=Math.round(ival(k)*pedBuyRate()); full+=ival(k); n++; if(k==='bandage') _soldB++;   // v15.36, peddler audit finding 8: a found Bandage he buys
    if(_ck[k]>0){ _ck[k]--; _ckOut.push(k); _ckV+=ival(k); }   // v20.47 (H18): a copy the lift carried up, sold
'@

SubRx @'
  G.bag=kept; if(G.bandSeen!==undefined) G.bandSeen-=_soldB;
'@ @'
  G.bag=kept; if(G.bandSeen!==undefined) G.bandSeen-=_soldB;
  if(_ckV>0){   // v20.47 (H18): what was carried up and sold here no longer counts as carried up
    G.carriedIn=Math.max(0,(G.carriedIn||0)-_ckV); G.kitSold=(G.kitSold||0)+_ckV;
    for(_cj=0;_cj<_ckOut.length;_cj++){ var _cx=G.carriedKit.indexOf(_ckOut[_cj]); if(_cx>=0) G.carriedKit.splice(_cx,1); }
  }
'@

SubRx @'
function runEarnings(rec){ return ((rec.outcome==='extract')?((rec.haul||0)+(rec.pedSold||0)):0)-(rec.carriedIn||0); }
'@ @'
// v20.47 (H18): and less what was carried up and then sold at the stall (kitSold), which a sale now takes out of carriedIn, so the
// sum is what it was: everything that came out, stall money included, less everything that went up. An older row has no kitSold.
function runEarnings(rec){ return ((rec.outcome==='extract')?((rec.haul||0)+(rec.pedSold||0)):0)-(rec.carriedIn||0)-(rec.kitSold||0); }
'@

SubRx @'
    carriedIn:G.carriedIn||0,   // v10.27: the bag's value when the lift landed
'@ @'
    carriedIn:G.carriedIn||0,   // v10.27: the bag's value when the lift landed
    kitSold:G.kitSold||0,   // v20.47 (H18): the part of it sold at the stall, which runEarnings still counts as gone up
'@

SubRx @'
var VER='20.46';
'@ @'
var VER='20.47';
'@

$pat = "(?m)^  now:'v20\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.47: Selling your own kit at the Peddler no longer wipes out the hazard pay and XP for the loot you found. Check 20.47 fails on v20.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
