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

# Vault guns drop from golden enemies, the Overseer and rarely anywhere (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function goldDrop(x,y){

'@ @'
// v28.xx (cw-vaultdrops), HIS ANSWER (2026-10-18, Q68): "Vault guns also drop from golden enemies and the Overseer, plus a low drop rate anywhere."
// The vault guns are the Longshot, the Meridian Lance and the Rocket Launcher. The golden hoard and the Overseer hoard each hold one more, and any
// kill of a machine or pillager has a small chance (VAULT_RATE, double for a hard one) to leave one. Math.random, so the seeded stream does not move.
var VAULT_GUNS=['gun_sniper','gun_lance','gun_rocket'], VAULT_RATE=0.015;
function vaultGunPick(){ return VAULT_GUNS[Math.floor(Math.random()*VAULT_GUNS.length)]; }
function vaultKillDrop(e){
  if(!e||(G&&G.sim)||e.boss||e.golden||e.merc||e.friendlyPC||e.neutral||e.summoned||e.kind==='warden'||e.kind==='choir'||e.kind==='snitch') return null;
  if(Math.random()>=VAULT_RATE*(isHard(e)?2:1)) return null;
  var c=setLoot(mkContainer(e.x+14,e.y+8,'cache'),[vaultGunPick()]); c.cache=1; c.time=1.6; G.containers.push(c);
  return c;
}
function goldDrop(x,y){

'@

SubRx @'
sideStream(seed,GOLD.tag+2,function(){ c=setLoot(mkContainer(x+16,y+8,'jackpot'),L); });
'@ @'
try{ L.push(vaultGunPick()); }catch(_vg){}   // v28.xx (cw-vaultdrops): a vault gun rides on the golden hoard
  sideStream(seed,GOLD.tag+2,function(){ c=setLoot(mkContainer(x+16,y+8,'jackpot'),L); });
'@

SubRx @'
setLoot(mkContainer(e.x+40,e.y+10,'cache'),['reactor','codex','bloom','titan','coil'])
'@ @'
setLoot(mkContainer(e.x+40,e.y+10,'cache'),['reactor','codex','bloom','titan','coil',vaultGunPick()])
'@

SubRx @'
      if((G.arcade||G.career)&&!G.sim&&(e.byPlayer||e.bySeat>0)){ try{ arcadeKeycardDrop(e); }catch(_akd){} }
'@ @'
      try{ vaultKillDrop(e); }catch(_vkd){}   // v28.xx (cw-vaultdrops): a small chance of a vault gun off any kill
      if((G.arcade||G.career)&&!G.sim&&(e.byPlayer||e.bySeat>0)){ try{ arcadeKeycardDrop(e); }catch(_akd){} }
'@

SubRx @'
var VER='30.25';
'@ @'
var VER='30.26';
'@

$pat = "(?m)^  now:'v30\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.26: Golden enemies and the Overseer now drop a vault gun, and any kill can rarely leave one. Check 30.26 fails on v30.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
