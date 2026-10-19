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

# PAD LOST AND PRESS A (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function pollPad(){
'@ @'
// v28.xx (cw-cx-padlost): J8, "pad lost", then "press a"; poll even in the covered window.
function padLostStart(ix){
  if(!G||G.over||G.sim||state!=='raid') return;
  PAD.lossRaid=G; PAD.lossIx=ix;
  if(!PAD.lost||PAD.lost.raid!==G) PAD.lost={raid:G,ix:ix,ready:false};
  padRelease(); PAD.on=false; PAD.mx=0; PAD.my=0; PAD.aiming=false;
  PAD.prev=[]; PAD.mSpent=null; PAD.prevMap=null;
  if(!pauseOpen) togglePauseBox(true);
  var h=document.querySelector('#pausebox h3'); if(h) h.textContent='pad lost';
}
function padLostPoll(gp){
  var live=!!(G&&!G.over&&!G.sim&&state==='raid'), lost=PAD.lost;
  if(!live||PAD.lossRaid!==G){ PAD.lost=null; lost=null; PAD.lossRaid=live?G:null; PAD.lossIx=-1; }
  if(!live) return false;
  if(!lost&&gp&&gp.connected){ PAD.lossIx=gp.index; return false; }
  if(!lost&&PAD.lossIx>=0){ padLostStart(PAD.lossIx); lost=PAD.lost; }
  if(!lost) return false;
  var ready=!!(gp&&gp.connected&&gp.index===lost.ix), b=ready&&gp.buttons&&gp.buttons[0], a=!!(b&&(b.pressed||b.value>0.5));
  lost.ready=ready;
  padRelease(); PAD.mx=0; PAD.my=0; PAD.aiming=false;
  if(!pauseOpen) togglePauseBox(true);
  var h=document.querySelector('#pausebox h3'); if(h) h.textContent=ready?'press a':'pad lost';
  if(a){
    PAD.lost=null; PAD.on=true; PAD.ix=gp.index;
    PAD.prev=[]; PAD.mSpent=[]; PAD.prevMap=null;
    for(var i=0;i<(gp.buttons||[]).length;i++){ var q=gp.buttons[i], down=!!(q&&(q.pressed||q.value>0.35)); PAD.prev[i]=down; PAD.mSpent[i]=down?1:0; }
    indevPadTick(gp); padBodyCls(); togglePauseBox(false);
  }
  return true;
}
function pollPad(){
'@

SubRx @'
  else for(var i=0;i<gps.length;i++){ if(gps[i]&&gps[i].connected){ gp=gps[i]; break; } }
'@ @'
  // v28.xx (cw-cx-padlost): a raid keeps its slot through a gap; another pad cannot resume it.
  else if(G&&PAD.lossRaid===G&&PAD.lossIx>=0) gp=(gps[PAD.lossIx]&&gps[PAD.lossIx].connected)?gps[PAD.lossIx]:null;
  else for(var i=0;i<gps.length;i++){ if(gps[i]&&gps[i].connected){ gp=gps[i]; break; } }
  if(padLostPoll(gp)){ RUMBLE.gp=null; return; }
'@

SubRx @'
  if(typeof G!=='undefined'&&G&&!G.over&&!G.sim&&typeof state!=='undefined'&&state==='raid'){ try{ if(!pauseOpen) togglePauseBox(true); }catch(_pd){} try{ say('CONTROLLER DISCONNECTED','sys',{sub:'RECONNECT TO RESUME'}); }catch(_pd2){} }   // v22.xx (R55): a system label in caps   // v23.xx (tr9fixm): a short detail, never an explaining sentence
'@ @'
  // v28.xx (cw-cx-padlost): the event is a fast path; the polling path does not depend on focus.
  if(typeof G!=='undefined'&&G&&!G.over&&!G.sim&&state==='raid'){ padLostStart(_gi); try{ say('CONTROLLER DISCONNECTED','sys'); }catch(_pd2){} }
'@

SubRx @'
function netPadStick(host,p2){ NET.padWas={pair:NET.pair,host:netPadIxOk(host),p2:netPadIxOk(p2)}; }
'@ @'
// v28.xx (cw-cx-padlost): keep both reservations when one slot is absent; a new pair or an explicit pick clears them as before.
function netPadStick(host,p2){ var w=netPadWasFor(); NET.padWas={pair:NET.pair,host:host>=0?netPadIxOk(host):(w?w.host:-1),p2:p2>=0?netPadIxOk(p2):(w?w.p2:-1)}; }
'@

SubRx @'
  pick=netPadIxOk(pick); taken=netPadIxOk(taken);
'@ @'
  pick=netPadIxOk(pick); taken=netPadIxOk(taken);
  // v28.xx (cw-cx-padlost): a previously played slot stays reserved, including connected:false and null entries.
  var reserved=was?netPadIxOk(side==='p2'?was.p2:was.host):-1;
  if(reserved>=0&&(pick<0||pick===reserved)) return (reserved!==taken&&gps&&gps[reserved]&&gps[reserved].connected)?reserved:-1;
'@

SubRx @'
function netPadWant(){
'@ @'
function netPadWant(){
  // v28.xx (cw-cx-padlost): forwarded input must also respect the reserved slot.
  var w=netPadWasFor(), ix=w?netPadIxOk(NET.same==='p2'?w.p2:w.host):-1;
  if(netPadIxOk(NET.padIx)<0&&ix>=0) return ix;
'@

SubRx @'
  if(!netSamePost({t:'pad',pair:NET.pair,ix:ix,own:NET.padIx,at:netPadIxOk(at),to:(NET.same==='host')?'p2':'host',p:p,v:v,a:a,b:padBrandOf(g)})) return false;
'@ @'
  // v28.xx (cw-cx-padlost): send empty slots too, so a covered window sees loss on the next poll, without waiting for stale input.
  var slots=netPadWasFor(), ownSlot=slots?netPadIxOk(NET.same==='p2'?slots.p2:slots.host):-1;
  if(!netSamePost({t:'pad',pair:NET.pair,ix:ix,own:NET.padIx,at:netPadIxOk(at),to:(NET.same==='host')?'p2':'host',p:p,v:v,a:a,b:padBrandOf(g),slots:slots,lost:ownSlot>=0&&at<0})) return false;
'@

SubRx @'
  if(typeof m.to==='string'&&m.to!==NET.same) return 'padnot';   // v30.xx (cw-p2pads), HIS ORDER (2026-10-18): "my controller controls both screens at the same time, that is not the intent". A state meant for the other player is never played here
'@ @'
  if(typeof m.to==='string'&&m.to!==NET.same) return 'padnot';
  // v28.xx (cw-cx-padlost): the sender reports both reservations and its loss; only the addressed window accepts them.
  if(m.slots&&m.slots.pair===NET.pair) netPadStick(netPadIxOk(m.slots.host),netPadIxOk(m.slots.p2));
  if(typeof m.lost==='boolean') NET.padPeerLost=m.lost;
'@

SubRx @'
    if(other>=0) netPadSend(gps[other],other,mine);
'@ @'
    // v28.xx (cw-cx-padlost): local polling also draws the other pillager loss tag, while this pad keeps running.
    var slots=netPadWasFor(), peerSlot=slots?netPadIxOk(NET.same==='host'?slots.p2:slots.host):-1;
    NET.padPeerLost=peerSlot>=0&&other<0;
    if(other>=0||peerSlot>=0) netPadSend(other>=0?gps[other]:null,other,mine);
'@

SubRx @'
  if(!netPadDead()) return '';
  t='CONTROLLER PAUSED: click one of the game windows';
'@ @'
  // v28.xx (cw-cx-padlost): reuse the existing small HUD plate; the unaffected window keeps its raid running.
  if(NET.padPeerLost&&G&&!G.over&&state==='raid') t=NET.same==='host'?'p2 pad lost':'p1 pad lost';
  else { if(!netPadDead()) return ''; t='CONTROLLER PAUSED: click one of the game windows'; }
'@

SubRx @'
var VER='31.89';
'@ @'
var VER='31.90';
'@

$pat = "(?m)^  now:'v31\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.90: A lost pad pauses its own window. Its slot stays reserved, the other window keeps running with a small loss tag, and physical A resumes when that slot returns. Check 31.90 fails on v31.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
