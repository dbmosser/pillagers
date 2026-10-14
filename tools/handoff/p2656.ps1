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

# ACTIVE RELOAD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function tickReload(dt){
'@ @'
// v26.xx (feel11), HIS ORDER (2026-10-14): "maybe reload can be a bar that goes halfway with like a sweet spot and if the player hits reload
// again during the sweet spot it adds the damage and finishes the reload instantly - good idea". ACTIVE RELOAD, A BONUS ONLY. The reload ring on
// the cursor now carries a bright SWEET SPOT, the stretch of the reload from AR_A to AR_B of its time. Press R again while the ring is inside it
// (a fresh press: the key was let go since the reload began, so holding R does not count) and the reload finishes at once, the next magazine's
// rounds do AR_BONUS times their damage, and a ping and a green spark say so. Press outside it and nothing happens: the reload goes on at its
// normal speed, with no jam and no penalty. The bonus ends when the magazine runs dry, at the next reload or when you change gun. Live play only
// (G.sim never runs it), and nothing here draws from the seeded stream.
var AR_A=0.42, AR_B=0.60, AR_BONUS=1.15;
function activeReloadTick(p){
  var f;
  if(!G||G.sim||!p||!p.wep) return false;
  if(!(p.reloading>0)){ p.rlTot=0; p.rlArm=0; if(p.arBonus&&(!(p.ammo>0)||p.wep!==p.arGun)) p.arBonus=0; return false; }
  if(!(p.rlTot>0)||p.reloading>p.rlTot+1){ p.rlTot=p.reloading; p.rlArm=keys['KeyR']?0:1; p.arBonus=0; }   // a reload has just begun
  if(!keys['KeyR']){ p.rlArm=1; return false; }
  if(!p.rlArm) return false;
  p.rlArm=0;
  f=1-p.reloading/p.rlTot;
  if(f<AR_A||f>AR_B) return false;
  p.arBonus=1; p.arGun=p.wep;
  p.reloading=1; tickReload(0.002);
  try{ rlfxPing(0); spark(p.x,p.y-14,'#9fe8b0',14,260); label(p.x,p.y-34,'ACTIVE RELOAD','#9fe8b0',0,true); }catch(_ar){}
  return true;
}
function tickReload(dt){
'@

SubRx @'
  // A JAM. The felt consequence of neglect: the trigger does nothing, the gun
'@ @'
  activeReloadTick(p);   // v26.xx (feel11): a second R in the sweet spot finishes the reload
  // A JAM. The felt consequence of neglect: the trigger does nothing, the gun
'@

SubRx @'
dmg:wep.dmg*((sh&&sh.elite)?(CFG.eliteDmg===undefined?1.6:CFG.eliteDmg):1),
'@ @'
dmg:wep.dmg*((sh&&sh.elite)?(CFG.eliteDmg===undefined?1.6:CFG.eliteDmg):1)*((fromPlayer&&!G.sim&&G.player.arBonus>0)?AR_BONUS:1),   // v26.xx (feel11): the active reload bonus
'@

SubRx @'
var _rlf=clamp(1-p.reloading/p.wep.reload,0,1);
'@ @'
var _rlf=clamp(1-p.reloading/((p.rlTot>0)?p.rlTot:p.wep.reload),0,1);   // v26.xx (feel11): of the reload it really began with
'@

SubRx @'
    } else if(rState){
'@ @'
      // v26.xx (feel11): THE SWEET SPOT, a bright stretch of the ring: full while the ring is before it or inside it, dim once it is missed
      ctx.strokeStyle=(_rlf>AR_B)?'rgba(150,240,170,.30)':((_rlf>=AR_A)?'rgba(235,255,240,1)':'rgba(150,240,170,.92)'); ctx.lineWidth=((_rlf>=AR_A&&_rlf<=AR_B)?6.4:5.2)*_wz; ctx.lineCap='butt';
      ctx.beginPath(); ctx.arc(rx0,ry0,_rlr,-1.5708+6.2832*AR_A,-1.5708+6.2832*AR_B); ctx.stroke();
    } else if(rState){
'@

SubRx @'
var VER='26.55';
'@ @'
var VER='26.56';
'@

$pat = "(?m)^  now:'v26\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.56: Press R again in the bright stretch of the reload ring to finish it at once and add 15 percent damage to the next magazine. Check 26.56 fails on v26.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
