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

# FROM THE 2026-09-08 READ-ONLY AUDIT, confirmed by a skeptic against the source.
# THE LAST DEFECT ON THAT LIST.
#
# A district contract names a place, and it works that name out ONCE, when the
# card is written, against whatever sector was selected at that moment. The
# sentence is then frozen on the card, and the sector can be changed afterwards
# with one click and no effect on the board.
#
# The two sectors have places with names that are one letter apart. Roll the card
# on one and read it on the other, and it sends him to a place with almost the
# right name, at the far corner from the district it actually wants. He searches
# it out and the counter does not move, because the containers there carry a
# different district number. The panel in the raid repeats the same wrong place,
# because it prints the stored sentence verbatim.
#
# The card is not broken, only its label: the district number on it is right and
# it still ticks on the right containers wherever they are. So the fix is to stop
# freezing the sentence: the district is what the card holds, and the place it
# names is worked out when it is read, on the sector he is actually playing.
SubRx @'
function cstand(){ return P.cstand||0; }
'@ @'
function cstand(){ return P.cstand||0; }
// v12.70, 2026-09-08 audit: A DISTRICT CARD NAMES THE PLACE ON THE SECTOR HE IS
// PLAYING. The sentence used to be written once, at roll time, against whichever
// sector was selected then, and the sector can be changed afterwards with one
// click. The two sectors have places whose names are one letter apart, so a card
// rolled on one and read on the other sent him to almost the right name at the
// far corner from the district it wanted, and the counter never moved. The
// district number on the card was always right; only the sentence was stale. It
// is worked out on the way to the screen now, so it follows the sector.
function contractDesc(c){
  if(c&&c.type==='district'&&c.d!==undefined&&typeof districtPlaceName==='function')
    return 'Search '+(c.n||0)+' containers in '+districtPlaceName(c.d);
  return (c&&c.desc)||'contract';
}
'@

SubRx @'
    var cd=document.createElement('div'); cd.className='cd'; cd.textContent=c.desc;
'@ @'
    var cd=document.createElement('div'); cd.className='cd'; cd.textContent=contractDesc(c);   // v12.70: the place on the sector he is playing
'@

SubRx @'
      var _cdTxt=(CD.desc||'contract');
'@ @'
      var _cdTxt=contractDesc(CD);   // v12.70: and the same sentence in the raid
'@

# NEW IN.
SubRx @'
  'THE XP A RUN PAYS IS FOR WHAT YOU BROUGHT BACK. Carrying your own stash up the lift and straight back down paid full haul XP for loot you already owned, and handed the stash back untouched, so the whole reward track could be walked without finding anything.',
'@ @'
  'THE XP A RUN PAYS IS FOR WHAT YOU BROUGHT BACK. Carrying your own stash up the lift and straight back down paid full haul XP for loot you already owned, and handed the stash back untouched, so the whole reward track could be walked without finding anything.',
  'A SEARCH CONTRACT NAMES A PLACE ON THE SECTOR YOU ARE PLAYING. It wrote the name down when the card was made, so changing sector afterwards left it pointing at a place with almost the right name in the wrong part of the map, and searching it moved nothing.',
'@

# STAMPS.
SubRx @'
var VER='12.69';
'@ @'
var VER='12.70';
'@
SubRx @'
var WHATSNEW_VER='12.69';
'@ @'
var WHATSNEW_VER='12.70';
'@
$cnt=([regex]::Matches($s,"now:'v12\.69:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.69 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.69:[^']*'",{ param($m) "now:'v12.70: from the 2026-09-08 read-only audit, and the last defect on that list. A district contract names a place and it worked that name out ONCE, when the card was written, against whatever sector was selected at that moment; the sentence was then frozen on the card, and the sector can be changed afterwards with one click and no effect on the board. The two sectors have places whose names are one letter apart, so a card rolled on one and read on the other sent him to a place with almost the right name at the far corner from the district it actually wanted: he searched it out and the counter never moved, because the containers there carry a different district number, and the panel in the raid repeated the same wrong place because it printed the stored sentence verbatim. The card itself was never broken, only its label, since the district number on it is right and it still ticks on the right containers wherever they are. So the sentence is no longer frozen: the district is what the card holds, and the place it names is worked out on the way to the screen, on the sector he is actually playing. Check 12.70 writes a district card on one sector, switches to the other, and requires the board and the in-raid panel to name a place that exists on the sector he is now playing, with a control that a card of any other type still reads exactly what it was written with; fails on v12.69.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
