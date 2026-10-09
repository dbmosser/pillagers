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

# ONE UNDERCROFT SONG IN TWO PLAYER PLAY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(typeof pendingRun!=='undefined'&&pendingRun) return false;
  return true;                            // the Undercroft, and only the Undercroft
'@ @'
  if(typeof pendingRun!=='undefined'&&pendingRun) return false;
  // v20.86, from the whole-game bug hunt of 2026-10-08 (H53): ONE UNDERCROFT SONG FOR THE PAIR. In a same machine mode both windows
  // ran this, and each picked its own theme at random (four times in five a different one) on its own clock, so with the world
  // sound in both windows two songs played at once, one in each speaker with SPLIT SPEAKERS on. The player 2 window now leaves the
  // music to the player 1 window, unless the world sound is set to player 2 only, when it is the one window that can be heard.
  // With SPLIT SPEAKERS on, the song still plays from both speakers (netMusOut). Solo play and the invite
  // code party never set NET.same, so nothing changes there.
  if(typeof NET==='object'&&NET&&NET.same==='p2'&&netSndWho()!=='p2') return false;
  return true;                            // the Undercroft, and only the Undercroft
'@

SubRx @'
function netSndOut(a){
'@ @'
// v20.86 (H53): THE ONE SONG PLAYS IN THE MIDDLE. With SPLIT SPEAKERS on, everything a window plays is panned to its side, so
// the one Undercroft song would sit in player 1's speaker only. The music goes through a gain of its own that follows this
// window's sound switch but skips the split panner, so it plays from both speakers.
function netMusOut(a){
  if(!a) return null;
  if(!NET.same) return a.destination;
  if(!NET.musG||NET.musAc!==a){
    try{ NET.musG=a.createGain(); NET.musG.gain.value=NET.sndOn?1:0; NET.musG.connect(a.destination); NET.musAc=a; }
    catch(e){ NET.musG=null; NET.musAc=null; return netSndOut(a); }
  }
  return NET.musG;
}
function netSndOut(a){
'@

SubRx @'
function netSndApply(){ var on=netSndWhoOn(); NET.sndOn=on; if(NET.sndG){ try{ NET.sndG.gain.value=on?1:0; }catch(e){} }
'@ @'
function netSndApply(){ var on=netSndWhoOn(); NET.sndOn=on; if(NET.sndG){ try{ NET.sndG.gain.value=on?1:0; }catch(e){} } if(NET.musG){ try{ NET.musG.gain.value=on?1:0; }catch(e){} }
'@

SubRx @'
    MUS.g.connect(MUS.lp); MUS.lp.connect(netSndOut(a));
'@ @'
    MUS.g.connect(MUS.lp); MUS.lp.connect(netMusOut(a));   // v20.86 (H53): past the split panner, so the one song is in both speakers
'@

SubRx @'
  list=[BUS||null,(REV&&REV.wet)||null,(MUS&&MUS.lp)||null];
'@ @'
  list=[BUS||null,(REV&&REV.wet)||null];
  // v20.86 (H53): the music moves behind its own gain, past the split panner
  var _mg=netMusOut(a);
  if(MUS&&MUS.lp&&_mg&&_mg!==a.destination&&MUS.lp.__sndOut!==_mg){ try{ MUS.lp.disconnect(); }catch(e0){} try{ MUS.lp.connect(_mg); MUS.lp.__sndOut=_mg; moved++; }catch(e1){} }
'@

SubRx @'
var VER='20.85';
'@ @'
var VER='20.86';
'@

$pat = "(?m)^  now:'v20\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.86: In two player play on one machine, the Undercroft plays one song, not two at once. Check 20.86 fails on v20.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
