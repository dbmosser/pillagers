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

# AN ARMOURY GUN DROPPED FOR A TEAMMATE IS IN ONE SAVE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  G.containers.push(c);
  return key;
'@ @'
  G.containers.push(c);
  // v21.95, from the whole-game bug hunt of 2026-10-08 (K5): A HOST'S ARMOURY GUN DROPPED WITH A TEAMMATE UP TOP COMES OFF HIS SAVED
  // LIST. The party can search the pile, and if this window closed before the teammate took the gun (closed by mistake, F5, a crash),
  // the teammate picked up the raid and banked it while the reload put it back in this armoury: one gun in two saves. It comes off
  // the saved list at the drop, as a guest drop does (v21.44). It stays on this raid's list, so an abandon while the window lives
  // still brings it home, and a gun he takes back out of a pile goes on the saved list again (grantLoot). Solo is unchanged.
  if(!G.sim&&typeof NET==='object'&&NET&&NET.on&&NET.role==='host'&&typeof netUpShared==='function'&&netUpShared()&&P&&P.raidSpliced){
    var _hn=0, _hu, _hk=(/^gun_/.test(key)&&ITEMS[key]&&ITEMS[key].gk)?ITEMS[key].gk:null, _hj;
    for(_hu=0;_hu<(NET.up||[]).length;_hu++) if(netUpShown(NET.up[_hu])&&!netUpGone(NET.up[_hu])) _hn++;
    if(_hn&&_hk&&(G.spliced||[]).indexOf(_hk)>=0){ _hj=P.raidSpliced.indexOf(_hk); if(_hj>=0){ P.raidSpliced.splice(_hj,1); try{ saveProfile(); }catch(_hs){} } }
  }
  return key;
'@

SubRx @'
    if(ct.issuedB&&key==='bandage'){ ct.issuedB=0; G.issuedBandages=(G.issuedBandages||0)+1; }   // v13.90: an issued Bandage picked back up is still issued
'@ @'
    if(ct.issuedB&&key==='bandage'){ ct.issuedB=0; G.issuedBandages=(G.issuedBandages||0)+1; }   // v13.90: an issued Bandage picked back up is still issued
    // v21.95 (K5): an armoury gun of his taken back out of a pile (his own drop) is carried again, so a closed window brings it home
    if(!G.sim&&ct.dropped&&itm&&itm.use==='gun'&&itm.gk&&P&&G.spliced&&G.spliced.indexOf(itm.gk)>=0&&(P.raidSpliced||[]).indexOf(itm.gk)<0){ (P.raidSpliced=P.raidSpliced||[]).push(itm.gk); try{ saveProfile(); }catch(_rs){} }
'@

SubRx @'
  c.time=0.6; c.dropped=1; c.dropBy=peer.seat; if(m.ib) c.issuedB=1;
'@ @'
  c.time=0.6; c.dropped=1; c.dropBy=peer.seat; if(m.ib) c.issuedB=1; c.dropPid=(peer.pid||'');   // v21.95 (K5): who dropped it, so a word about it can wait for his next link
'@

SubRx @'
  q=netPeerOfSeat(ct.dropBy); if(!q) return 0;
  for(i=0;i<items.length;i++){ it=ITEMS[items[i]]; if(it&&it.use==='gun'&&it.gk){ netSend(q,{t:'gungone',k:it.gk}); n++; } }
  return n;
}
'@ @'
  // v21.95, from the whole-game bug hunt of 2026-10-08 (K5): A WORD FOR A TEAMMATE WHOSE WINDOW IS GONE WAITS FOR HIS NEXT LINK. When
  // he dropped an armoury gun, abandoned (the gun went home) and closed his window, and then someone took the gun out of his pile,
  // this word had nobody to go to and was dropped, so the gun was in his armoury and in the taker's save. It is kept (NET.gunOwed)
  // with his player id and the raid seed, and sent marked late when he links again (netGunOwedTell); his window acts on it only
  // while it still holds the record of that gun piled in that raid.
  q=netPeerOfSeat(ct.dropBy);
  for(i=0;i<items.length;i++){ it=ITEMS[items[i]]; if(it&&it.use==='gun'&&it.gk){ if(!(q&&netSend(q,{t:'gungone',k:it.gk}))) (NET.gunOwed=Array.isArray(NET.gunOwed)?NET.gunOwed:[]).push({pid:ct.dropPid||'',seat:ct.dropBy,gk:it.gk,sd:NET.upSeed>>>0}); n++; } }
  return n;
}
// v21.95 (K5): THE HOST, as a teammate links: every word about a gun of his that waited for him, marked late, once.
function netGunOwedTell(peer){
  var a=NET.gunOwed, i, e, n=0;
  if(!peer||!Array.isArray(a)||!a.length) return 0;
  for(i=a.length-1;i>=0;i--){
    e=a[i];
    if(!e||!e.gk){ a.splice(i,1); continue; }
    if((e.pid?(e.pid===peer.pid):(e.seat===peer.seat))&&netSend(peer,{t:'gungone',k:e.gk,late:1,sd:e.sd>>>0})){ a.splice(i,1); n++; }
  }
  return n;
}
'@

SubRx @'
  if(typeof G!=='undefined'&&G&&Array.isArray(G.spliced)){ j=G.spliced.indexOf(gk); if(j>=0) G.spliced.splice(j,1); }
'@ @'
  // v21.95 (K5): A LATE WORD (it waited on the host for this link) is about a raid that is over for him. It touches nothing of the raid
  // he may be in now; it acts only when he still holds the record of that gun piled in that raid, and then takes the gun out of his
  // armoury if his abandon put it back there.
  if(m.late){
    var _lp=(P&&Array.isArray(P.gunPiled))?P.gunPiled:[], _li, _le=null, _lsd=(+m.sd)>>>0;
    for(_li=0;_li<_lp.length;_li++) if(_lp[_li]&&_lp[_li].gk===gk&&((_lp[_li].sd>>>0)===_lsd)){ _le=_lp[_li]; _lp.splice(_li,1); break; }
    if(!_le) return 'ignored';
    if(_le.home&&Array.isArray(P.weapons)){ j=P.weapons.indexOf(gk); if(j>=0){ P.weapons.splice(j,1); back=1; } }
    if(back){
      if(P.equipped&&P.equipped!=='fists'&&P.weapons.indexOf(P.equipped)<0) P.equipped=P.weapons.length?P.weapons[0]:'fists';
      if(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists'&&P.weapons.indexOf(P.equippedSec)<0) P.equippedSec='none';
      if((P.equippedSec||'none')===P.equipped) P.equippedSec='none';
    }
    try{ saveProfile(); }catch(_ls){}
    return 'gungone:late';
  }
  if(typeof G!=='undefined'&&G&&Array.isArray(G.spliced)){ j=G.spliced.indexOf(gk); if(j>=0) G.spliced.splice(j,1); }
'@

SubRx @'
      try{ hubDropsTell(peer,false); }catch(_ht){}   // v18.58: and every crate on the floor, dropped before he linked
'@ @'
      try{ hubDropsTell(peer,false); }catch(_ht){}   // v18.58: and every crate on the floor, dropped before he linked
      try{ netGunOwedTell(peer); }catch(_go){}   // v21.95 (K5): and every word about a gun of his that waited for his link
'@

SubRx @'
var VER='21.94';
'@ @'
var VER='21.95';
'@

$pat = "(?m)^  now:'v21\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.95: In co-op, an armoury gun dropped for a teammate no longer ends up in both saves when a window closes. Check 21.95 fails on v21.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
