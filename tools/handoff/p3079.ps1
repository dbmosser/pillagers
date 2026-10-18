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

# PARTY LAUNCH MODE: ONE ADDRESS OPENS BOTH WINDOWS ON THE ATTRACT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var NETP2=!NETSLOT&&netP2Of((typeof location!=='undefined'&&location.search)||'');

'@ @'
var NETP2=!NETSLOT&&netP2Of((typeof location!=='undefined'&&location.search)||'');
// v30.xx (cw-party), HIS Q28 (2026-10-18): "one-click shortcut that opens both windows full screen on attract, with Career and stash out of reach". ?party=1 on
// the address is the party launch mode. Without it nothing below does anything. With it the title is never shown: the host window goes
// straight into the arcade (partyHostBoot), the player 2 window shows its attract at once (partyP2Boot), and the title rows stay hidden by CSS.
function partyOf(q){ return (/[?&]party=1(&|$)/).test(String(q||'')); }
var PARTY=partyOf((typeof location!=='undefined'&&location.search)||''), PARTY_EXIT=0;
if(PARTY){ try{ document.documentElement.classList.add('party'); if(NETP2||netPairOf(location.search)) document.documentElement.classList.add('partyhide'); }catch(_pc){} }

'@

SubRx @'
*{ text-transform:none !important; }

'@ @'
*{ text-transform:none !important; }
/* v30.xx (cw-party), his Q28: in the party launch mode (?party=1) Career, the saves and the stash are out of reach. The windows that go straight to the arcade never show the title at all; a host window with no pair code keeps only the 2 player arcade row. */
html.partyhide #title{ display:none !important; }
html.party #slotpanel, html.party #titlesub, html.party #titlestart, html.party #modecoop, html.party #modearcade1, html.party #modepvp, html.party .modelater, html.party #titleset{ display:none !important; }

'@

