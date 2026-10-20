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

# NEXT LOADED GUN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function updatePlayer(dt){
'@ @'
// v28.xx (cw-cx-drygun): his 2.58 b: an exhausted gun yields to the next loaded gun, with its name.
function autoEmptyGun(){
  var p=G&&G.player;
  if(!p||G.sim||G.over||G.paused||G.bagOpen||G.mapOpen||G.wheel||G.trade||G.forgeUI||G.searching||p.hand||p.downed||p.dying||p.roll>0||p.reloading>0||p.cooking||!p.wep||p.wep.mag<=0||p.ammo>0||rlHave(p)) return false;
  var sl=hotbarSlots(), start=heldGunCell(sl), i, n, o, q, rounds, id=p.wep.id;
  if(start<0||G.hot!==start) return false;
  for(n=1;n<GUNKEYS;n++){
    i=(start+n)%GUNKEYS; o=gunKeyOcc(sl[i]);
    if(!o||o.gk===id||o.w.mag<=0) continue;
    if(o.where==='sec') rounds=p.secAmmo||0;
    else if(o.where==='bag'){ q=G.stowAmmo&&G.stowAmmo[o.gk]; rounds=q&&q.length?Math.min(o.w.mag,Math.max(0,q[0]|0)):Math.ceil(o.w.mag/2); }
    else continue;
    if(rounds<=0&&(p.reserve||0)<rktCost(o.w)) continue;
    setHot(i);
    if(p.wep.id!==id){ if(o.where!=='bag') say(String(p.wep.name||p.wep.id).toLowerCase(),'info'); return true; }   // v28.xx (cw-cx-drygun): a backpack draw already names the equipped gun once.
  }
  return false;
}
function updatePlayer(dt){
'@

SubRx @'
  tickReload(dt);   // v13.83: also run from the roll branch, so a roll does not freeze it
'@ @'
  tickReload(dt);   // v13.83: also run from the roll branch, so a roll does not freeze it
  autoEmptyGun();   // v28.xx (cw-cx-drygun): the gun yields even when the trigger is released.
'@

SubRx @'
var VER='32.60';
'@ @'
var VER='32.61';
'@

$pat = "(?m)^  now:'v32\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.61: An exhausted gun switches to the next loaded gun on the belt with a short gun-name callout. Check 32.61 fails on v32.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
