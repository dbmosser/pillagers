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

# THE FIND SOUNDS STOP RINGING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function blip(type,d,pan){
'@ @'
// v24.xx, HIS NOTE 2026-10-12: "sound after finding rarer items lingers for too long". THE FIND SOUNDS ARE DRY AND SHORT.
// The find voices themselves were short (green 0.13 s, blue 0.33, purple 0.48, a gun 0.22), but every one went into BUS, and
// BUS feeds the room reverb: four comb delays fed back at 0.80 inside a building and in the Undercroft and at 0.86 in a vault,
// so a bright two or three note chime rang on in the room for another 1.2 to 1.7 s after its notes ended, and a jackpot pulled
// item by item smeared each ring into the next. A find (green, blue, purple, gold, and the gun voice) now plays dry: on its own
// gain at the effects volume, straight to the speakers (through the same machine master gain, so the SOUND row still mutes it),
// with no room send, so the whole sound is over when its notes are: inside 0.6 s for green and blue, 0.8 s for purple and gold.
// The notes, pitches and attacks are untouched, so a purple still climbs above a blue. A new find cuts the one still ringing
// (an 8 ms fade) so two in a row never stack. The green find was the plain pick chirp every menu plays; it is pickUnc now, the
// same chirp on the dry path, so the menus keep theirs. Cosmetic only: no seeded draw and no game state.
var SND_FIND={pickUnc:1,pickRare:2,pickElite:3,pickGun:3}, SND_FIND_LAST=null;
function sndFindOut(a,t){
  var B=bus(), L=SND_FIND_LAST, g, o;
  if(!B) return null;
  if(L&&L.a===a&&L.g){ try{ L.g.gain.cancelScheduledValues(t); L.g.gain.setTargetAtTime(0,t,0.008); }catch(_c){} }
  SND_FIND_LAST=null;
  try{ g=a.createGain(); g.gain.value=B.gain.value; o=netSndOut(a)||a.destination; g.connect(o); }catch(e){ return null; }
  SND_FIND_LAST={a:a,g:g};
  return g;
}
function blip(type,d,pan){
'@

SubRx @'
  var OUT=sndBus(SND_CAT[type]||'world')||bus()||a.destination;   // v23.67 (his #45): onto the bus for its kind of sound
'@ @'
  var _fnd=SND_FIND[type]||0; if(type==='pickUnc') type='pick';   // v24.xx (his note): a find plays dry and short, see sndFindOut
  var OUT=sndBus(SND_CAT[type]||'world')||bus()||a.destination;   // v23.67 (his #45): onto the bus for its kind of sound
  if(_fnd){ var _fo=sndFindOut(a,t); if(_fo) OUT=_fo; }   // v24.xx (his note): no room reverb on a find, and it cuts the last one
'@

SubRx @'
  if(best>=2) return 'pickRare';
  return 'pick';
'@ @'
  if(best>=2) return 'pickRare';
  if(best===1) return 'pickUnc';   // v24.xx (his note): a green find, the pick chirp on the dry find path
  return 'pick';
'@

SubRx @'
lv=lootVoice(items); if(lv!=='pick') blip(lv);
'@ @'
lv=lootVoice(items); if(lv!=='pick'&&lv!=='pickUnc') blip(lv);
'@

SubRx @'
var VER='25.07';
'@ @'
var VER='25.08';
'@

$pat = "(?m)^  now:'v25\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.08: A rare find now rings short and dry, with no echo hanging on after it. Check 25.08 fails on v25.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