SubRx @'
if(typeof NETP2!=='undefined'&&NETP2){
  p2LiveBeat(); try{ setInterval(p2LiveBeat,2000); }catch(_si){}

'@ @'
// v30.xx (cw-party), the stale player 2 marks: a player 2 window killed mid raid leaves salvagerun:p2raid and p2live, and for 75 s the 2 PLAYER row refuses ("still in a raid in the other window"). At a party boot nothing else can be open, so both go before anything reads them.
function partyClearMarks(){ try{ localStorage.removeItem(p2RaidKey()); localStorage.removeItem(p2LiveKey()); }catch(_pm){} return true; }
if(PARTY) partyClearMarks();if(typeof NETP2!=='undefined'&&NETP2){
  p2LiveBeat(); try{ setInterval(p2LiveBeat,2000); }catch(_si){}

'@

SubRx @'
  if(NET.same==='p2'){
    if(m.t==='offer'){

'@ @'
  if(NET.same==='p2'){
    // v30.xx (cw-party): the host window posts hostup at every boot and every 5 s while nobody is linked; a player 2 window that is not linked answers ready, and the old handshake follows (offer, answer, arcon). So a reload of EITHER window finds the pair again with no touch.
    if(m.t==='hostup'){ if(NET.role) return 'ignored'; netPadPost(); netSndPost(); netSamePost({t:'ready',pair:NET.pair}); return 'ready'; }
    if(m.t==='offer'){

'@

SubRx @'
// THE TITLE. Called once at boot with the start the old button runs.
'@ @'
// v30.xx (cw-party), the party launch mode (his Q28, Q30, Q31, Q24 of 2026-10-18). The host window of ?party=1&pair=CODE does what arcadePick does, without
// window.open (the shortcut opens player 2 itself). With no pair code it returns nopair and the title keeps only the 2 player arcade row.
function partyHostUp(){ if(NET.same!=='host'||!NET.pair) return false; if(netInCount()>0) return false; return netSamePost({t:'hostup',pair:NET.pair}); }
function partyHostBoot(q){
  q=(typeof q==='string')?q:((typeof location!=='undefined'&&location.search)||'');
  if(!partyOf(q)) return 'off';
  var pair=netPairOf(q), tl=document.getElementById('title');
  partyClearMarks();
  if(!pair) return 'nopair';
  NET.pair=pair; NET.arcPick=1; NET.mode='coop'; NET.pick='coop'; NET.same='host'; NET.p2win=null;
  if(!NET.role) netStartHost();
  netSameChan(); netPadInit(); netSndInit(); netSameHostLink();
  try{ if(typeof NET.start==='function') NET.start(); }catch(_ns){}
  if(tl) tl.style.display='none';
  if(!arcadeEnter('host')){ partyReload(); return 'fail'; }
  partyHostUp();
  try{ clearInterval(NET.partyT); NET.partyT=setInterval(partyHostUp,5000); }catch(_pi){}
  return 'host';
}
// The player 2 window never shows its title: the arcade attract is up at once (arcon from the host then changes nothing).
function partyP2Boot(r){
  if(!PARTY) return 'off';
  var tl=document.getElementById('title');
  if(tl) tl.style.display='none';
  if(r!=='ready') return 'wait';
  return arcadeEnter('p2')?'arcade':'fail';
}
function partyNav(u){ try{ location.href=u; }catch(_pn){} }
function partyPlainUrl(){ return String(location.href).split('#')[0].split('?')[0]; }
// A reload back into the party attract, at most 4 in 30 s so a build that cannot enter the arcade never spins.
function partyReload(){
  var now=Date.now(), a=[], k='pillagers:partyreloads';
  try{ a=JSON.parse(sessionStorage.getItem(k)||'[]').filter(function(x){ return now-x<30000; }); }catch(_p0){ a=[]; }
  if(a.length>=4) return false;
  a.push(now); try{ sessionStorage.setItem(k,JSON.stringify(a)); }catch(_p1){}
  try{ location.reload(); }catch(_p2){ return false; }
  return true;
}
// The operator's EXIT DEMO (the card row and the chord): in the party launch mode it goes to the same address without ?party, the full title.
function arcadeOpLeave(){
  if(!PARTY) return arcadeLeave();
  PARTY_EXIT=1;
  var r=arcadeLeave();
  partyNav(partyPlainUrl());
  return r;
}// THE TITLE. Called once at boot with the start the old button runs.
'@

SubRx @'
  if(rt) rt.onclick=function(){ if(NET.arcPick) arcadePick(); else netSamePick(NET.pick||'coop'); };

'@ @'
  if(rt) rt.onclick=function(){ if(NET.arcPick) arcadePick(); else netSamePick(NET.pick||'coop'); };
  if(PARTY&&st) st.onclick=function(){ arcadePick(); };   // v30.xx (cw-party): no Career start in the party launch mode
  if(PARTY&&!(typeof NETP2!=='undefined'&&NETP2)){ try{ partyHostBoot(); }catch(_pb){} }

'@

SubRx @'
  r=netSameBootP2();

'@ @'
  r=netSameBootP2();
  if(PARTY){ try{ partyP2Boot(r); }catch(_pp){} }   // v30.xx (cw-party)

'@

SubRx @'
  if(typeof startFn==='function') startFn();
  return 'start';

'@ @'
  if(PARTY&&typeof arcadePick==='function'){ arcadePick(); return 'start'; }   // v30.xx (cw-party): ENTER on a party title is the arcade row, never Career
  if(typeof startFn==='function') startFn();
  return 'start';

'@

SubRx @'
  if(hadRaid){ try{ showScreen('hub'); }catch(_sh2){} }
  return r;

'@ @'
  if(hadRaid){ try{ showScreen('hub'); }catch(_sh2){} }
  if(PARTY&&!PARTY_EXIT) partyReload();   // v30.xx (cw-party): any leave except the operator's EXIT DEMO goes straight back into the party attract (the reload keeps ?party=1), never to the title
  return r;

'@

SubRx @'
  arcadeOpClose();
  arcadeLeave();
  return true;

'@ @'
  arcadeOpClose();
  arcadeOpLeave();   // v30.xx (cw-party)
  return true;

'@

SubRx @'
    arcadeLeave(); return true;

'@ @'
    arcadeOpLeave(); return true;   // v30.xx (cw-party)

'@

SubRx @'
var VER='30.78';
'@ @'
var VER='30.79';
'@

$pat = "(?m)^  now:'v30\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.79: The party shortcut can open both windows on the attract with one address, Career and the stash out of reach, and a reload of either window finds its pair again. Check 30.79 fails on v30.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
