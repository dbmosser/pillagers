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

# HIRE AND PEDDLER AUDIT OF 2026-09-14, finding 5: ISSUED BANDAGES COULD BE SOLD. The lift issues
# up to two Bandages as a loaner that is never banked (v13.54). The stall bought them at 55
# percent, 33 each, carried home at the extraction: free money every raid, and once sold they
# were no longer in the backpack for the extraction exclusion to hold back. The stall now keeps
# the issued Bandages the way it keeps the belt's copies, a belt copy counting as issued first.
SubRx @'
  var _cl=pedBeltClaims();
'@ @'
  var _cl=pedBeltClaims(), _iss=G.issuedBandages||0;
'@
SubRx @'
    if(_cl[k]>0){ _cl[k]--; kept.push(k); continue; }
'@ @'
    if(_cl[k]>0){ _cl[k]--; if(k==='bandage'&&_iss>0) _iss--; kept.push(k); continue; }
    // v13.71, hire and peddler audit: nor does he buy the issued Bandages, a loaner that is
    // never banked (v13.54); 33 each was free money every raid.
    if(k==='bandage'&&_iss>0){ _iss--; kept.push(k); continue; }
'@
SubRx @'
  var tot=0,n=0,fullv=0,_tcl=pedBeltClaims();
'@ @'
  var tot=0,n=0,fullv=0,_tcl=pedBeltClaims(),_tiss=(G.issuedBandages||0);
'@
SubRx @'
    if(_tcl[k]>0){ _tcl[k]--; continue; }   // v13.70: the belt's copies are not for sale
'@ @'
    if(_tcl[k]>0){ _tcl[k]--; if(k==='bandage'&&_tiss>0) _tiss--; continue; }   // v13.70: the belt's copies are not for sale
    if(k==='bandage'&&_tiss>0){ _tiss--; continue; }   // v13.71: nor are the issued Bandages
'@
SubRx @'
var VER='13.70';
'@ @'
var VER='13.71';
'@

$pat = "(?m)^  now:'v13\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.71: THE STALL DOES NOT BUY ISSUED BANDAGES. Hire and peddler audit of 2026-09-14, finding 5: the Bandages the lift issues are a loaner never banked (v13.54), but the stall bought them at 55 percent, 33 each, carried home at the extraction every raid. The sale and the stall count now keep the issued count of Bandages, a belted copy counting as issued first. Check 13.71 sells a backpack holding the two issued Bandages and one plain item and requires both Bandages kept and only the plain item paid for, with a found Bandage sold as the control; it fails on v13.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
