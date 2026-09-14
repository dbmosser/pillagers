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

# END-OF-RAID AUDIT OF 2026-09-14, finding 2: AN ITEM CONTRACT COULD BE MET WITH ITEMS FROM
# THE STASH. "Extract carrying 2x Optic" counted every matching item in the backpack at the
# extraction, including ones packed from the stash, which then went straight back to the
# stash. Pack two Optics, go up, walk out: the card completed and paid, again on every
# refill. The same leak v12.65 closed for the haul card, by item count this time. The raid
# records what the lift carried up, and the card counts only what is beyond it.
SubRx @'
  G.carriedIn=bagValue();
'@ @'
  G.carriedIn=bagValue();
  G.carriedKit=(G.bag||[]).slice();   // v13.55: WHICH items came up, so an item contract counts only what was found
'@
SubRx @'
      var n=0;
      for(var j=0;j<bag.length;j++) if(bag[j]===c.item) n++;
      if(n>=c.n) c.prog=c.n;
'@ @'
      var n=0;
      for(var j=0;j<bag.length;j++) if(bag[j]===c.item) n++;
      // v13.55, end-of-raid audit: what the run earned, not what the lift carried, by count.
      var _up=0, _ck=(G&&G.carriedKit)||[];
      for(var j2=0;j2<_ck.length;j2++) if(_ck[j2]===c.item) _up++;
      if(n-_up>=c.n) c.prog=c.n;
'@
SubRx @'
var VER='13.54';
'@ @'
var VER='13.55';
'@

$pat = "(?m)^  now:'v13\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.55: AN ITEM CONTRACT COUNTS ONLY WHAT THE RUN FOUND. End-of-raid audit of 2026-09-14, finding 2: extract carrying N of an item counted every match in the backpack at the extraction, including items packed from the stash that went straight back to it, so packing two Optics and walking out completed and paid the card on every refill. The raid now records which items the lift carried up, and the card counts only matches beyond those, the item-count form of the v12.65 haul fix. Check 13.55 stages an extract-carrying card for two of an item and calls the extraction count with the items carried up, which must not complete it, and found, which must; it fails on v13.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
