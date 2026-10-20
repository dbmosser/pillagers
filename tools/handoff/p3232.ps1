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

# A HARD CAP ON LOUD SOUND (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function bus(){

'@ @'
// v28.xx (cw-masterlimit), HIS WORDS (round 2, 2.12): "put a hard cap on loud sounds". THE MASTER LIMITER. Everything the game plays (the world
// buses, the HUD and the stings through BUS, the music and the end pieces through the music gain) now ends in this one limiter on its way to
// the speakers, always on: a fast compressor at -2 dB with a 20 to 1 ratio and no knee, so nothing can go past the ceiling. Where a context
// has no compressor (the dry recorder of the fixture) the destination itself is returned, as before.
function masterOut(a){
  var Lm;
  if(!a) return null;
  if(a.__ml) return a.__ml;
  try{
    if(a.createDynamicsCompressor){
      Lm=a.createDynamicsCompressor();
      Lm.threshold.value=-2; Lm.knee.value=0; Lm.ratio.value=20; Lm.attack.value=0.001; Lm.release.value=0.08;
      Lm.connect(a.destination); a.__ml=Lm; return Lm;
    }
  }catch(_ml){}
  return a.destination;
}
// v28.xx (cw-masterlimit), HIS ANSWER 2.69 b (rain: "about a third quieter"): the rain voice rides 0.030 times the rain strength (it was 0.045).
var RAIN_VOL=0.030;
function rainLevel(r){ return (+r||0)*RAIN_VOL; }
// v28.xx (cw-masterlimit), HIS ANSWER 2.12 b (party mode: "lower only the loudest sounds a few decibels (explosions, heavy guns, the boss)"):
// in the demo the impact bus (blasts, hits) plays 3 dB down and the gun bus 2 dB down. Career is unchanged.
function sndDemoTrim(cat){
  var on=(typeof ARCADE==='object'&&ARCADE&&ARCADE.on);
  if(!on) return 1;
  return (cat==='imp')?0.708:((cat==='gun')?0.794:1);
}
function bus(){

'@

SubRx @'
A.wg.gain.setTargetAtTime(alive?wxr*0.045:0,t,1.2);
'@ @'
A.wg.gain.setTargetAtTime(alive?rainLevel(wxr):0,t,1.2);   // v28.xx (cw-masterlimit): a third quieter
'@

SubRx @'
gn.gain.value=(c==='ui')?volOf('volUi'):1;
'@ @'
gn.gain.value=(c==='ui')?volOf('volUi'):sndDemoTrim(c);
'@

SubRx @'
  try{ monoApply(); }catch(_vm2){}   // v26.xx (settings1): MONO AUDIO

'@ @'
  try{ if(SND&&SND.bus){ ['imp','gun'].forEach(function(_tc){ var _tg=SND.bus[_tc]&&SND.bus[_tc].gain, _tv=sndDemoTrim(_tc); if(_tg&&_tg.value!==_tv) _tg.value=_tv; }); } }catch(_vt){}   // v28.xx (cw-masterlimit): the demo trim follows the mode
  try{ monoApply(); }catch(_vm2){}   // v26.xx (settings1): MONO AUDIO

'@

SubRx @'
function netMusOut(a){
  if(!a) return null;
  if(!NET.same) return a.destination;

'@ @'
function netMusOut(a){
  if(!a) return null;
  if(!NET.same) return masterOut(a);   // v28.xx (cw-masterlimit): through the master limiter

'@

SubRx @'
NET.musG.connect(NET.musP); NET.musP.connect(a.destination);
'@ @'
NET.musG.connect(NET.musP); NET.musP.connect(masterOut(a));
'@

SubRx @'
if(!NET.musP) NET.musG.connect(a.destination);
'@ @'
if(!NET.musP) NET.musG.connect(masterOut(a));
'@

SubRx @'
function netSndOut(a){
  if(!a) return null;
  if(!NET.same) return a.destination;

'@ @'
function netSndOut(a){
  if(!a) return null;
  if(!NET.same) return masterOut(a);   // v28.xx (cw-masterlimit): through the master limiter

'@

SubRx @'
NET.sndG.connect(NET.sndP); NET.sndP.connect(a.destination);
'@ @'
NET.sndG.connect(NET.sndP); NET.sndP.connect(masterOut(a));
'@

SubRx @'
if(!NET.sndP) NET.sndG.connect(a.destination);
'@ @'
if(!NET.sndP) NET.sndG.connect(masterOut(a));
'@

SubRx @'
NET.sndG=null; NET.sndAc=null; return a.destination; }
'@ @'
NET.sndG=null; NET.sndAc=null; return masterOut(a); }
'@

SubRx @'
var VER='32.31';
'@ @'
var VER='32.32';
'@

$pat = "(?m)^  now:'v32\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.32: A master limiter caps every sound, the rain is a third quieter, and the demo lowers blasts and guns. Check 32.32 fails on v32.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
