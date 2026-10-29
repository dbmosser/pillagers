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

# HEALING AND PLATING CANCEL RELOADS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arSetHeldGun(p,w){
'@ @'
// v28.xx (cw-cx-reloadmedical), HIS WORDS 10-28: "a reload cancel kills the reload streak" and "or shooting to reload cxl".
function reloadCancel(p){
  if(!p) return;
  var cut=p.reloading>0;
  p.reloading=0; p.rlTot=0; p.rlArm=0;
  if(G&&!G.sim&&cut){ p.arStk=0; p.arBonus=0; p.arHot=0; p.arGun=null; p.arMul=1; }
  if(G&&!G.sim&&RLFX.p===p) rlfxStop();
}
// v28.xx (cw-cx-reloadmedical), HIS WORDS: "player should not be permitted to apply a bandage and reload at the same ttime; nor apply armor and reload at the same time".
function reloadMedicalBusy(p){ return !!(G&&!G.sim&&p&&(p.prep||p.prepA||(p.healQ||0)>0)); }
function arSetHeldGun(p,w){
'@

SubRx @'
if(p.wep!==w){ p.arStk=0;
'@ @'
if(p.wep!==w){ reloadCancel(p); p.arStk=0;
'@

SubRx @'
function startPrep(kind,key){
'@ @'
function startPrep(kind,key){
  // v28.xx (cw-cx-reloadmedical): every heal/plate door shares this wind-up; stims and the bot sim keep their rules.
  if(!G.sim&&(kind==='heal'||kind==='armor')) reloadCancel(G.player);
'@

SubRx @'
        arSetHeldGun(p,found); p.ammo=(ct&&ct.dropped)?takeRounds(found.id,found.mag):Math.ceil(p.wep.mag/2); p.wepIssued=false; p.wepFromArmory=false; p.reloading=0; p.rlTot=0; p.rlArm=0;   // v13.81; v28.55 (cloud-feel-reload-swap-ring): the reload ring starts over for the gun now in hand
'@ @'
        arSetHeldGun(p,found); p.ammo=(ct&&ct.dropped)?takeRounds(found.id,found.mag):Math.ceil(p.wep.mag/2); p.wepIssued=false; p.wepFromArmory=false; reloadCancel(p);   // v13.81; v28.55 (cloud-feel-reload-swap-ring): the reload ring starts over for the gun now in hand
'@

SubRx @'
    arSetHeldGun(p,p.sec||WEAPONS.fists); p.ammo=p.secAmmo||0; p.wepIssued=!!p.secIssued; p.wepFromArmory=!!p.secFromArmory; p.reloading=0; p.rlTot=0; p.rlArm=0;   // v28.55 (cloud-feel-reload-swap-ring): the reload ring starts over for the gun now in hand
'@ @'
    arSetHeldGun(p,p.sec||WEAPONS.fists); p.ammo=p.secAmmo||0; p.wepIssued=!!p.secIssued; p.wepFromArmory=!!p.secFromArmory; reloadCancel(p);   // v28.55 (cloud-feel-reload-swap-ring): the reload ring starts over for the gun now in hand
'@

SubRx @'
  else { arSetHeldGun(p,g); p.ammo=_rd; p.wepIssued=false; p.wepFromArmory=false; p.reloading=0; p.rlTot=0; p.rlArm=0; }   // v28.55 (cloud-feel-reload-swap-ring): the reload ring starts over for the gun now in hand
'@ @'
  else { arSetHeldGun(p,g); p.ammo=_rd; p.wepIssued=false; p.wepFromArmory=false; reloadCancel(p); }   // v28.55 (cloud-feel-reload-swap-ring): the reload ring starts over for the gun now in hand
'@

SubRx @'
  if(hand){ arSetHeldGun(p,nc); p.ammo=carry; p.wepIssued=false; p.wepFromArmory=false; p.reloading=0; p.rlTot=0; p.rlArm=0; G.tel.weapon=nc.name; }   // v28.55 (cloud-feel-reload-swap-ring): the reload ring starts over for the gun now in hand
'@ @'
  if(hand){ arSetHeldGun(p,nc); p.ammo=carry; p.wepIssued=false; p.wepFromArmory=false; reloadCancel(p); G.tel.weapon=nc.name; }   // v28.55 (cloud-feel-reload-swap-ring): the reload ring starts over for the gun now in hand
'@

SubRx @'
pp.reloading=0; pp.rlTot=0; pp.rlArm=0;
'@ @'
reloadCancel(pp);
'@

SubRx @'
    p.reloading=0;   // v13.83, combat audit: a reload does not wait on the floor to finish after he stands
'@ @'
    reloadCancel(p);   // v28.xx (cw-cx-reloadmedical): going down loses the reload and its chain.
'@

SubRx @'
p.hand={k:k,t:len,len:len,armed:0,used:0,prev:!!mouse.down};
  p.reloading=0;
'@ @'
p.hand={k:k,t:len,len:len,armed:0,used:0,prev:!!mouse.down};
  reloadCancel(p);   // v28.xx (cw-cx-reloadmedical): taking an item out cuts the reload, including its sound and chain.
'@

SubRx @'
p.swapped=false; p.reloading=0; p.jam=0;
'@ @'
p.swapped=false; reloadCancel(p); p.jam=0;
'@

SubRx @'
p.ammo=p.wep.mag; p.reloading=0; p.jam=0;
'@ @'
p.ammo=p.wep.mag; reloadCancel(p); p.jam=0;
'@

SubRx @'
p.roll=.38; p.rollCd=.85;
'@ @'
reloadCancel(p); p.roll=.38; p.rollCd=.85;
'@

SubRx @'
    tickReload(dt);   // v13.83, combat audit: and the reload keeps going through a roll
'@ @'
    reloadCancel(p);   // v28.xx (cw-cx-reloadmedical): a roll loses the reload clock and chain.
'@

SubRx @'
  G.sprinting=sprint;
  // v12.71:
'@ @'
  G.sprinting=sprint;
  if(sprint&&p.reloading>0) reloadCancel(p);   // v28.xx (cw-cx-reloadmedical): sprint cuts the reload before it can finish.
  // v12.71:
'@

SubRx @'
keys['KeyR']&&p.reloading<=0&&!p.hand&&p.ammo<p.wep.mag
'@ @'
keys['KeyR']&&p.reloading<=0&&!p.hand&&!reloadMedicalBusy(p)&&!sprint&&p.ammo<p.wep.mag
'@

SubRx @'
mouse.down&&p.reloading<=0&&!p.hand&&p.wep.mag>0
'@ @'
mouse.down&&p.reloading<=0&&!p.hand&&!reloadMedicalBusy(p)&&!sprint&&p.wep.mag>0
'@

SubRx @'
if(rlHave(p)&&p.reloading<=0&&CFG.autoRel!==0)
'@ @'
if(rlHave(p)&&p.reloading<=0&&!reloadMedicalBusy(p)&&!sprint&&CFG.autoRel!==0)
'@

SubRx @'
  if(mouse.down&&!hotGun&&!p.hand){
'@ @'
  // v28.xx (cw-cx-reloadmedical): a fresh, fireable trigger cuts a partial reload; holding an empty trigger still lets it finish.
  if(hotGun&&mouse.down&&!p.fired&&!p.trigYield&&!p.cooking&&!p.hand&&!(p.drawT>0)&&p.reloading>0&&p.ammo>0&&p.jam<=0&&now-p.lastShot>p.wep.rof*spinMul(p)*pwrRof()&&spinGo(p)) reloadCancel(p);
  if(mouse.down&&!hotGun&&!p.hand){
'@

SubRx @'
var VER='36.48';
'@ @'
var VER='36.49';
'@

$pat = "(?m)^  now:'v36\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.49: Medical use loses the reload clock and chain. R and empty-trigger reloads wait until medical use is done. Firing, rolling, sprinting, changing guns and going down cancel through one door. Check 36.49 fails on v36.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
