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

# VOICE. Multiplayer, his rulings of 2026-09-25 (push-to-talk and open mic, per-teammate mute); plan.md build 3, net.md section 4.

SubRx @'
    peer.fc.onmessage=function(ev){ netOnMsg(peer,ev.data); };
  }catch(e){ peer.fc=null; }
'@ @'
    peer.fc.onmessage=function(ev){ netOnMsg(peer,ev.data); };
  }catch(e){ peer.fc=null; }
  // v16.09: THE VOICE LINE. The host puts one audio line on every link when it is made, so the mic can be switched on later with
  // no second code: the invite code carries it. The joiner takes the line the offer made (netJoin). What arrives is played
  // through its own audio element and context (voiceAttach).
  if(NET.role==='host'){ try{ peer.at=pc.addTransceiver('audio',{direction:'sendrecv'}); }catch(e4){ peer.at=null; } }
  pc.ontrack=function(ev){ try{ voiceAttach(peer,(ev.streams&&ev.streams[0])||new MediaStream([ev.track])); }catch(e5){} };
'@

SubRx @'
      .then(function(){ return peer.pc.createAnswer(); })
'@ @'
      .then(function(){ peer.at=voiceLineOf(peer); if(peer.at){ try{ peer.at.direction='sendrecv'; }catch(_vd){} } return peer.pc.createAnswer(); })   // v16.09: the voice line the host offered, both ways
'@

SubRx @'
  netClearTimers(peer); peer.state='gone';
'@ @'
  netClearTimers(peer); peer.state='gone';
  try{ voiceDetach(peer); }catch(e6){}   // v16.09: his voice goes with the link
'@

