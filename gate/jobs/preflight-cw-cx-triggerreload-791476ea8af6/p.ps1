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

# HELD FIRE AND SHELL RELOADS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  p.reloading=0; p.rlTot=0; p.rlArm=0;
'@ @'
  // v28.xx (cw-cx-triggerreload): a cut keeps shells already loaded and discards only the pending shell clock.
  p.reloading=0; p.rlTot=0; p.rlArm=0; p.shTot=0; p.shN=0; p.shIn=0;
'@

SubRx @'
function tickReload(dt){
  var p=G.player, fx=!G.sim&&RLFX.on&&RLFX.p===p&&RLFX.w===p.wep&&RLFX.tot>0;   // v25.52 (his reload order): this reload has its steps
  if(p.reloading>0){
    p.reloading-=dt*1000;
'@ @'
function tickReload(dt){
  var p=G.player, fx=!G.sim&&RLFX.on&&RLFX.p===p&&RLFX.w===p.wep&&RLFX.tot>0;   // v25.52 (his reload order): this reload has its steps
  // v28.xx (cw-cx-triggerreload), his g-12: "Yes, shell by shell". Keep the full reload time and the existing shellIn schedule; the bot sim stays one go.
  var shell=!G.sim&&p.wep&&gunBase(p.wep.id)==='shotgun';
  if(p.reloading>0){
    if(shell&&(!(p.shTot>0)||p.reloading>p.shTot+1)){ p.shTot=p.reloading; p.shN=rlRounds(p); p.shIn=0; }
    p.reloading-=dt*1000;
    if(shell){
      var shf=1-p.reloading/p.shTot;
      while(p.shIn<p.shN&&shf>=(p.shN>1?0.1+0.75*p.shIn/(p.shN-1):0.45)&&rlRounds(p)>0){ p.ammo++; p.reserve--; p.shIn++; }
    }
'@

SubRx @'
      if(take>0) p.padReloadN=(p.padReloadN||0)+1; // v28.xx (cw-cx-xreloadsearch): completion survives a shot on this frame; cancelled reloads never stamp it.
'@ @'
      // v28.xx (cw-cx-triggerreload): shell reloads also stamp completion after the final pump; a cut never stamps it.
      if(take>0||(shell&&p.shIn>0)) p.padReloadN=(p.padReloadN||0)+1;
      p.shTot=0; p.shN=0; p.shIn=0;
'@

SubRx @'
  } else if(RLFX.on&&RLFX.p===p) rlfxStop();   // v25.52: cut short (a swap, a draw, going down): nothing more plays
'@ @'
  } else {
    // v28.xx (cw-cx-triggerreload): no shell clock survives an ended reload.
    p.shTot=0; p.shN=0; p.shIn=0;
    if(RLFX.on&&RLFX.p===p) rlfxStop();
  }
'@

SubRx @'
  // v28.xx (cw-cx-reloadmedical): a fresh, fireable trigger cuts a partial reload; holding an empty trigger still lets it finish.
  if(hotGun&&mouse.down&&!p.fired&&!p.trigYield&&!p.cooking&&!p.hand&&!(p.drawT>0)&&p.reloading>0&&p.ammo>0&&p.jam<=0&&now-p.lastShot>p.wep.rof*spinMul(p)*pwrRof()&&spinGo(p)) reloadCancel(p);
'@ @'
  // v28.xx (cw-cx-triggerreload), his g-75: "Yes, fire stops it". A fresh loaded pull cuts now; the normal shot clock and MG spin still decide when it fires.
  if(hotGun&&mouse.down&&!p.fired&&!p.trigYield&&!p.cooking&&!p.hand&&!(p.drawT>0)&&p.jam<=0&&p.reloading>0&&p.wep&&p.wep.mag>0&&p.ammo>0) reloadCancel(p);
  // v28.xx (cw-cx-triggerreload): consume a blocked or dry pull during reload, so a held trigger cannot cut when the first shell arrives.
  if(hotGun&&mouse.down&&p.reloading>0&&p.wep&&p.wep.mag>0) p.fired=true;
'@

SubRx @'
    else if(p.ammo>0){
      if(p.wep.auto||!p.fired){
        if(!pwrClip()) p.ammo--; p.lastShot=now; p.fired=true;
        fireWeapon(p,p.wep,p.x+Math.cos(p.face)*100,p.y+Math.sin(p.face)*100,true); lowMagClick(p);   // v36.xx (cw-lowmag): after the shot, p.ammo is what is left
      }
    } else {
'@ @'
    else if(p.ammo>0){
      // v28.xx (cw-cx-triggerreload), his g-15: "Yes, hold to repeat". Magazine guns repeat on their own shot clock; melee, items and dry clicks keep their latches.
      if(!pwrClip()) p.ammo--; p.lastShot=now; p.fired=true;
      fireWeapon(p,p.wep,p.x+Math.cos(p.face)*100,p.y+Math.sin(p.face)*100,true); lowMagClick(p);
    } else {
'@

SubRx @'
var VER='37.69';
'@ @'
var VER='37.70';
'@

$pat = "(?m)^  now:'v37\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.70: Magazine guns repeat at their existing fire rate while held. Shotguns load usable shells at each shell sound and keep their full reload time. A fresh loaded trigger cancels reload before cooldown or MG spin permits firing. Held and dry pulls let the reload finish. Cuts keep loaded shells and lose the active chain. The bot sim stays one go. Check 37.70 fails on v37.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
