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

# THE HOWLER WALKS ON ITS OWN STEP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// ---------------------------------------------------------------- the stronghold gate breach

'@ @'
// v28.xx (cw-howlstep), HIS YES (100 picks, 73 "machine movement signatures", motion only, no continuous tones). Looked at which machines already have a way of
// moving that you can hear: the sentry, the warden (and so the Overseer, a boss warden) and the bulwark have the heavy clank (stepSoundFor, v8.55), the crawler
// its skitter, the Crier its drone, the pillbox and the Listener do not walk. The HOWLER walks and was the only machine on the light pillager scuff. It gets a
// step of its own: a quick pneumatic tick (a click, a short bandpassed knock around 1.5 kHz, a falling 330 to 180 Hz triangle and a faint 3 kHz hiss), lighter
// than a clank and sharper than a scuff, a little slower than a pillager's, on the machine bus and on the FOOTSTEPS VOLUME row like every step. Nothing is held,
// nothing hums: one short sound per step, at most one per 150 ms.
SPK_CAT.stepHowl='mach';
SPK_INFO.stepHowl={grp:'machines',lab:'HOWLER step',len:0.14,kind:'synth',uses:[]};
SPK_GEN.stepHowl=function(a,OUT,vol,t){
  var M, o;
  if(!spkGate('stepHowl',0.15,t)) return null;
  M=spkMaster(a,OUT,vol,t);
  spkTick(a,M,t,2200,1,0.01,0.1);
  spkTick(a,M,t,1500,1.2,0.04,0.12);
  o=spkOsc(a,M,{ty:'triangle',f0:330,f1:180,dur:0.07,g:0.06,lp:900,at:t,atk:0.002});
  spkNoise(a,M,{at:t+0.02,dur:0.09,g:0.03,ft:'highpass',f0:3000,q:0.7,atk:0.004});
  return spkH(M,o,t+0.14);
};
// ---------------------------------------------------------------- the stronghold gate breach

'@

SubRx @'
function stepSoundFor(kind){
  return (kind==='sentry'||kind==='warden'||kind==='bulwark')?'stepHeavy':'step';
}

'@ @'
function stepSoundFor(kind){
  if(kind==='howler') return 'stepHowl';   // v28.xx (cw-howlstep): the Howler walks on its own sound
  return (kind==='sentry'||kind==='warden'||kind==='bulwark')?'stepHeavy':'step';
}

'@

SubRx @'
  if(heavy) blip('stepHeavy',ear.d*1.35,ear.pan,bsurf);

'@ @'
  if(stepSoundFor(best.kind)==='stepHowl') blip('stepHowl',ear.d*1.35,ear.pan,bsurf);   // v28.xx (cw-howlstep)
  else if(heavy) blip('stepHeavy',ear.d*1.35,ear.pan,bsurf);

'@

SubRx @'
  STEP_T=(heavy?0.62:0.44)*
'@ @'
  STEP_T=(heavy?0.62:(best.kind==='howler'?0.56:0.44))*
'@

SubRx @'
(type==='foot'||type==='step'||type==='stepHeavy')?volOf('volFoot'):1
'@ @'
(type==='foot'||type==='step'||type==='stepHeavy'||type==='stepHowl')?volOf('volFoot'):1
'@

SubRx @'
var VER='33.33';
'@ @'
var VER='33.34';
'@

$pat = "(?m)^  now:'v33\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.34: The Howler now has its own walking sound, a quick pneumatic tick. The other machines sound as before. Check 33.34 fails on v33.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
