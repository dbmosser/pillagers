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

# A DROPPED ARMOURY GUN COMES HOME UNLESS SOMEONE TAKES IT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      // v20.34, from the whole-game bug hunt of 2026-10-08 (H23): AN ARMOURY GUN DROPPED FOR THE PARTY IS THE PARTY'S NOW. The pile
      // is the host's, so whoever searches it banks the gun, but this window still had the gun on its list of armoury guns carried
      // up, and an abandon put it back in this armoury: one gun in two saves. It comes off the list at the drop, as a gift does.
      var _gk=(/^gun_/.test(key)&&ITEMS[key]&&ITEMS[key].gk)?ITEMS[key].gk:null, _j;
      if(_gk){ _j=(G.spliced||[]).indexOf(_gk); if(_j>=0) G.spliced.splice(_j,1); if(P.raidSpliced){ _j=P.raidSpliced.indexOf(_gk); if(_j>=0) P.raidSpliced.splice(_j,1); } try{ saveProfile(); }catch(_sp){} }
'@ @'
      // v21.21, from the review of the night builds (2026-10-09, R1): an armoury gun dropped here stays on this window's list of guns
      // carried up until someone else takes it out of the pile (netGunTold on the host, netGunGoneTake here). v20.34 took it off at
      // the drop, so a gun nobody took, or one he searched back up himself, was gone from his save after an abandon.
'@

SubRx @'
function grantLoot(ct,keys,delay0){
'@ @'
function grantLoot(ct,keys,delay0){
  try{ if(typeof NET==='object'&&NET&&NET.on&&NET.role==='host') netGunTold(ct,keys,0); }catch(_ngt){}   // v21.21 (R1): the host took a gun out of a pile one of the party dropped
'@

SubRx @'
      netGunsGone(ct,items);   // v17.06, co-op hunt 2026-09-28: a host armoury gun handed over is his no more
'@ @'
      netGunsGone(ct,items);   // v17.06, co-op hunt 2026-09-28: a host armoury gun handed over is his no more
      netGunTold(ct,items,+s);   // v21.21 (R1)
'@

SubRx @'
} else if(items.length){ netGunsGone(ct,items); netSend(q,{t:'loot',cid:r.cid,items:items}); }
'@ @'
} else if(items.length){ netGunsGone(ct,items); netGunTold(ct,items,+s); netSend(q,{t:'loot',cid:r.cid,items:items}); }
'@

SubRx @'
function netGunsGone(ct,items){
  var i, it, j, n=0, back=0;
  if(G.sim||!ct||!ct.dropped||!items||!G.spliced||!G.spliced.length) return 0;
'@ @'
// v21.21, from the review of the night builds (2026-10-09, R1): A GUN TAKEN FROM A PILE ONE OF THE PARTY DROPPED IS TOLD TO HIM. An
// armoury gun he dropped stays on his list of guns carried up (so an abandon brings it home) until someone ELSE takes it out of the
// pile; then the host tells his window, which takes it off the list, as a gift does. If he takes it back himself nothing is said.
function netGunTold(ct,items,taker){
  var i, it, q, n=0;
  if(!ct||typeof ct.dropBy!=='number'||ct.dropBy<=0||ct.dropBy===taker||!items||!items.length) return 0;
  if(typeof G==='undefined'||!G||G.sim||typeof netEntsHost!=='function'||!netEntsHost()) return 0;
  q=netPeerOfSeat(ct.dropBy); if(!q) return 0;
  for(i=0;i<items.length;i++){ it=ITEMS[items[i]]; if(it&&it.use==='gun'&&it.gk){ netSend(q,{t:'gungone',k:it.gk}); n++; } }
  return n;
}
function netGunGoneTake(peer,m){
  var gk, j, back=0;
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  gk=netClean(m.k,24); if(!gk||!WEAPONS[gk]) return 'bad';
  if(typeof G!=='undefined'&&G&&Array.isArray(G.spliced)){ j=G.spliced.indexOf(gk); if(j>=0) G.spliced.splice(j,1); }
  if(P&&Array.isArray(P.raidSpliced)){ j=P.raidSpliced.indexOf(gk); if(j>=0) P.raidSpliced.splice(j,1); }
  // an abandon has already put the list back in his armoury, so the gun comes out of the armoury too (netGunsGone, v17.23)
  if(typeof G!=='undefined'&&G&&G.over==='abandon'&&P&&Array.isArray(P.weapons)){ j=P.weapons.indexOf(gk); if(j>=0){ P.weapons.splice(j,1); back=1; } }
  if(back){
    if(P.equipped&&P.equipped!=='fists'&&P.weapons.indexOf(P.equipped)<0) P.equipped=P.weapons.length?P.weapons[0]:'fists';
    if(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists'&&P.weapons.indexOf(P.equippedSec)<0) P.equippedSec='none';
    if((P.equippedSec||'none')===P.equipped) P.equippedSec='none';
  }
  try{ saveProfile(); }catch(_s){}
  return 'gungone';
}
function netGunsGone(ct,items){
  var i, it, j, n=0, back=0;
  if(G.sim||!ct||!ct.dropped||!items||!G.spliced||!G.spliced.length) return 0;
  if(typeof ct.dropBy==='number'&&ct.dropBy>0) return 0;   // v21.21 (R1): a pile one of the party dropped never holds the host's own armoury gun
'@

SubRx @'
  if(m.t==='mark') return netMarkTake(peer,m);   // v20.38 (H11): a Crier or THE OVERSEER on one of the party, told to his window
'@ @'
  if(m.t==='mark') return netMarkTake(peer,m);   // v20.38 (H11): a Crier or THE OVERSEER on one of the party, told to his window
  if(m.t==='gungone') return netGunGoneTake(peer,m);   // v21.21 (R1): an armoury gun he dropped was taken by someone else
'@

SubRx @'
var VER='21.20';
'@ @'
var VER='21.21';
'@

$pat = "(?m)^  now:'v21\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.21: In co-op, an armoury gun you drop comes home on an abandon unless the other player takes it. Check 21.21 fails on v21.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
