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

# WHEN THE HOST LEAVES, THE BOXES ARE RIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(i=0;i<g.containers.length;i++){ ct=g.containers[i]; ct.cid=i; ct.netBy=-1; ct.netOpen=ct.opened?1:0; NET.contMap[i]=ct; }
'@ @'
  for(i=0;i<g.containers.length;i++){ ct=g.containers[i]; ct.cid=i; ct.netBy=-1; ct.netOpen=ct.opened?1:0; NET.contMap[i]=ct; ct.netLn=ct.loot?ct.loot.length:0; ct.netPu=ct.pulled|0; ct.netTold=0; ct.netLk=undefined; }
'@

SubRx @'
    ct=G.containers[NET.contN]; ct.cid=NET.contN; if(typeof ct.netBy!=='number') ct.netBy=-1; ct.netOpen=ct.opened?1:0;
'@ @'
    ct=G.containers[NET.contN]; ct.cid=NET.contN; if(typeof ct.netBy!=='number') ct.netBy=-1; ct.netOpen=ct.opened?1:0; ct.netLn=ct.loot?ct.loot.length:0; ct.netPu=ct.pulled|0;
'@

SubRx @'
ib:ct.issuedB?1:0};
'@ @'
ib:ct.issuedB?1:0,lk:netLootList(ct.loot),pl:ct.pulled|0};
'@

SubRx @'
  var i, ct, op, n=0;
  if(!netContHost()) return 0;
  n+=netContNumber();
'@ @'
  var i, ct, op, w, n=0;
  if(!netContHost()) return 0;
  n+=netContNumber();
'@

SubRx @'
      ct.netOpen=op;
      netBroadcast({t:'cont',cid:ct.cid,st:op?'open':'shut',by:(op&&typeof ct.netOpenBy==='number')?ct.netOpenBy:0});
      if(!op) ct.netOpenBy=undefined;
      n++;
    }
'@ @'
      ct.netOpen=op;
      w={t:'cont',cid:ct.cid,st:op?'open':'shut',by:(op&&typeof ct.netOpenBy==='number')?ct.netOpenBy:0};
      if(!op){ ct.netOpenBy=undefined; w.lk=netLootList(ct.loot); w.pl=ct.pulled|0; ct.netTold=1; }   // v20.30 (H22): a restocked box says what it holds now
      netBroadcast(w);
      ct.netLn=ct.loot?ct.loot.length:0; ct.netPu=ct.pulled|0;
      n++;
    } else if(!op&&((ct.loot?ct.loot.length:0)!==ct.netLn||(ct.pulled|0)!==ct.netPu)){
      // v20.30 (H21): a box part searched, by anyone, tells the party what is left in it
      ct.netLn=ct.loot?ct.loot.length:0; ct.netPu=ct.pulled|0; ct.netTold=1;
      netBroadcast(netContLeftWord(ct)); n++;
    }
'@

SubRx @'
  for(i=NET.contN0;i<NET.contN;i++){ ct=NET.contMap[i]; if(ct) netSend(peer,netContNewWord(ct)); }
'@ @'
  for(i=NET.contN0;i<NET.contN;i++){ ct=NET.contMap[i]; if(ct) netSend(peer,netContNewWord(ct)); }
  for(i=0;i<NET.contN0;i++){ ct=NET.contMap[i]; if(ct&&ct.netTold&&!ct.opened) netSend(peer,netContLeftWord(ct)); }   // v20.30 (H21): and what is left in a box from the build that someone part searched or that came back
'@

SubRx @'
    if(ct&&typeof ct.netLeft==='number') ct.netLeft=Math.max(0,ct.netLeft-items.length);   // v16.32: the count on the bar falls as each item comes out
'@ @'
    if(ct&&typeof ct.netLeft==='number') ct.netLeft=Math.max(0,ct.netLeft-items.length);   // v16.32: the count on the bar falls as each item comes out
    if(ct) netLkTake(ct,items);   // v20.30 (H21): and this window remembers what is left in the box, for the day the host is gone
'@

SubRx @'
  if(st==='open'){ netContOpen(ct,by); return 'cont:open'; }
'@ @'
  if(st==='left'){ ct.netLk=netLootKeys(m.lk); ct.netPl=((m.pl|0)>0)?(m.pl|0):0; if(!ct.opened) ct.netLeft=ct.netLk.length; return 'cont:left'; }   // v20.30 (H21)
  if(st==='open'){ netContOpen(ct,by); return 'cont:open'; }
'@

SubRx @'
    ct.opened=false; ct.openedAt=null; ct.prog=0; ct.pulled=0; ct.loot=[]; ct.best='common'; ct.netBy=-1; ct.netCounted=0; ct.netLit=0;
