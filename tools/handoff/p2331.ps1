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

# ARCADE: EASIER FOR NEWCOMERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function damagePlayer(amt,src,srcName,sx,sy){
  // v21.97 (K7): and on a raid this window joined and took over when the host left
  if(typeof NET==='object'&&NET&&((NET.on&&NET.role==='join')||(typeof G!=='undefined'&&G&&G.netWasJoin))&&isFinite(amt)) amt*=netKidMul();   // v16.44, his order: kid mode, player 2 takes less
'@ @'
// v23.31, HIS ORDER (2026-10-11), build 10 of 20 (arcade10): EASIER FOR NEWCOMERS. In an arcade raid every hit on the player takes
// half (ARCADE_DMG), in both windows; on player 2 it stacks with kid mode, which KID_MIN still floors. A normal raid never reads it.
var ARCADE_DMG=0.5;
function damagePlayer(amt,src,srcName,sx,sy){
  // v21.97 (K7): and on a raid this window joined and took over when the host left
  if(typeof NET==='object'&&NET&&((NET.on&&NET.role==='join')||(typeof G!=='undefined'&&G&&G.netWasJoin))&&isFinite(amt)) amt*=netKidMul();   // v16.44, his order: kid mode, player 2 takes less
  if(typeof G!=='undefined'&&G&&G.arcade&&isFinite(amt)) amt*=ARCADE_DMG;   // v23.31 (arcade10): arcade hits take half
'@

SubRx @'
// A kill this window credited to its own player. Returns the points.
function arcadeKill(k,el,boss){
'@ @'
// v23.31, HIS ORDER (2026-10-11), build 10 of 20 (arcade10): EASIER FOR NEWCOMERS. Every kill this window credits to its own player
// refunds half a magazine of the gun in his hands into his reserve, and every 3rd kill of the run adds a Bandage to the backpack
// while he carries fewer than 5 heals (the pickup stack shows it as KILL BONUS). The drop already gives 6 magazines and full
// armour (arcadeKitApply). Only arcadeKill calls it, which is behind G.arcade, so a normal raid is unchanged.
var ARCADE_HEALS_MAX=5;
function arcadeHealsCarried(){
  var n=0, i, it;
  if(!G||!Array.isArray(G.bag)) return 0;
  for(i=0;i<G.bag.length;i++){ it=ITEMS[G.bag[i]]; if(it&&it.use==='heal') n++; }
  return n;
}
function arcadeKillPerks(){
  var p=G&&G.player, m;
  if(!p||!G.arcade||G.sim||G.over) return;
  m=(p.wep&&p.wep.mag)|0;
  if(m>0) p.reserve=(+p.reserve||0)+Math.ceil(m/2);
  if((ARCADE.kills|0)>0&&(ARCADE.kills|0)%3===0&&ITEMS.bandage&&arcadeHealsCarried()<ARCADE_HEALS_MAX){
    if(!Array.isArray(G.bag)) G.bag=[];
    G.bag.push('bandage');
    try{ say(ITEMS.bandage.name,'pick',{item:'bandage',tag:'KILL BONUS'}); }catch(_sb){}
  }
}
// A kill this window credited to its own player. Returns the points.
function arcadeKill(k,el,boss){
'@

SubRx @'
  ARCADE.mine=(ARCADE.mine|0)+n; ARCADE.kills=(ARCADE.kills|0)+1;
'@ @'
  ARCADE.mine=(ARCADE.mine|0)+n; ARCADE.kills=(ARCADE.kills|0)+1;
  arcadeKillPerks();   // v23.31 (arcade10): half a magazine back, a Bandage every 3rd kill
'@

SubRx @'
var VER='23.30';
'@ @'
var VER='23.31';
'@

$pat = "(?m)^  now:'v23\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.31: In the arcade hits take half, every kill refunds half a magazine and every third kill adds a Bandage up to 5 heals. Check 23.31 fails on v23.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
