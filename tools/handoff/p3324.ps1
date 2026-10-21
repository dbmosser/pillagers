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

# KILL CHAIN TICKS CLIMB A NOTE FOR EACH KILL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// ---------------------------------------------------------------- the stronghold gate breach

'@ @'
// v28.xx (cw-chaintick), HIS YES (100 picks, 72 "pitch-climbing kill chain", replacing the announcer with sounds that are not words): every kill that CHAINS
// (the second kill inside the streak gap, the existing chain) plays one small soft tick, a sine pluck, a note higher than the one before on an E minor
// pentatonic (E5 G5 A5 B5 D6 E6 G6 A6, the key of the medal pops). The chain breaking starts the count again, because the step is read from the
// streak count itself (the second kill is step 0). Past the eighth step it holds the top note. On the sting bus, so nothing ducks it, and each tick
// is only a few thousandths of full scale (0.06 plus a 0.012 octave), under a medal pop (0.22). Cosmetic: no game state, no seeded draw.
var CHAIN_NOTES=[659.3,784,880,987.8,1174.7,1318.5,1568,1760];
function chainTickStep(n){ n=n|0; return (n>=2)?Math.min(CHAIN_NOTES.length-1,n-2):-1; }
function chainTickPlay(n){
  var s=chainTickStep(n);
  if(s<0) return '';
  try{ blip('chainTick'+s); }catch(_ct){}
  return 'chainTick'+s;
}
(function(){
  var i;
  for(i=0;i<CHAIN_NOTES.length;i++){
    (function(step){
      var nm='chainTick'+step, f=CHAIN_NOTES[step];
      SPK_CAT[nm]='sting';
      SPK_INFO[nm]={grp:'medals',lab:'KILL CHAIN tick '+(step+1)+' of '+CHAIN_NOTES.length,len:0.14,kind:'synth',uses:[]};
      SPK_GEN[nm]=function(a,OUT,vol,t){
        var M, o;
        if(!spkGate('chainTick',0.04,t)) return null;
        M=spkMaster(a,OUT,vol,t);
        o=spkOsc(a,M,{ty:'sine',f0:f,dur:0.1,g:0.06,at:t,atk:0.002});
        spkOsc(a,M,{ty:'triangle',f0:f*2,dur:0.05,g:0.012,lp:3600,at:t,atk:0.002});
        return spkH(M,o,t+0.14);
      };
    })(i);
  }
})();
// ---------------------------------------------------------------- the stronghold gate breach

'@

SubRx @'
  if(c){ try{ say(c,'ext',{sub:'x'+mx}); }catch(_asc){} try{ if(ANN_STREAK[c]) blip('medal'+(SPK_MEDALS[c]||1)); }catch(_avc){} }   // v27.94 (snd3): the streak is a medal pop that climbs, DOUBLE KILL medal1 to UNSTOPPABLE medal5

'@ @'
  if(c){ try{ say(c,'ext',{sub:'x'+mx}); }catch(_asc){} try{ if(ANN_STREAK[c]) blip('medal'+(SPK_MEDALS[c]||1)); }catch(_avc){} }   // v27.94 (snd3): the streak is a medal pop that climbs, DOUBLE KILL medal1 to UNSTOPPABLE medal5
  try{ chainTickPlay(s.n); }catch(_ctk){}   // v28.xx (cw-chaintick): a rising tick for each kill in the chain

'@

SubRx @'
  if(c){ try{ say(c,'ext',{sub:'x'+mx}); }catch(_asc){} try{ if(ANN_STREAK[c]) blip('medal'+(SPK_MEDALS[c]||1)); }catch(_avc){} }   // v27.94 (snd3): the streak plays a medal pop that climbs (it was a chime ladder)

'@ @'
  if(c){ try{ say(c,'ext',{sub:'x'+mx}); }catch(_asc){} try{ if(ANN_STREAK[c]) blip('medal'+(SPK_MEDALS[c]||1)); }catch(_avc){} }   // v27.94 (snd3): the streak plays a medal pop that climbs (it was a chime ladder)
  try{ chainTickPlay(s.n); }catch(_ctk){}   // v28.xx (cw-chaintick): a rising tick for each kill in the chain

'@

SubRx @'
var VER='33.23';
'@ @'
var VER='33.24';
'@

$pat = "(?m)^  now:'v33\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.24: Chained kills now tick a note higher each time, and a broken chain starts the climb again. Check 33.24 fails on v33.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