'@ @'
    ct.opened=false; ct.openedAt=null; ct.prog=0; ct.pulled=0; ct.loot=[]; ct.best='common'; ct.netBy=-1; ct.netCounted=0; ct.netLit=0;
    ct.netLk=netLootKeys(m.lk); ct.netPl=((m.pl|0)>0)?(m.pl|0):0; ct.netLeft=ct.netLk.length;   // v20.30 (H22): what the restock put in it
'@

SubRx @'
  if(m.ib) ct.issuedB=1;   // v17.07, co-op hunt 2026-09-28: grantLoot puts it back on this window issued count, as a pile of his own would
'@ @'
  if(m.ib) ct.issuedB=1;   // v17.07, co-op hunt 2026-09-28: grantLoot puts it back on this window issued count, as a pile of his own would
  if(m.lk&&typeof m.lk.length==='number'){ ct.netLk=netLootKeys(m.lk); ct.netPl=((m.pl|0)>0)?(m.pl|0):0; }   // v20.30 (H22): what it holds, never granted from here while the host runs the raid
'@

SubRx @'
// A box the host made, with what the drawing and the reach need; its loot is the host list, never rolled here.
function netContMake(cid,m){
'@ @'
// v20.30, from the whole-game bug hunt of 2026-10-08 (H21, H22): WHEN THE HOST LEAVES, EVERY BOX HOLDS WHAT THE HOST SAID IT HELD.
// When the host's window closed and the other player picked up the raid (his ruling of 2026-10-02), each box went back to this
// window's own copy: a box part searched still held the full list it was built with, so it gave the same items again, and a box
// the host made (a dropped pile, a pillager body, a wreck, the Overseer hoard, a restock) held nothing at all, so a Medkit dropped
// to trade was gone. Now the host tells the party what is left in a box whenever that changes (and the whole list for a box it
// makes or restocks), this window keeps it aside (netLk, never granted from while the host runs the raid), and at the takeover
// every box takes that list, its pulled count, and the bar where it was.
function netLootList(a){ var o=[], i; if(a&&typeof a.length==='number') for(i=0;i<a.length&&i<40;i++) if(typeof a[i]==='string') o.push(a[i]); return o; }
function netLootKeys(a){ var o=[], i, k; if(a&&typeof a.length==='number') for(i=0;i<a.length&&i<40;i++){ k=netClean(a[i],32); if(k&&Object.prototype.hasOwnProperty.call(ITEMS,k)&&ITEMS[k]) o.push(k); } return o; }
function netContLeftWord(ct){ return {t:'cont',cid:ct.cid,st:'left',lk:netLootList(ct.loot),pl:ct.pulled|0}; }
function netLkTake(ct,items){
  var i, j;
  if(!Array.isArray(ct.netLk)){ ct.netLk=(ct.loot||[]).slice(); ct.netPl=ct.pulled|0; }
  for(i=0;i<items.length;i++){ j=ct.netLk.indexOf(items[i]); if(j>=0){ ct.netLk.splice(j,1); ct.netPl=(ct.netPl|0)+1; } }
}
function netBoxMine(ct){
  var tot;
  if(!ct||typeof ct.cid!=='number') return false;
  if(!ct.opened&&Array.isArray(ct.netLk)){
    ct.loot=ct.netLk.slice(); ct.pulled=ct.netPl|0;
    tot=ct.loot.length+ct.pulled;
    ct.prog=(tot>0&&ct.pulled>0)?(ct.time||1)*ct.pulled/tot:0;   // the bar where the last item came out, so the next stage is the next item
    ct.best=bestRarity(ct.loot);
  }
  ct.net=0; ct.netLeft=undefined; ct.netLk=undefined; ct.netBy=-1;
  return true;
}
// A box the host made, with what the drawing and the reach need; its loot is the host list, never rolled here.
function netContMake(cid,m){
'@

SubRx @'
  if(G.searching){ G.searching=null; G.searchT=0; }
  for(_i=G.ents.length-1;_i>=0;_i--){ _e=G.ents[_i]; if(_e&&_e.net)
'@ @'
  if(G.searching){ G.searching=null; G.searchT=0; }
  for(_i=0;_i<G.containers.length;_i++) netBoxMine(G.containers[_i]);   // v20.30 (H21, H22): every box holds what the host last said it held
  for(_i=G.ents.length-1;_i>=0;_i--){ _e=G.ents[_i]; if(_e&&_e.net)
'@

SubRx @'
var VER='20.29';
'@ @'
var VER='20.30';
'@

$pat = "(?m)^  now:'v20\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.30: In co-op, when the host leaves, boxes never give items twice, and dropped piles and bodies keep their items. Check 20.30 fails on v20.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
