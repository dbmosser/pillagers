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

# THE UNDERCROFT SONG FOLLOWS THE PLAYERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(typeof NET==='object'&&NET&&NET.same==='p2'&&netSndWho()!=='p2') return false;
'@ @'
  // v21.22, from the review of the night builds (2026-10-09, R5): player 2 leaves the song to player 1 only while player 1 is on the
  // floor too (NET.hostSeed is set while the host is up top). Back first from a raid the host is still in, his floor was silent.
  if(typeof NET==='object'&&NET&&NET.same==='p2'&&netSndWho()!=='p2'&&!NET.hostSeed) return false;
'@

SubRx @'
    try{ NET.musG=a.createGain(); NET.musG.gain.value=NET.sndOn?1:0; NET.musG.connect(a.destination); NET.musAc=a; }
'@ @'
    try{ NET.musG=a.createGain(); NET.musG.gain.value=NET.sndOn?1:0; NET.musAc=a;
         // v21.22 (R5): through a panner of its own, centred while both players are on the floor (netMusPan)
         NET.musP=null; try{ if(a.createStereoPanner){ NET.musP=a.createStereoPanner(); NET.musG.connect(NET.musP); NET.musP.connect(a.destination); } }catch(_mp){ NET.musP=null; }
         if(!NET.musP) NET.musG.connect(a.destination);
         netMusPan(); }
'@

SubRx @'
function netMusOut(a){
'@ @'
// v21.22, from the review of the night builds (2026-10-09, R5): WHERE THE ONE SONG SITS. Centred only while both players are on the
// floor. While the other player is still up top (the host spectating with the party in the raid, or player 2 back first), this window's
// song keeps to its own side with SPLIT SPEAKERS on, as every sound of this window does, so no Undercroft music reaches the speaker
// of a player in a raid (his ruling: no raid music).
function netMusPan(){
  var up, on, pan=0;
  if(!NET.musP) return 0;
  up=(NET.same==='p2')?!!NET.hostSeed:!!NET.specG;
  on=(typeof netSndWhoOn==='function')?netSndWhoOn():true;
  if(on&&up&&netSndWho()==='both'&&netSndSplitOn()) pan=(NET.same==='p2')?1:-1;
  try{ NET.musP.pan.value=pan; }catch(e){}
  return pan;
}
function netMusOut(a){
'@

SubRx @'
function netSndRelease(){ NET.sndOther=-1; if(NET.sndG){ try{ NET.sndG.gain.value=1; }catch(e){} }
'@ @'
function netSndRelease(){ NET.sndOther=-1; if(NET.sndG){ try{ NET.sndG.gain.value=1; }catch(e){} } if(NET.musG){ try{ NET.musG.gain.value=1; }catch(e3){} } if(NET.musP){ try{ NET.musP.pan.value=0; }catch(e4){} }   /* v21.22 (R6): the music comes back with the rest when the party ends */
'@

SubRx @'
function tickMusic(){
'@ @'
function tickMusic(){
  try{ if(typeof NET==='object'&&NET&&NET.same&&NET.musP) netMusPan(); }catch(_mpt){}   // v21.22 (R5): the song moves to the middle when both players are on the floor
'@

SubRx @'
var VER='21.21';
'@ @'
var VER='21.22';
'@

$pat = "(?m)^  now:'v21\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.22: In two player play on one machine, the Undercroft song plays for whoever is on the floor and never reaches a player in a raid. Check 21.22 fails on v21.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
