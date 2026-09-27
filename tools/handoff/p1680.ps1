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

# THE CONTROLLER FOLLOWS ITS WINDOW, IN FRONT OR NOT (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).

SubRx @'
var NET_PAD_STALE=0.25, NET_PAD_MAX=4;
'@ @'
var NET_PAD_STALE=0.6, NET_PAD_MAX=4, NET_PAD_LIVE=0.15, NET_PAD_DEAD=1.5;   // v16.78: a handed-over state rides out a slow frame on the sender; the live hold spans a frame between two browser samples; the pause word after this long with nothing
'@

SubRx @'
// Called by pollPad with what navigator.getGamepads gave, in a same machine mode only. In front: hands the other window its
'@ @'
// v16.78, HIS ORDER OF 2026-09-27: THE CONTROLLER FOLLOWS ITS WINDOW WHETHER OR NOT THAT WINDOW IS IN FRONT. Liveness is read
// off the DATA and not off focus alone. Chrome feeds the window it holds in front, and a fed window sees the timestamp of a
// connected pad move poll to poll; a window Chrome stopped feeding sees the same timestamps every poll, or no pads at all.
// So a window is live while a connected pad timestamp moved within NET_PAD_LIVE (a hold that rides out a frame between two
// browser samples), or while it is in front. A live window plays its own pad and hands the other window its pad; a window
// that is not live plays the state handed over while it is fresh, and NET_PAD_STALE now rides out a slow frame on the sender.
// Neither window live (he clicked another app, a dialog or the desktop) is the one case a page cannot mend: after
// NET_PAD_DEAD seconds with neither live data nor a fresh state handed over, a window that has played a pad says so on the HUD.
function netPadLive(gps){
  var i, n=(gps&&gps.length)||0, g, ts, now=netPadNow(), moved=false;
  if(!NET.padTs) NET.padTs={};
  for(i=0;i<n&&i<NET_PAD_MAX;i++){
    g=gps[i]; if(!g||!g.connected) continue;
    ts=+g.timestamp; if(!isFinite(ts)) continue;
    if(NET.padTs[i]!==undefined&&ts>NET.padTs[i]) moved=true;
    NET.padTs[i]=ts;
  }
  if(moved) NET.padLiveAt=now;
  return moved||(NET.padLiveAt!==undefined&&(now-NET.padLiveAt)<=NET_PAD_LIVE)||netPadFocused();
}
// What netPadTick hands pollPad, noted: when this window last had a controller (live, or a fresh state handed over), and
// whether it ever played one, so the pause word never shows in a window that never had a pad.
function netPadOut(gp,live){
  if(live||gp) NET.padOkAt=netPadNow();
  if(gp) NET.padHad=true;
  return gp;
}
function netPadDead(){ return !!(NET.same&&NET.padHad&&NET.padOkAt!==undefined&&(netPadNow()-NET.padOkAt)>NET_PAD_DEAD); }
// The one HUD line, on the plate below the message column, in the window whose controller went quiet. It is drawn under the
// message scale (hudZoomIn msg: the monitor, and his own size for that plate), so on every screen it sits under the message
// plate at LH(96)-LH(113) and never across it; a throw after the scale still restores the context. Returns what it drew.
function netPadHud(){
  var t, w;
  if(!netPadDead()) return '';
  t='CONTROLLER PAUSED: click one of the game windows';
  try{
    ctx.save();
    hudZoomIn('msg',W/2,0);
    ctx.font=FS(TYPE.label); ctx.textAlign='center'; w=ctx.measureText(t).width;
    ctx.fillStyle='rgba(6,9,13,.62)'; ctx.fillRect(W/2-w/2-LH(8),LH(120),w+LH(16),LH(17));
    ctx.fillStyle='#ffc04a'; ctx.fillText(t,W/2,LH(133));
    ctx.restore();
  }catch(_e){ try{ ctx.restore(); }catch(_e2){} }
  return t;
}
// Called by pollPad with what navigator.getGamepads gave, in a same machine mode only. Live (v16.78 above): hands the other window its
'@

SubRx @'
  var focused=netPadFocused(), mine, other, fwd=NET.padFwd;
'@ @'
  var focused=netPadLive(gps), mine, other, fwd=NET.padFwd;   // v16.78: live by data or in front, no longer in front alone
'@

SubRx @'
    return (mine>=0)?gps[mine]:null;
'@ @'
    return netPadOut((mine>=0)?gps[mine]:null,true);
'@

SubRx @'
  if(fwd&&fwd.gp&&(netPadNow()-fwd.at)<=NET_PAD_STALE) return fwd.gp;
'@ @'
  if(fwd&&fwd.gp&&(netPadNow()-fwd.at)<=NET_PAD_STALE) return netPadOut(fwd.gp,false);
'@

SubRx @'
  try{ if(NET.on) netPingDraw(); }catch(_npd){}   // v16.43: the party pings
'@ @'
  try{ if(NET.on) netPingDraw(); }catch(_npd){}   // v16.43: the party pings
  try{ if(NET.same) netPadHud(); }catch(_nph){}   // v16.78: the controller paused word, in the window whose pad went quiet
'@

SubRx @'
var VER='16.79';
'@ @'
var VER='16.80';
'@

$pat = "(?m)^  now:'v16\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.80: THE CONTROLLER FOLLOWS ITS WINDOW, IN FRONT OR NOT. His order during his co-op session: the second player controller always controls his window, even when the PC focus leaves that window. The windows now tell a live controller by its data instead of by which window is in front, a slow frame no longer drops the other player controller, and if neither game window gets controller data for a moment the HUD says CONTROLLER PAUSED and where to click. Check 16.80 fails on v16.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
