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

# HIS ORDER, 2026-09-06: "grenades should have larger explosion radius and do
# more damage". He set the no-balancing-before-alpha rule on 2026-09-04 and has
# overruled it here himself; these are the only dials that move. Radius 150 to
# 190. To an enemy 85 to 115 at the centre falling to 25 at the edge (was 15).
# To him 80 falling to 18 (was 60 and 12): a full-health man at the epicentre
# lives by two points, on purpose, because he died to his own charge twice last
# night and the fuse is still 1.1 s. The wall damage is untouched, but a wider
# radius reaches more wall, which the entry says. The radius is a saved dial, so
# the config version is bumped and a saved profile still on the old default is
# moved, the discipline the cfgv block records.
SubRx @'
smokeR:165,fragR:150,healSolo:1
'@ @'
smokeR:165,fragR:190,healSolo:1
'@
SubRx @'
  var p=G.player,R=(CFG.fragR===undefined?150:CFG.fragR),i;
'@ @'
  // v11.77, HIS ORDER: bigger and harder. 150 to 190, and the two damage lines
  // below moved with it; the saved dial is migrated at cfgv 18.
  var p=G.player,R=(CFG.fragR===undefined?190:CFG.fragR),i;
'@
SubRx @'
    damagePlayer(60*(1-dp/R)+12,_fSrc,_fName,f.x,f.y);
'@ @'
    damagePlayer(80*(1-dp/R)+18,_fSrc,_fName,f.x,f.y);   // v11.77: was 60 and 12; 98 at the centre, so a full man just lives
'@
SubRx @'
      e.hp-=85*(1-Math.max(0,de-e.r)/R)+15; e.hitT=.2;
'@ @'
      e.hp-=115*(1-Math.max(0,de-e.r)/R)+25; e.hitT=.2;   // v11.77: was 85 and 15
'@
SubRx @'
function saveProfile(){ P.cfg=CFG; P.cfgv=17; storeSet(JSON.stringify(P));
'@ @'
function saveProfile(){ P.cfg=CFG; P.cfgv=18; storeSet(JSON.stringify(P));
'@
SubRx @'
if((P.cfgv>=9&&P.cfgv<=17)&&P.cfg){
'@ @'
if((P.cfgv>=9&&P.cfgv<=18)&&P.cfg){
'@
SubRx @'
            if(P.cfgv<17&&P.cfg.simRig==='light') P.cfg.simRig='std';
'@ @'
            if(P.cfgv<17&&P.cfg.simRig==='light') P.cfg.simRig='std';
            // cfgv 18: his order of 2026-09-06, a bigger blast. Only moved off
            // the old default, so a radius he set himself in the console survives.
            if(P.cfgv<18&&P.cfg.fragR===150) P.cfg.fragR=190;
'@

# STAMPS.
SubRx @'
var VER='11.76';
'@ @'
var VER='11.77';
'@
SubRx @'
var WHATSNEW_VER='11.76';
'@ @'
var WHATSNEW_VER='11.77';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'FRAG CHARGES REACH FURTHER AND HIT HARDER. Radius 150 to 190; to a machine or a pillager 115 at the centre, was 85; to you 80 at the centre, was 60. The fuse is still 1.1 seconds.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.76:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.76 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.76:[^']*'",{ param($m) "now:'v11.77: HIS ORDER of 2026-09-06, grenades with a larger radius and more damage. fragR 150 to 190; enemy damage 85 down to 15 becomes 115 down to 25; damage to him 60 down to 12 becomes 80 down to 18, so a full-health man at the epicentre lives by two points because he died to his own charge twice with the fuse still 1.1 s. He overruled his own no-balancing rule for these dials. cfgv 17 to 18 with a migration that moves a saved fragR of 150 to 190 and leaves a hand-set value alone. Check 11.77 reads DEF.fragR, stages a blast a fixed distance from a pillager and requires the loss to match the new formula and exceed the old, and drives the real loader with a cfgv 17 save carrying fragR 150 and requires 190 after load.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
