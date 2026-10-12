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

# THE FINAL MINUTE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function tickClockWarn(prev,now){

'@ @'
// v23.xx, HIS ANSWERS (2026-10-12), answer 19: "final 60 s: sting plus red clock". THE FINAL MINUTE. The one minute mark plays a sting
// of its own (a low brass hit with a bright ring on the sting bus, never ducked) in place of the rising clock siren, and from 1:00 the
// clock is red and pops on every second it turns, then settles before the next one. It was red only from 0:44 and never moved. The
// same in the CAREER clock and the DEMO clock under the score ("exactly the same in demo and career"); the DEMO figure also steps up
// to the callout size for the last minute, so it reads across the room. The words of every warning are unchanged.
var CLOCK_RED=60;
function clockPopIn(x,y,left){
  left=+left||0; if(!(left>0)) return false;
  var f=left-Math.floor(left), k=1+0.22*f*f*f;   // big the moment the figure turns, back to its size before the next
  ctx.save(); ctx.translate(x,y); ctx.scale(k,k); ctx.translate(-x,-y);
  return true;
}
function tickClockWarn(prev,now){

'@

SubRx @'
    blip('clockwarn');
  }
  var tick=0;

'@ @'
    blip(tlNow===60?'lastmin':'clockwarn');   // v23.xx (his answer 19): the final minute has a sting of its own
  }
  var tick=0;

'@

SubRx @'
  ctx.fillStyle=(!_noClk&&_tSrc<45)?'#ff5a4a':'#cdd6dd';

'@ @'
  ctx.fillStyle=(!_noClk&&_tSrc<=CLOCK_RED)?'#ff5a4a':'#cdd6dd';   // v23.xx (his answer 19): red for the final minute

'@

SubRx @'
  if(G.arcade) arcadeScoreHud(_yClk,_tz); else hudText(mm+':'+(ss<10?'0':'')+ss,W/2,_yClk);
'@ @'
  if(G.arcade) arcadeScoreHud(_yClk,_tz); else { var _cpo=(!_noClk&&_tSrc<=CLOCK_RED&&_tSrc>0)?clockPopIn(W/2,_yClk-_hClk*0.35,G.timeLeft):false; hudText(mm+':'+(ss<10?'0':'')+ss,W/2,_yClk); if(_cpo) ctx.restore(); }   /* v23.xx (his answer 19): it pops on every second of the final minute */
'@

SubRx @'
    ctx.font=fs; ctx.fillStyle=(_ct<45)?'#ff5a4a':'#cdd6dd'; hudText(_cm+':'+(_cs<10?'0':'')+_cs,cx,Math.round(y+h*0.62));
'@ @'
    var _cfin=(_ct<=CLOCK_RED), _cy=Math.round(y+h*(_cfin?0.88:0.62)), _apo=(_cfin&&_ct>0)?clockPopIn(cx,_cy-h*0.3,G.timeLeft):false;   // v23.xx (his answer 19): the final minute, red, bigger and popping
    ctx.font=_cfin?FSz(TYPE.head,z):fs; ctx.fillStyle=_cfin?'#ff5a4a':'#cdd6dd'; hudText(_cm+':'+(_cs<10?'0':'')+_cs,cx,_cy); if(_apo) ctx.restore();
'@

SubRx @'
  } else if(type==='clocktick'){

'@ @'
  } else if(type==='lastmin'){
    // v23.xx (his answer 19): THE FINAL MINUTE STING. A low brass hit (two detuned saws and a sub, the filter opening and closing)
    // under a bright two-note ring, 1.2 s, on the sting bus so nothing ducks or compresses it.
    var lmO=sndBus('sting')||OUT, lmF=a.createBiquadFilter(), lmG=a.createGain(), lmi, lmo;
    lmF.type='lowpass'; lmF.Q.value=2.2; lmF.frequency.setValueAtTime(380,t); lmF.frequency.exponentialRampToValueAtTime(1900,t+.07); lmF.frequency.exponentialRampToValueAtTime(420,t+1.1);
    lmG.gain.setValueAtTime(.0001,t); lmG.gain.linearRampToValueAtTime(.075*vol,t+.02); lmG.gain.exponentialRampToValueAtTime(.001,t+1.15);
    lmF.connect(lmG); lmG.connect(lmO);
    for(lmi=0;lmi<3;lmi++){
      lmo=a.createOscillator(); lmo.type=lmi<2?'sawtooth':'sine';
      lmo.frequency.setValueAtTime(lmi===0?110:(lmi===1?110.9:55),t);
      lmo.connect(lmF); lmo.start(t); lmo.stop(t+1.2);
    }
    for(lmi=0;lmi<2;lmi++){
      var lrO=a.createOscillator(), lrG=a.createGain(), lrt=t+lmi*.16;
      lrO.type='triangle'; lrO.frequency.setValueAtTime(lmi?1320:1760,lrt);
      lrG.gain.setValueAtTime(.0001,lrt); lrG.gain.linearRampToValueAtTime(.022*vol,lrt+.01); lrG.gain.exponentialRampToValueAtTime(.001,lrt+.55);
      lrO.connect(lrG); lrG.connect(lmO); lrO.start(lrt); lrO.stop(lrt+.6);
    }
  } else if(type==='clocktick'){

'@

SubRx @'
var VER='24.12';
'@ @'
var VER='24.13';
'@

$pat = "(?m)^  now:'v24\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.13: The final minute plays a sting and the clock turns red and pops each second, in career and demo. Check 24.13 fails on v24.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
