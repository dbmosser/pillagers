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

# THE HOT GROUND IS SHARED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      try{ tickHot(dt); }catch(e){}
'@ @'
      if(!netEntsPeer()) try{ tickHot(dt); }catch(e){}   // v20.39 (H59): a linked window keeps the hot ground where the host has it (netWorldTake), as it keeps his weather
'@

SubRx @'
  m.sh=CFG.superhot?1:0;   // v16.74, his order: Superhot as the host has it, for the whole party (netShTake on a linked window)
'@ @'
  m.sh=CFG.superhot?1:0;   // v16.74, his order: Superhot as the host has it, for the whole party (netShTake on a linked window)
  if(G.hotZone) m.hz=[Math.round(G.hotZone.x),Math.round(G.hotZone.y),G.hotZone.moves|0];   // v20.39 (H59): the hot ground, for the party
'@

SubRx @'
    if(!G.sim) sfx('charge',S.x,S.y);
  }
  return 'wd';
'@ @'
    if(!G.sim) sfx('charge',S.x,S.y);
  }
  // v20.39, from the whole-game bug hunt of 2026-10-08 (H59): THE HOT GROUND IS THE HOST'S. Each window moved its own disc on its
  // own dice, so after the first move the two maps showed it in different places. It is where the host has it, and a move is
  // said here when the host makes it.
  if(m.hz&&typeof m.hz.length==='number'&&G.hotZone&&isFinite(+m.hz[0])&&isFinite(+m.hz[1])){
    a=G.hotZone; k=m.hz[2]|0;
    a.x=clamp(+m.hz[0],a.r,WORLD_W-a.r); a.y=clamp(+m.hz[1],a.r,WORLD_H-a.r);
    if(k>(a.moves|0)){ a.moves=k; a.at=0; if(!G.sim) say('The hot ground has moved. Check your map.'); }
  }
  return 'wd';
'@

SubRx @'
function netSrchTick(dt){
  var s, r, ct, q, tot, due, k, items, cid, n=0;
'@ @'
// v20.39, from the whole-game bug hunt of 2026-10-08 (H59): AND A BOX ONE OF THE PARTY EMPTIES ON THE HOT GROUND PAYS ITS BONUS. The
// two extra items an open on the hot ground adds were rolled only for the host's own open, so the disc on player 2's map never
// paid him. The host rolls them here, for the box the party member searched, and they come out with the last of it.
function netHotBonus(ct){
  var out=[], i, k, H=G.hotZone;
  if(!H||!ct||ct.cache||ct.dropped||ct.hotPaid) return out;
  if(Math.hypot(ct.x-H.x,ct.y-H.y)>H.r) return out;
  for(i=0;i<2;i++){ k=rollLoot(LOOT.safe); if(k) out.push(k); }
  ct.hotPaid=1;
  return out;
}
function netSrchTick(dt){
  var s, r, ct, q, tot, due, k, items, cid, hot, n=0;
'@

SubRx @'
      items=items.concat(ct.loot); ct.pulled=(ct.pulled||0)+ct.loot.length; ct.loot=[]; ct.best='common';
'@ @'
      items=items.concat(ct.loot); ct.pulled=(ct.pulled||0)+ct.loot.length; ct.loot=[]; ct.best='common';
      hot=netHotBonus(ct); if(hot.length) items=items.concat(hot);   // v20.39 (H59)
'@

SubRx @'
netSend(q,{t:'loot',cid:r.cid,items:items,done:1});
'@ @'
netSend(q,{t:'loot',cid:r.cid,items:items,done:1,hot:hot.length?1:0});
'@

SubRx @'
    if(ct) netContOpen(ct,NET.seat);
'@ @'
    if(m.hot===1){ if(T) T.hotOpened=(T.hotOpened||0)+1; if(!G.sim) sayWhenFree('Hot ground. Extra loot in here.'); }   // v20.39 (H59): the bonus the host rolled for this search
    if(ct) netContOpen(ct,NET.seat);
'@

SubRx @'
var VER='20.38';
'@ @'
var VER='20.39';
'@

$pat = "(?m)^  now:'v20\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.39: In co-op, both players see the hot ground in the same place, and both get its extra loot. Check 20.39 fails on v20.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
