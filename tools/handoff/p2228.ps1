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

# A REFUSED LOANER BANDAGE STAYS A LOANER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(NET.role==='host'){ r=netAidPass(s,NET.seat,PR.key); if(r!=='passed'&&r!=='aid') return kept(' could not take it. '); }
  else for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],{t:'aid',s:s,k:PR.key});
'@ @'
  // v22.28, from the whole-game bug hunt of 2026-10-08 (K41, K42): A LOANER BANDAGE THE TEAMMATE CANNOT TAKE COMES BACK A LOANER. The
  // aid word and the word back now carry the loaner mark (ib) on every leg, so a Bandage his window sends back (he is already healing,
  // he is down, or his raid just ended) goes back on the issued count here, as one kept on this window does (kept, above). It came
  // back as a found Bandage and was banked at the extraction.
  if(NET.role==='host'){ r=netAidPass(s,NET.seat,PR.key,PR.issB?1:0); if(r!=='passed'&&r!=='aid') return kept(' could not take it. '); }
  else for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],{t:'aid',s:s,k:PR.key,ib:PR.issB?1:0});
'@

SubRx @'
}function netAidPass(s,by,key){
  var i;
  if(s===NET.seat) return netAidApply(by,key);
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&NET.peers[i].seat===s) return netSend(NET.peers[i],{t:'aid',s:s,by:by,k:key})?'passed':'lost';
'@ @'
}function netAidPass(s,by,key,ib){   // v22.28 (K41): and the loaner mark
  var i;
  if(s===NET.seat) return netAidApply(by,key,ib);
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&NET.peers[i].seat===s) return netSend(NET.peers[i],{t:'aid',s:s,by:by,k:key,ib:ib?1:0})?'passed':'lost';
'@

SubRx @'
  if(NET.role==='host'){ var r=netAidPass(m.s,peer.seat,netClean(m.k,24)); if(r==='nobody'||r==='lost') netAidBack(peer.seat,netClean(m.k,24),'gone'); return r; }
  if(NET.role==='join'){ if(m.s!==NET.seat) return 'ignored'; return netAidApply((typeof m.by==='number')?(m.by|0):0,netClean(m.k,24)); }
'@ @'
  if(NET.role==='host'){ var r=netAidPass(m.s,peer.seat,netClean(m.k,24),m.ib?1:0); if(r==='nobody'||r==='lost') netAidBack(peer.seat,netClean(m.k,24),'gone',m.ib?1:0); return r; }   // v22.28 (K41): the loaner mark rides along
  if(NET.role==='join'){ if(m.s!==NET.seat) return 'ignored'; return netAidApply((typeof m.by==='number')?(m.by|0):0,netClean(m.k,24),m.ib?1:0); }
'@

SubRx @'
function netAidApply(by,key){
'@ @'
function netAidApply(by,key,ib){   // v22.28 (K41): ib, the loaner mark, goes back with anything refused
'@

SubRx @'
if(it) netAidBack(by,key,'gone'); return 'no raid'; }
'@ @'
if(it) netAidBack(by,key,'gone',ib); return 'no raid'; }
'@

SubRx @'
p=G.player; if(p.downed||p.dying){ netAidBack(by,key,'down'); return 'down'; }
'@ @'
p=G.player; if(p.downed||p.dying){ netAidBack(by,key,'down',ib); return 'down'; }
'@

SubRx @'
if(netAidReach(p)>=healCeil(it)){ netAidBack(by,key,'full'); return 'full'; }
'@ @'
if(netAidReach(p)>=healCeil(it)){ netAidBack(by,key,'full',ib); return 'full'; }
'@

SubRx @'
function netAidBack(by,key,why){
  var i, w={t:'aidx',s:by,f:NET.seat,k:key,w:why};
  if(NET.role==='host'){
    if(by===NET.seat) return netAidKept(NET.seat,key,why);
'@ @'
function netAidBack(by,key,why,ib){
  var i, w={t:'aidx',s:by,f:NET.seat,k:key,w:why,ib:ib?1:0};   // v22.28 (K41): with the loaner mark
  if(NET.role==='host'){
    if(by===NET.seat) return netAidKept(NET.seat,key,why,ib);
'@

SubRx @'
    if(m.s===NET.seat) return netAidKept(peer.seat,k,m.w);
    for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&NET.peers[i].seat===m.s) return netSend(NET.peers[i],{t:'aidx',s:m.s,f:peer.seat,k:k,w:netClean(m.w,8)})?'passed':'lost';
    return 'nobody';
  }
  if(NET.role==='join'){ if(m.s!==NET.seat) return 'ignored'; return netAidKept((typeof m.f==='number')?(m.f|0):0,k,m.w); }
'@ @'
    if(m.s===NET.seat) return netAidKept(peer.seat,k,m.w,m.ib?1:0);   // v22.28 (K41): the loaner mark, on every leg
    for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&NET.peers[i].seat===m.s) return netSend(NET.peers[i],{t:'aidx',s:m.s,f:peer.seat,k:k,w:netClean(m.w,8),ib:m.ib?1:0})?'passed':'lost';
    return 'nobody';
  }
  if(NET.role==='join'){ if(m.s!==NET.seat) return 'ignored'; return netAidKept((typeof m.f==='number')?(m.f|0):0,k,m.w,m.ib?1:0); }
'@

SubRx @'
function netAidKept(from,key,why){
  var it=ITEMS[key], nm=netSeatName(from)||'Your teammate';
  if(!it||(it.use!=='heal'&&it.use!=='armor')) return 'bad';
  if(typeof G==='undefined'||!G||G.over||G.sim||!G.player||!G.bag) return 'no raid';
  G.bag.push(key);
'@ @'
function netAidKept(from,key,why,ib){
  var it=ITEMS[key], nm=netSeatName(from)||'Your teammate';
  if(!it||(it.use!=='heal'&&it.use!=='armor')) return 'bad';
  if(typeof G==='undefined'||!G||G.over||G.sim||!G.player||!G.bag) return 'no raid';
  G.bag.push(key);
  if(ib&&key==='bandage'){ G.issuedBandages=(G.issuedBandages||0)+1; if(G.bandSeen!==undefined) G.bandSeen++; }   // v22.28 (K41): a loaner sent back is still a loaner, as kept() in netAidFinish puts one back
'@

SubRx @'
var VER='22.27';
'@ @'
var VER='22.28';
'@

$pat = "(?m)^  now:'v22\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.28: In co-op, a loaner Bandage your teammate cannot take comes back as a loaner and is not banked. Check 22.28 fails on v22.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
