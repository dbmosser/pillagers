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

# THE PAIR SHARES ITS MARKS AND SETTINGS INSIDE ITCH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function p2LiveBeat(){ try{ localStorage.setItem(p2LiveKey()
'@ @'
function p2LiveBeat(){ try{ netBeatPost(); }catch(_nb){} try{ localStorage.setItem(p2LiveKey()
'@

SubRx @'
function p2RaidNow(){ var t=0; try{ t=+localStorage.getItem(p2RaidKey())||0; }catch(_g){ t=0; }
'@ @'
function p2RaidNow(){ var t=0; try{ t=+localStorage.getItem(p2RaidKey())||0; }catch(_g){ t=0; } try{ t=Math.max(t,(NET.mateBeat&&NET.mateBeat.raid)||0); }catch(_gm){}   /* v33.58 (cw-p2marks): in itch frame player 2 marks come over the bridge, not this store */
'@

SubRx @'
function p2LiveNow(){ var t=0; try{ t=+localStorage.getItem(p2LiveKey())||0; }catch(_g){ t=0; }
'@ @'
function p2LiveNow(){ var t=0; try{ t=+localStorage.getItem(p2LiveKey())||0; }catch(_g){ t=0; } try{ t=Math.max(t,(NET.mateBeat&&NET.mateBeat.live)||0); }catch(_gm){}
'@

SubRx @'
NET.p2win=null; NET.sameBusy=false; NET.sameT0=0; NET.noLink=0;
'@ @'
NET.p2win=null; NET.sameBusy=false; NET.sameT0=0; NET.noLink=0; NET.brKv={}; NET.brKvT=0;
'@

SubRx @'
function netMateTick(dt){ try{ netSameWatch(Date.now()); }catch(_nw){}
'@ @'
function netMateTick(dt){ try{ netSameWatch(Date.now()); }catch(_nw){} try{ netBridgeTick(Date.now()); }catch(_nbt){}   // v33.58 (cw-p2marks): the shared settings ride the same frame tick
'@

SubRx @'
  if(!NET.same||!NET.pair||m.pair!==NET.pair) return 'ignored';
'@ @'
  if(!NET.same||!NET.pair||m.pair!==NET.pair) return 'ignored';
  if(m.t==='kv') return netBridgeKv(m);   // v33.58 (cw-p2marks): a shared setting from the other window, bridge only
'@

SubRx @'
netSndPost();   // v15.78: and whether this window's sound is on
'@ @'
netSndPost();   // v15.78: and whether this window's sound is on
      if(NET.bc&&NET.bc.br) netBridgeKvAll();   // v33.58 (cw-p2marks): on the bridge the host shared settings go out when the pair links, so the host values win
'@

SubRx @'
  if(!NET.bc||!NET.bc.br) return 'off';
  if(!d||typeof d!=='object'||d.pg!=='pillagers'||!m||typeof m!=='object') return 'bad';
  if(e.origin!==location.origin) return 'origin';

'@ @'
  if(!d||typeof d!=='object'||d.pg!=='pillagers'||!m||typeof m!=='object') return 'bad';
  if(e.origin!==location.origin) return 'origin';
  if(m.t==='beat') return netBeatIn(src,m);   // v33.58 (cw-p2marks): pair free, taken before any pick, so a reloaded frame finds the popup again
  if(!NET.bc||!NET.bc.br) return 'off';

'@

SubRx @'
function netBridgeIn(e){
'@ @'
// v33.58 (cw-p2marks), coord-06 (2026-10-21): THE MARKS AND THE SHARED SETTINGS ACROSS THE TWO STORES. In itch frame player 1 and player 2 keep
// separate stores, so the p2live and p2raid marks never reached player 1 and the v20.35 refusal (never open a window over a live raid) could not
// fire. Player 2 now posts a beat to its opener every 2 s (raid 0 or 1); the host keeps it in memory (NET.mateBeat) and p2RaidNow and p2LiveNow read
// the newer of storage and memory. Saves and slot pointers are NOT shared, so two windows can never open the same save. The three settings the pair
// shares (who hears the world, split speakers, the kid settings) are compared once a second on the bridge and posted when one changes.
function netBrKeys(){ return [NET_WHO_KEY,NET_SPLIT_KEY,KID_SHARE_KEY]; }
function netBeatPost(q){
  var o=(typeof q==='string')?q:((typeof location!=='undefined'&&location.search)||''), w=null, raid;
  if(!netEmbOf(o)) return false;
  try{ w=window.opener; }catch(_bp){ w=null; }
  if(!w) return false;
  raid=(typeof G!=='undefined'&&G&&!G.sim&&!G.over)?1:0;
  try{ w.postMessage({pg:'pillagers',m:{t:'beat',raid:raid}},location.origin); return true; }catch(_bq){ return false; }
}
function netBeatIn(src,m){
  var now=Date.now();
  if(typeof NETP2!=='undefined'&&NETP2) return 'off';
  try{ if(!reportEmbedded()) return 'off'; }catch(_bi){ return 'off'; }
  if(!src) return 'source';
  if(NET.p2win&&!NET.p2win.closed&&src!==NET.p2win) return 'source';
  NET.p2win=src;
  NET.mateBeat={live:now,raid:m.raid?now:0};
  return 'beat';
}
function netBridgeKvAll(){
  var ks=netBrKeys(), i, v, n=0;
  for(i=0;i<ks.length;i++){ v=null; try{ v=localStorage.getItem(ks[i]); }catch(_ka){ v=null; } if(typeof v==='string'){ if(!NET.brKv) NET.brKv={}; NET.brKv[ks[i]]=v; netSamePost({t:'kv',pair:NET.pair,k:ks[i],v:v}); n++; } }
  return n;
}
function netBridgeTick(now){
  if(!NET.bc||!NET.bc.br||!NET.pair) return 'off';
  if(!NET.brKv) NET.brKv={};
  if(NET.brKvT&&now-NET.brKvT<1000) return 'wait';
  NET.brKvT=now;
  var ks=netBrKeys(), i, v, n=0;
  for(i=0;i<ks.length;i++){
    v=null; try{ v=localStorage.getItem(ks[i]); }catch(_kt){ v=null; }
    if(!(ks[i] in NET.brKv)){ NET.brKv[ks[i]]=v; continue; }
    if(v!==NET.brKv[ks[i]]){ NET.brKv[ks[i]]=v; if(typeof v==='string'){ netSamePost({t:'kv',pair:NET.pair,k:ks[i],v:v}); n++; } }
  }
  return n;
}
function netBridgeKv(m){
  if(!NET.bc||!NET.bc.br) return 'ignored';
  if(netBrKeys().indexOf(m.k)<0||typeof m.v!=='string'||m.v.length>400) return 'ignored';
  try{ localStorage.setItem(m.k,m.v); }catch(_kw){}
  if(!NET.brKv) NET.brKv={};
  NET.brKv[m.k]=m.v;
  if(m.k===KID_SHARE_KEY){ try{ if(kidSync(m.v)){ var sm=document.getElementById('settingsmodal'); if(sm&&sm.classList.contains('on')) renderSettings(); } }catch(_kk){} }
  else { try{ netSndApply(); renderParty(); }catch(_kn){} }
  return 'kv';
}
function netBridgeIn(e){
'@

SubRx @'
var VER='33.60';
'@ @'
var VER='33.61';
'@

$pat = "(?m)^  now:'v33\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.61: On itch, player 1 is told when player 2 is in a raid, and the shared sound and kid settings follow in both windows. Check 33.61 fails on v33.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
