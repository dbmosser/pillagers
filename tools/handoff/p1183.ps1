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

# HIS SPEC, 2026-09-06 (his 06:26 export, run 4, @204s): "stim injector should
# give unlimited stamina and 1.2 speed boost for 10 seconds". It refilled the
# bar once, which is a bandage for legs. One verb now, two numbers, and the
# stamina and speed lines in updatePlayer read the clock.
SubRx @'
// One action key drives whatever is selected, which is the point of the hotbar.
function useHot(){
'@ @'
// v11.83, HIS SPEC: "stim injector should give unlimited stamina and 1.2 speed
// boost for 10 seconds". STIM_SEC and STIM_SPD are the whole of it: the
// stamina line in updatePlayer holds the bar full while stimT runs and the
// speed line multiplies by STIM_SPD. A second stim while one runs tops the
// clock back up to the full ten rather than stacking. One verb, so any later
// route into a stim uses the same numbers.
var STIM_SEC=10, STIM_SPD=1.2;
function useStim(ix){
  var p=G.player;
  if(ix===undefined||ix<0||G.bag[ix]!=='stim') ix=G.bag.indexOf('stim');
  if(ix<0){ say('No stim.'); return false; }
  G.bag.splice(ix,1);
  p.stam=100; p.stamLock=0; p.stamRelease=0; p.stimT=STIM_SEC;
  blip('pick'); say('Stim. Ten seconds of legs.');
  if(G.tel) G.tel.stims=(G.tel.stims||0)+1;
  return true;
}
// One action key drives whatever is selected, which is the point of the hotbar.
function useHot(){
'@
SubRx @'
    if(ait.use==='stim'){
      var _sp3=G.player;
      if(_sp3.stam>=95){ say('Legs are fresh already.'); return; }
      G.bag.splice(ix,1);
      _sp3.stam=100; _sp3.stamLock=0;
      blip('pick'); say('Stim. The legs come back at once.');
      return;
    }
'@ @'
    if(ait.use==='stim'){ useStim(ix); return; }   // v11.83: ten seconds of legs, see useStim
'@
SubRx @'
  var spd=CFG.pSpeed*armorById(p.rig).spd; if(crouch) spd*=.52; if(sprint) spd*=1.62;
'@ @'
  var spd=CFG.pSpeed*armorById(p.rig).spd; if(crouch) spd*=.52; if(sprint) spd*=1.62;
  if(p.stimT>0) spd*=STIM_SPD;   // v11.83, HIS SPEC: a fifth more while the stim runs
'@
SubRx @'
if(sprint) p.stam=Math.max(0,p.stam-26*dt); else p.stam=Math.min(100,p.stam+7.5*dt);
'@ @'
// v11.83, HIS SPEC: unlimited stamina while the stim runs; the bar is held full
// and the drain below is skipped, so the release latch never arms either.
if(p.stimT>0){ p.stimT-=dt; p.stam=100; if(p.stimT<=0){ p.stimT=0; if(!G.sim) say('The stim wears off.'); } }
else if(sprint) p.stam=Math.max(0,p.stam-26*dt); else p.stam=Math.min(100,p.stam+7.5*dt);
'@
SubRx @'
  if(it.use==='stim') return 'Refills stamina and clears winded.';
'@ @'
  if(it.use==='stim') return 'Ten seconds of unlimited stamina and a fifth more speed.';   // v11.83
'@

# STAMPS.
SubRx @'
var VER='11.82';
'@ @'
var VER='11.83';
'@
SubRx @'
var WHATSNEW_VER='11.82';
'@ @'
var WHATSNEW_VER='11.83';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE STIM INJECTOR IS TEN SECONDS OF LEGS: unlimited stamina and a fifth more speed while it runs.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.82:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.82 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.82:[^']*'",{ param($m) "now:'v11.83: HIS SPEC of 2026-09-06, the stim injector gives unlimited stamina and a 1.2x speed boost for 10 seconds; it used to refill the bar once. useStim sets stimT, the stamina line holds the bar full while it runs, the speed line multiplies by 1.2, and the belt path calls the one verb. Check 11.83 puts a stim on key 3 and uses it through useHot, sprints from an extraction ring along a clear line and requires the bar still full and the distance covered 1.2x the same sprint without the stim; fails on v11.82.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
