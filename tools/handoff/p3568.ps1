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

# HARDER SETTINGS PAY MORE SP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeKillPts(k,el,boss){ var n=boss?ARCADE_BOSSPTS:(ARCADE_KILLPTS[k]|0); return el?n*(el>1?el:2):n; }   // v26.xx (ai25): an affixed elite passes 3, a plain elite 2
'@ @'
// v35.xx (cw-diffmul), HIS ORDER (2026-10-28): "When the player makes the game harder in any way in the settings (eg number of enemies, number of pillagers, damage
// taken, etc, that should give a score multiplier (maybe an additional 5% for each tier/level) and that should be indicated to the player. Super hot off should be
// considered harder and should also give the multiplier. All these multipliers should stack."
// THE SETTINGS SCORE MULTIPLIER. The Settings rows that make a raid harder, read from the dials they write (a dial moved on the tuning console counts by where it
// stands, and nothing new is saved): pillager bots (Standard 1 step, Many 2, over Few), machines (Standard 1, Many 2, over Few), how hard they hit (Hardened 1,
// Brutal 2, over Standard), heat when you call for extraction (Standard 1, Heavy 2, over Light) and superhot (off is 1 step over on). Each step pays its row's
// DMUL_STEP (5%, one constant a row, to tune) and the rows multiply, so the hardest game pays x1.54. A row set easier than its default pays no less. Not counted:
// raid length (a career and a demo raid run their own 10 minute clock, so the row changes nothing there), how much is out there (it is worth only, read when
// sold, so lean for one raid would cost nothing), fog of war and shared sight (each window's own view, not in the raid word, so two windows would differ).
// A raid takes the rows from the dials it was built with (G.dmul at careerPostBuild and arcadePostBuild, so a linked window builds with the host's dials, as the
// raid word builds the raid), superhot read live (the host word rules it on a linked window). spMul puts it on sp earned: kills (arcadeKillPts, before the
// streak), style medals (scoreBonus), goals, bounty and strongholds (flowChip) and vaults. Never on money, the haul, loot pickups or the loot pot.
// DMUL_ON 0 (the test fixture) pays x1, so the older checks keep their figures.
var DMUL_ON=1, DMUL_STEP={raiders:0.05,robots:0.05,hits:0.05,ext:0.05,superhot:0.05};
function diffTiers(c){
  c=c||CFG||{};
  var n=+c.nRaider||0, s=+c.nSentry||0, d=+c.eDmg||0, v=(c.siegeVol===undefined)?1:(+c.siegeVol||0);
  return {raiders:n>=15?2:(n>=10?1:0), robots:s>=28?2:(s>=20?1:0), hits:d>=1.4?2:(d>=1.2?1:0), ext:v>=1.4?2:(v>=1?1:0), superhot:c.superhot?0:1};
}
// the product of the rows (noSh: all but superhot, which a raid reads live)
function diffMulOf(c,noSh){ var t=diffTiers(c), m=1, k; for(k in DMUL_STEP) if(!(noSh&&k==='superhot')) m*=1+DMUL_STEP[k]*(t[k]|0); return Math.round(m*1e4)/1e4; }
// the multiplier now, to two places: this raid's rows and superhot as it stands; outside a raid, the dials as they stand
function diffMul(){
  if(!DMUL_ON) return 1;
  var b=(typeof G!=='undefined'&&G&&!G.sim&&typeof G.dmul==='number')?G.dmul:diffMulOf(CFG,1), sh=(CFG&&CFG.superhot)?1:1+DMUL_STEP.superhot;
  return Math.max(1,Math.round(b*sh*100)/100);
}
function spMul(n){ var m=diffMul(); return (n>0&&m>1)?Math.round(n*m):n; }
function arcadeKillPts(k,el,boss){ var n=boss?ARCADE_BOSSPTS:(ARCADE_KILLPTS[k]|0); return spMul(el?n*(el>1?el:2):n); }   // v26.xx (ai25): an affixed elite passes 3, a plain elite 2. v35.xx (cw-diffmul): with the settings multiplier in
'@

SubRx @'
  g.cs={s:0,k:0,streak:null,waveT:0,waveN:0};
'@ @'
  g.cs={s:0,k:0,streak:null,waveT:0,waveN:0};
  g.dmul=diffMulOf(CFG,1);   // v35.xx (cw-diffmul): the settings multiplier rows this raid was built with (a linked window builds under the host word)
'@

SubRx @'
  g.arcade=1; g.raidLen=g.timeLeft=ARCADE_RAID_SEC;   // v23.6x (feat0e): the 10 minute DEMO clock
'@ @'
  g.arcade=1; g.raidLen=g.timeLeft=ARCADE_RAID_SEC;   // v23.6x (feat0e): the 10 minute DEMO clock
  g.dmul=diffMulOf(CFG,1);   // v35.xx (cw-diffmul): the settings multiplier rows, as for a career raid (his rule: the demo and career play the same)
'@

SubRx @'
function scoreBonus(n,x,y,txt){
  if(!G||G.sim||G.over||!(n>0)) return 0;
'@ @'
function scoreBonus(n,x,y,txt){
  if(!G||G.sim||G.over||!(n>0)) return 0;
  n=spMul(n);   // v35.xx (cw-diffmul): the settings multiplier
'@

SubRx @'
  if(!scoreBonus(pts,x,y-12,'')) return 0;
'@ @'
  pts=scoreBonus(pts,x,y-12,''); if(!pts) return 0;   // v35.xx (cw-diffmul): the figure paid, settings multiplier in, for the plate and the feed
'@

SubRx @'
function flowChip(n,head,sub){
  var p=G.player;
  if(!(n>0)) return 0;
'@ @'
function flowChip(n,head,sub){
  var p=G.player;
  if(!(n>0)) return 0;
  n=spMul(n);   // v35.xx (cw-diffmul): the settings multiplier
'@

SubRx @'
function arcadeVaultPay(R){
'@ @'
function arcadeVaultPay(R){ return arcadeVaultPayN(R,spMul(ARCADE_VAULT_PAY)); }   // v35.xx (cw-diffmul): the vault pay with the settings multiplier in
function arcadeVaultPayN(R,ARCADE_VAULT_PAY){   // v35.xx (cw-diffmul): the parameter stands in for the constant, so every line below pays and shows the figure paid
'@

SubRx @'
var VER='35.67';
'@ @'
var VER='35.68';
'@

$pat = "(?m)^  now:'v35\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.68: harder settings pay more sp: 5 percent a step on pillagers, machines, how hard they hit and extraction heat, and superhot off, stacked Check 35.68 fails on v35.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
