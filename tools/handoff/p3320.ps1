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

# LOW HEALTH FILTER: THE WORLD MUFFLES AS YOU BLEED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var SND_DOWN={n:0,mine:0,mate:0,at:-1};

'@ @'
var SND_DOWN={n:0,mine:0,mate:0,at:-1};
// v28.xx (cw-lowhpfilter), HIS YES (100 picks, 70 "low-health filter", CoD low-health audio): below 30 health the world mix runs through a soft low-pass
// that closes with the damage: nothing at 30, about 12 kHz just under it, down to 2.2 kHz at 0 (a log curve, so the first points of damage are barely heard).
// It rides the SAME filter as the downed dip (sndDipOf, after the world trim, so the menu sounds, the HUD ticks and the stings never go through it) and
// it waits out the dip, so the two never stack: the dip owns the filter for 1.3 s after a fall, then the health sets it again. It eases with a 0.5 s
// time constant both ways. Nothing in a raid that is over or in the Undercroft.
var LOWHP_AT=30, LOWHP_HI=12000, LOWHP_LO=2200;
function lowHpFreq(hp,downed,ny){
  var f;
  if(downed||!(hp<LOWHP_AT)) return ny;
  f=Math.max(0,Math.min(1,1-Math.max(0,hp)/LOWHP_AT));
  return Math.min(ny,LOWHP_HI*Math.pow(LOWHP_LO/LOWHP_HI,f));
}
function sndLowHpApply(a,S,hp,downed){
  var ny, f, t, dip;
  if(!a||!S||!S.out) return 'skip';
  ny=a.sampleRate/2;
  t=a.currentTime;
  if(t<(SND_DOWN.dipEnd||0)) return 'dip';
  f=lowHpFreq(hp,downed,ny);
  if(!S.dip&&f>=ny) return 'skip';
  if(S.lowHpF>0&&Math.abs(Math.log(f/S.lowHpF))<0.02) return 'same';
  dip=sndDipOf(a); if(!dip) return 'skip';
  try{ dip.frequency.setTargetAtTime(f,t,0.5); }catch(_lh){ return 'skip'; }
  S.lowHpF=f;
  return 'set';
}
function sndLowHpTick(){
  var pp=(G&&G.player&&!G.over&&!G.sim)?G.player:null;
  if(typeof NET==='object'&&NET&&NET.specTick) return 'skip';
  return sndLowHpApply(AC||null,SND,pp?pp.hp:100,!!(pp&&pp.downed));
}
'@

SubRx @'
        dip.frequency.exponentialRampToValueAtTime(ny,t+1.25);

'@ @'
        dip.frequency.exponentialRampToValueAtTime(ny,t+1.25);
        SND_DOWN.dipEnd=t+1.3; SND.lowHpF=0;   // v28.xx (cw-lowhpfilter): the dip owns the filter until it has opened; the health sets it again after

'@

SubRx @'
  try{ sndMixTick(dt); }catch(_mx){}   // v23.69 (his #45): the ducked buses come back up

'@ @'
  try{ sndMixTick(dt); }catch(_mx){}   // v23.69 (his #45): the ducked buses come back up
  try{ sndLowHpTick(); }catch(_lh){}   // v28.xx (cw-lowhpfilter): the low health filter

'@

SubRx @'
var VER='33.19';
'@ @'
var VER='33.20';
'@

$pat = "(?m)^  now:'v33\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.20: Below 30 health the sound of the world goes duller as you get worse. Back above 30 it opens again. Menu clicks and pickups stay crisp. Check 33.20 fails on v33.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
