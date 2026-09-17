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
  var i,tot=0,full=0,n=0,kept=[];
'@ @'
  var i,tot=0,full=0,n=0,kept=[],_soldB=0;   // v15.36, peddler audit finding 8: _soldB, the found Bandages this sale takes
'@
SubRx @'
    tot+=Math.round(ival(k)*pedBuyRate()); full+=ival(k); n++;
'@ @'
    tot+=Math.round(ival(k)*pedBuyRate()); full+=ival(k); n++; if(k==='bandage') _soldB++;   // v15.36, peddler audit finding 8: a found Bandage he buys
'@
SubRx @'
  if(!n){ if(!G.sim) say('Nothing in your backpack he wants.'); return; }
  G.bag=kept;
'@ @'
  if(!n){ if(!G.sim) say('Nothing in your backpack he wants.'); return; }
  // v15.36, peddler audit finding 8: SELLING FOUND BANDAGES NEVER TURNS ISSUED BANDAGES INTO FOUND ONES. Since v13.71 the stall
  // keeps the issued Bandages and buys only the found ones, but the sale left G.bandSeen where the last frame put it. On the
  // next frame trackIssuedBandages saw the Bandage count fall by the number sold and, by the older v13.67 rule that every fall
  // spends issued ones first, took that many off G.issuedBandages. The loaners the stall had just refused to buy then counted
  // as found: the panel priced them, a second press sold them (the free money v13.71 took away), and an extraction banked them
  // against v13.54. The sale now moves what the count last saw by the found Bandages it took, as dropItem does for a drop
  // (v13.90), so the frame reads no fall. A use or a drop after the sale is still counted. No seeded draw, no price changed.
  G.bag=kept; if(G.bandSeen!==undefined) G.bandSeen-=_soldB;
'@
SubRx @'
var VER='15.35';
'@ @'
var VER='15.36';
'@

$pat = "(?m)^  now:'v15\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.36: SELLING FOUND BANDAGES NEVER TURNS ISSUED BANDAGES INTO FOUND ONES. The stall keeps the two issued Bandages and buys only found ones, but on the frame after the sale the game read the drop in Bandages as the issued pair being spent, so the loaners then counted as found: a second press sold them and an extraction banked them. The sale now moves the Bandage count that frame reads, the way a drop already does. Check 15.36 sells three found Bandages beside the issued pair at the open stall, presses again, uses one and extracts; it fails on v15.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