SubRx @'
function netReset(keepErr){
  var ps=NET.peers.slice(), i;
'@ @'
function netReset(keepErr){
  var ps=NET.peers.slice(), i;
  try{ voiceMicOff(); }catch(_vm){}   // v16.09: the mic is let go with the party
'@

SubRx @'
  netClearTimers(peer);
  peer.state='open';
'@ @'
  netClearTimers(peer);
  peer.state='open';
  try{ if(NET.micTrack) voiceSend(peer); }catch(_vs){}   // v16.09: a mic already on reaches a link made after it
'@

SubRx @'
    <span id="partysndnote" style="margin-left:10px;color:var(--ash)"></span>
  </div>
'@ @'
    <span id="partysndnote" style="margin-left:10px;color:var(--ash)"></span>
  </div>
  <!-- v16.09: voice. The mic is asked for only when MIC is pressed. -->
  <div class="msub" id="partyvoice" style="display:none">
    <button id="partymicbtn" style="padding:6px 16px">MIC: OFF</button>
    <button id="partymicmode" style="padding:6px 16px;margin-left:8px">HOLD Y TO TALK</button>
    <span id="partyvoicenote" style="margin-left:10px;color:var(--ash)"></span>
  </div>
'@

SubRx @'
  sb.style.display=role?'none':'flex';
'@ @'
  var vr=g('partyvoice');   // v16.09: the voice row, for a party linked by code (a same machine pair shares one room already)
  if(vr){ vr.style.display=(role&&!NET.same)?'':'none';
    if(g('partymicbtn')) g('partymicbtn').textContent=NET.micTrack?'MIC: ON':'MIC: OFF';
    if(g('partymicmode')) g('partymicmode').textContent=(NET.micMode==='open')?'OPEN MIC':'HOLD Y TO TALK';
    if(g('partyvoicenote')) g('partyvoicenote').textContent=NET.micTrack?((NET.micMode==='open')?'Everyone linked hears you. Wear a headset.':'Hold Y to talk. Wear a headset.'):'Press MIC to talk to your party. The browser asks first.'; }
  sb.style.display=role?'none':'flex';
'@

SubRx @'
    row.appendChild(nm); ro.appendChild(row);
'@ @'
    row.appendChild(nm);
    if(r[i].seat!==NET.seat&&r[i].pid&&!NET.same){   // v16.09: each teammate's voice can be muted here, on this PC only
      var mb=document.createElement('button'); mb.style.cssText='padding:2px 10px;margin-left:10px';
      mb.textContent=(P.netMute&&P.netMute[r[i].pid])?'UNMUTE':'MUTE'; mb.setAttribute('data-mute',r[i].pid);
      mb.onclick=(function(pid){ return function(){ voiceMute(pid); renderParty(); }; })(r[i].pid);
      row.appendChild(mb);
    }
    ro.appendChild(row);
'@

SubRx @'
  if(g('partysndbtn')) g('partysndbtn').onclick=function(){ netSndToggle(); };   // v15.78: the SOUND row
'@ @'
  if(g('partysndbtn')) g('partysndbtn').onclick=function(){ netSndToggle(); };   // v15.78: the SOUND row
  if(g('partymicbtn')) g('partymicbtn').onclick=function(){ if(NET.micTrack){ voiceMicOff(); renderParty(); } else netUi(function(){ return voiceMicOn(); },'Asking the browser for the microphone.'); };   // v16.09
  if(g('partymicmode')) g('partymicmode').onclick=function(){ NET.micMode=(NET.micMode==='open')?'ptt':'open'; voiceGate(); renderParty(); };   // v16.09
'@

SubRx @'
function netEntsHost(){
'@ @'
// v16.09, MULTIPLAYER: VOICE (his rulings of 2026-09-25: push-to-talk and open mic, with per-teammate mute; tools/multiplayer
// plan.md build 3 and net.md section 4). The mic is asked for only when MIC is pressed in the PARTY window, never at load. Hold Y
// to talk (Y has no other use), or OPEN MIC; a window with a controller in use starts on open mic, since a pad has no free
// button. Each link carries one audio line from the moment it is made (netPeerNew), so switching the mic on sends the track down
// every link with no new code (voiceSend). What arrives plays through a muted audio element (Chromium sends Web Audio silence
// without one) into a context of the voice's own (VAC), so the game pausing its own sound when the page hides never cuts a
// friend off. MUTE beside a name in the roster sets that voice to nothing on this PC only, kept in the save under his player id.
// In this first version the host hears everyone and each friend hears the host; friends in a party of three or four do not
// yet hear each other, which needs the host to relay. Solo play never touches any of it.
var VAC=null, VAC_C=(typeof window!=='undefined')?(window.AudioContext||window.webkitAudioContext||null):null;   // the constructor as the page loaded it (the silent test fixture replaces it later, at boot; a voice step in the live test is opt-in)
function voiceCtx(){
  if(!VAC){ try{ VAC=VAC_C?new VAC_C():null; }catch(e){ VAC=null; } }
  if(VAC&&VAC.state==='suspended'){ try{ VAC.resume(); }catch(e2){} }
  return VAC;
}
function voiceLineOf(peer){
  var t=(peer&&peer.pc&&peer.pc.getTransceivers)?peer.pc.getTransceivers():[], i;
  for(i=0;i<t.length;i++) if(t[i].receiver&&t[i].receiver.track&&t[i].receiver.track.kind==='audio') return t[i];
  return null;
}
function voiceSend(peer){
  var tr=(peer&&peer.at)||voiceLineOf(peer);
  if(!tr||!tr.sender) return false;
  try{ tr.sender.replaceTrack(NET.micTrack||null); }catch(e){ return false; }
  return true;
}
function voiceGate(){ if(NET.micTrack) NET.micTrack.enabled=(NET.micMode==='open')||!!NET.ptt; return NET.micTrack?NET.micTrack.enabled:false; }
function voiceMicOn(){
  var md=(typeof navigator!=='undefined')?navigator.mediaDevices:null;
  if(NET.micTrack) return Promise.resolve(true);
  if(!md||typeof md.getUserMedia!=='function') return Promise.resolve({err:'This browser cannot use a microphone here.'});
  NET.micAsks=(NET.micAsks||0)+1;
  if(!NET.micMode) NET.micMode=(typeof PAD!=='undefined'&&PAD&&PAD.on)?'open':'ptt';
  return md.getUserMedia({audio:{echoCancellation:true,noiseSuppression:true,autoGainControl:true}}).then(function(s){
    var i;
    NET.micStream=s; NET.micTrack=(s&&s.getAudioTracks)?(s.getAudioTracks()[0]||null):null;
    if(!NET.micTrack) return {err:'The browser gave no microphone.'};
    voiceGate();
    for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'||NET.peers[i].state==='open') voiceSend(NET.peers[i]);
    NET.status=(NET.micMode==='open')?'Mic on. Everyone linked hears you.':'Mic on. Hold Y to talk.';
    return true;
  },function(e){ return {err:'The microphone was not allowed ('+netErrText(e)+'). Emotes still work.'}; });
}
function voiceMicOff(){
  var i, t=NET.micStream&&NET.micStream.getTracks?NET.micStream.getTracks():[];
  for(i=0;i<t.length;i++){ try{ t[i].stop(); }catch(e){} }
  NET.micStream=null; NET.micTrack=null; NET.ptt=false;
  for(i=0;i<NET.peers.length;i++) voiceSend(NET.peers[i]);
  return true;
}
function voiceVol(peer){ if(peer&&peer.vGain&&peer.vGain.gain) peer.vGain.gain.value=(P&&P.netMute&&peer.pid&&P.netMute[peer.pid])?0:1; }
function voiceAttach(peer,stream){
  var ac=voiceCtx(), el;
  if(!ac||!stream) return false;
  voiceDetach(peer);
  el=document.createElement('audio'); el.muted=true; el.autoplay=true; el.style.display='none'; el.srcObject=stream;
  document.body.appendChild(el); try{ var pp=el.play(); if(pp&&pp.catch) pp.catch(function(){}); }catch(e){}
  peer.vEl=el; peer.vSrc=ac.createMediaStreamSource(stream); peer.vGain=ac.createGain();
  peer.vSrc.connect(peer.vGain); peer.vGain.connect(ac.destination);
  voiceVol(peer);
  return true;
}
function voiceDetach(peer){
  try{ if(peer.vSrc) peer.vSrc.disconnect(); }catch(e){} try{ if(peer.vGain) peer.vGain.disconnect(); }catch(e2){}
  try{ if(peer.vEl){ peer.vEl.srcObject=null; if(peer.vEl.parentNode) peer.vEl.parentNode.removeChild(peer.vEl); } }catch(e3){}
  peer.vEl=null; peer.vSrc=null; peer.vGain=null;
}
function voiceMute(pid){
  var i;
  pid=netClean(pid,16); if(!pid) return false;
  P.netMute=P.netMute||{};
  if(P.netMute[pid]) delete P.netMute[pid]; else P.netMute[pid]=1;
  try{ saveProfile(); }catch(e){}
  for(i=0;i<NET.peers.length;i++) voiceVol(NET.peers[i]);
  return !!P.netMute[pid];
}
// Push-to-talk: Y, read before anything else sees it, never in a text box, and let go when the window loses the keyboard.
(function(){
  function typing(ev){ var t=ev&&ev.target&&ev.target.tagName; return t==='INPUT'||t==='TEXTAREA'; }
  function up(){ if(NET.ptt){ NET.ptt=false; voiceGate(); } }
  window.addEventListener('keydown',function(ev){ if(ev.code!=='KeyY'||!NET.on||NET.same||typing(ev)) return; if(!NET.ptt){ NET.ptt=true; voiceGate(); } },true);
  window.addEventListener('keyup',function(ev){ if(ev.code==='KeyY') up(); },true);
  window.addEventListener('blur',up);
  document.addEventListener('visibilitychange',function(){ if(document.hidden) up(); });
})();
function netEntsHost(){
'@

SubRx @'
      stand:function(x,y){ if(typeof G==='undefined'||!G||!G.player) return false; G.player.x=+x; G.player.y=+y; return true; }};
'@ @'
      stand:function(x,y){ if(typeof G==='undefined'||!G||!G.player) return false; G.player.x=+x; G.player.y=+y; return true; },
      // v16.09: voice for the live test: switch the mic on, read what this window sends and hears, and the voice bytes it has taken in.
      mic:function(){ return voiceMicOn(); },
      voice:function(){ var h=0, l=0, i; for(i=0;i<NET.peers.length;i++){ if(NET.peers[i].vEl) h++; if(NET.peers[i].at||voiceLineOf(NET.peers[i])) l++; } return {mic:!!NET.micTrack,live:!!(NET.micTrack&&NET.micTrack.enabled),mode:NET.micMode||'',lines:l,heard:h}; },
      energy:function(){ return Promise.all(NET.peers.map(function(pe){ return (pe.pc&&pe.pc.getStats)?pe.pc.getStats().then(function(r){ var e=0; r.forEach(function(x){ if(x.type==='inbound-rtp'&&x.kind==='audio') e+=(x.bytesReceived||0); }); return e; },function(){ return 0; }):0; })).then(function(a){ return a.reduce(function(s,x){ return s+x; },0); }); }};
'@

SubRx @'
var VER='16.08';
'@ @'
var VER='16.09';
'@

$pat = "(?m)^  now:'v16\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.09: VOICE. Multiplayer, his rulings. Press MIC in the PARTY window (the browser asks first, never at load), then hold Y to talk, or pick OPEN MIC; a controller player starts on open mic. Every link carries a voice line from the start, so no new code is needed. MUTE beside a name silences that teammate on this PC. For now the host hears everyone and each friend hears the host. Solo play never touches it. No number moved. Check 16.09 fails on v16.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
