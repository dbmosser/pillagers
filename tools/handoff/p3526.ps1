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

# MORE AMMO WHEN YOU RUN DRY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function ammoTell(ct){
'@ @'
// v35.xx (cw-ammoneed), HIS ORDER (2026-10-27): "player should have higher chance of finding ammo boxes if player has no ammo".
// A box rolls its loot at the build, so the help is decided the moment a pillager with no ammo first searches it: a crate, locker,
// body or wreck (any box whose LOOT table can hold an ammo box) that holds none gets one on AMMO_NEED.ch of boxes. That takes the
// chance a box holds ammo from about 21 to 68 percent on a crate, 22 to 69 on a locker, 29 to 72 on a body and 45 to 78 on a wreck.
// No ammo means nothing left to reload with: no rounds in the pool (not one rocket for the launcher) and no ammo box in the backpack.
// The roll is a hash of the raid seed and the box, never a draw on the seeded stream, so the seed 4242 build and the raid after it
// come out the same; it is decided once per box, and nothing is taken out of the box. In co-op the host decides for whoever opens
// it: the window of player 2 says dry in its search request, from its own pillager.
var AMMO_NEED={ch:0.6,tag:0x414d};
function ammoDry(p,bag){
  if(!p) return false;
  if((+p.reserve||0)>=rktCost(p.wep)) return false;
  for(var i=0;bag&&i<bag.length;i++){ var it=ITEMS[bag[i]]; if(it&&it.use==='ammo') return false; }
  return true;
}
function ammoNeedRoll(ct){
  var h=(((G&&G.seed)>>>0)^Math.imul(AMMO_NEED.tag,0x9E3779B1))>>>0;
  h=(h^Math.imul(Math.round(ct.x)|0,374761393))>>>0;
  h=(h^Math.imul(Math.round(ct.y)|0,668265263))>>>0;
  h=Math.imul(h^(h>>>15),2246822519)>>>0;
  h=Math.imul(h^(h>>>13),3266489917)>>>0;
  return ((h^(h>>>16))>>>0)/4294967296;
}
function ammoNeed(ct,dry){
  if(!dry||!ct||ct.opened||ct.ammoNeed||ct.pulled||ct.mercSrc||ct.dropped||!ct.loot) return false;
  var t=LOOT[ct.type], ok=false, i, it;
  for(i=0;t&&i<t.length;i++){ it=ITEMS[t[i][0]]; if(it&&it.use==='ammo') ok=true; }
  if(!ok) return false;
  ct.ammoNeed=1;   // once per box: stepping off and back on rolls nothing new
  for(i=0;i<ct.loot.length;i++){ it=ITEMS[ct.loot[i]]; if(it&&it.use==='ammo') return false; }
  if(ammoNeedRoll(ct)>=AMMO_NEED.ch) return false;
  setLoot(ct,ct.loot.concat(['ammobox']));
  return true;
}
function ammoTell(ct){
'@

SubRx @'
searchFoley(near,'rummage');   // v25.30 (usefoleyg): hands in the box
'@ @'
ammoNeed(near,ammoDry(G.player,G.bag));   // v35.xx (cw-ammoneed): a pillager with no ammo is more likely to find an ammo box
        searchFoley(near,'rummage');   // v25.30 (usefoleyg): hands in the box
'@

SubRx @'
if(q) netSend(q,{t:'srch',op:'start',cid:cid,slow:+(+buzzSlow()).toFixed(3)});
'@ @'
if(q) netSend(q,{t:'srch',op:'start',cid:cid,slow:+(+buzzSlow()).toFixed(3),dry:ammoDry(G.player,G.bag)?1:0});   // v35.xx (cw-ammoneed): dry, his own ammo
'@

SubRx @'
NET.holds[s]={cid:cid,slow:slow}; ct.netBy=s;
'@ @'
NET.holds[s]={cid:cid,slow:slow}; ct.netBy=s;
  if(m.dry) ammoNeed(ct,1);   // v35.xx (cw-ammoneed): player 2 has no ammo, so the host rolls the help for his box
'@

SubRx @'
var VER='35.25';
'@ @'
var VER='35.26';
'@

$pat = "(?m)^  now:'v35\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.26: more ammo boxes when you run dry Check 35.26 fails on v35.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
