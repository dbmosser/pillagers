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

# SOME CRATES ARE MIMICS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function feudFoe(a,b){
'@ @'
// v26.xx (ai27), HIS YES (2026-10-14, suggestion 27): MIMIC CONTAINERS. Now and then (MIMIC_PM in a thousand) a crate or a locker is a
// MIMIC: a dormant crawler lies in it. Which ones are mimics is a pure function of where the box stands and the raid seed (isMimic: a
// hash, no random number drawn), so the raid builds exactly as before and the seeded stream and the container counts do not move. A
// mimic gives itself away to a careful player by a faint tick when you come within 130 of it; start to search it and, 0.8 seconds
// later, the crawler bursts out and goes for you (and, being a crawler, latches on). The box keeps its loot and is searched as normal
// afterward. A box wakes once. The bot sim never wakes one. Its crawler is made on the cosmetic stream (fxBorrow), so no seeded draw moves.
var MIMIC_PM=20;
function isMimic(ct){
  var h;
  if(!ct||typeof G==='undefined'||!G||CFG.mimic===0) return false;
  if(ct.type!=='crate'&&ct.type!=='locker') return false;
  if(ct.dropped||ct.mercSrc||ct.cache||ct.mimicDone) return false;
  h=((Math.round(ct.x)*73856093)^(Math.round(ct.y)*19349663)^(((G.seed|0)+1)*83492791))>>>0;
  h=Math.imul(h^(h>>>15),2246822507)>>>0; h=(h^(h>>>13))>>>0;
  return (h%1000)<MIMIC_PM;
}
function mimicWake(ct){
  var c=null, p=G.player, a=p?Math.atan2(p.y-ct.y,p.x-ct.x):0, x=ct.x+Math.cos(a)*26, y=ct.y+Math.sin(a)*26;
  if(!spotFree(G.map,x,y,12)){ x=ct.x; y=ct.y; }
  fxBorrow(function(){ c=mkCrawler(x,y); });
  c.mimic=1; c.state='chase'; c.alert=3; c.tx=p?p.x:x; c.ty=p?p.y:y;
  G.ents.push(c);
  ct.mimicDone=1; ct.mimicWake=0;
  if(!G.sim){ spark(ct.x,ct.y,'#ff5a40',16,260); G.shake=Math.max(G.shake||0,4); sfx('alarm',ct.x,ct.y,'crawler'); say('MIMIC','warn'); }
  return c;
}
function mimicTick(dt){
  var i, ct, p=G&&G.player;
  if(!G||G.over||G.sim||!G.containers) return;
  for(i=0;i<G.containers.length;i++){
    ct=G.containers[i];
    if(ct.mimicDone||ct.opened) continue;
    if(ct.mim===undefined) ct.mim=isMimic(ct)?1:0;
    if(!ct.mim) continue;
    if(!ct.mimicWake&&(ct.prog||0)>0){ ct.mimicWake=1; ct.mimicT=0.8; }
    if(ct.mimicWake){ ct.mimicT-=dt; if(ct.mimicT<=0) mimicWake(ct); continue; }
    if(p&&!p.downed&&dist(p,ct)<130){
      ct.tkT=(ct.tkT===undefined?fxn(0.4,1.2):ct.tkT)-dt;
      if(ct.tkT<=0){ ct.tkT=fxn(2.0,3.2); if(typeof foley==='function') foley('pinClick',ct.x,ct.y,{g:0.22,rate:1.5}); }
    }
  }
}
function feudFoe(a,b){
'@

SubRx @'
  for(var _rs=0;_rs<G.containers.length;_rs++){
'@ @'
  try{ mimicTick(dt); }catch(_mt){}   // v26.xx (ai27): a mimic crate wakes when searched
  for(var _rs=0;_rs<G.containers.length;_rs++){
'@

SubRx @'
var VER='26.76';
'@ @'
var VER='26.77';
'@

$pat = "(?m)^  now:'v26\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.77: About one crate in fifty is a mimic: a faint tick near it, and a crawler bursts out if you search it. Check 26.77 fails on v26.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
