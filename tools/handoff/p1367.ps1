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

# IN-RAID AUDIT OF 2026-09-14, finding 5: A FOUND BANDAGE WAS HELD BACK AFTER AN ISSUED ONE LEFT
# THE BACKPACK ANY WAY BUT USE. v13.54 counted the issued Bandages down only in startPrep, so
# dropping the issued pair, selling it to the peddler or giving it to a hire left the count at
# two; the next two Bandages he found were then kept back at the extraction as if issued.
# The count is now kept by watching how many Bandages the backpack holds, once a frame on the
# heal tick both the player and the bot run, and once more at the extraction: any fall spends
# issued ones first, which is the rule v13.54 wrote for a use. The startPrep line goes, or a
# use would be counted twice.
SubRx @'
  // v13.54: a Bandage used spends an issued one first; they are all alike, so what is
  // left over at the extraction is what he found.
  if(kind==='heal'&&key==='bandage'&&G&&G.issuedBandages>0) G.issuedBandages--;
'@ @'
  // v13.67: the issued Bandage count is kept by trackIssuedBandages, which sees every way
  // one leaves the backpack; this line saw only a use.
'@
SubRx @'
function tickHeal(dt){
  var p=G.player;
  tickPrep(dt);
'@ @'
// v13.67, in-raid audit: ISSUED BANDAGES ARE SPENT FIRST, HOWEVER THEY LEAVE. A use, a drop, a
// sale to the peddler and a Bandage handed to a hire all lower how many the backpack holds,
// and every fall spends issued ones before found ones, so what is left at the extraction
// above the issued count is what he found. Rises are finds and change nothing.
function trackIssuedBandages(){
  if(!G||!G.bag) return;
  var c=0; for(var i=0;i<G.bag.length;i++) if(G.bag[i]==='bandage') c++;
  if(G.bandSeen!==undefined&&c<G.bandSeen&&G.issuedBandages>0)
    G.issuedBandages=Math.max(0,G.issuedBandages-(G.bandSeen-c));
  G.bandSeen=c;
}
function tickHeal(dt){
  var p=G.player;
  trackIssuedBandages();
  tickPrep(dt);
'@
SubRx @'
    var _issB=G.issuedBandages||0;
'@ @'
    trackIssuedBandages();   // v13.67: a Bandage that left since the last frame is counted first
    var _issB=G.issuedBandages||0;
'@
SubRx @'
var VER='13.66';
'@ @'
var VER='13.67';
'@

$pat = "(?m)^  now:'v13\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.67: ISSUED BANDAGES ARE SPENT FIRST, HOWEVER THEY LEAVE. In-raid audit of 2026-09-14, finding 5: v13.54 counted issued Bandages down only in startPrep, so after dropping, selling or giving away the issued pair the next Bandages he found were held back at the extraction. trackIssuedBandages watches how many Bandages the backpack holds on the heal tick and at the extraction, and any fall spends issued ones first; the startPrep decrement goes so a use is not counted twice. Check 13.67 drops the issued Bandages, finds as many, and requires all of them banked, with a use then a find banking exactly one as the second arm; it fails on v13.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
