$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'16.09',what:")) { throw "check 16.09 is in the fixture already" }

SubRx @'
  {v:'16.08',what:
'@ @'
  {v:'16.09',what:'voice: the mic was never asked for at load; MIC asks once and sends the track down every link; with HOLD Y the track is live only while Y is held and goes quiet on blur; OPEN MIC keeps it live; MUTE beside a name silences that voice and UNMUTE brings it back; alone, Y does nothing',
   run:function(){
     if(typeof NET!=='object'||!NET||typeof netReset!=='function') return 'SKIP: this build has no party';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,seat:NET.seat,roster:NET.roster,same:NET.same,micMode:NET.micMode}, md=navigator.mediaDevices, oG=md?md.getUserMedia:null, asked=0, got=[], track={kind:'audio',enabled:true,stopped:0,stop:function(){ this.stopped++; }}, keepMute=P.netMute, peer, r;
     function key(type,code){ window.dispatchEvent(new KeyboardEvent(type,{code:code,key:code==='KeyY'?'y':code,bubbles:true,cancelable:true})); }
     if(typeof voiceMicOn!=='function') return 'this build has no voice: there is no microphone to switch on, no push-to-talk and no mute';
     if(NET.micAsks) bad.push('the microphone was asked for '+NET.micAsks+' times before MIC was pressed');
     if(!md) return 'SKIP: no mediaDevices in this browser';
     try{
       md.getUserMedia=function(){ asked++; return {then:function(ok){ return ok({getAudioTracks:function(){ return [track]; },getTracks:function(){ return [track]; }}); }}; };
       NET.on=true; NET.role='host'; NET.seat=0; NET.same=''; NET.micMode='ptt'; NET.micTrack=null; NET.micStream=null; NET.ptt=false;
       peer={state:'in',seat:1,pid:'zqxpid01',name:'ZQX MATE',timers:[],dc:{readyState:'open',send:function(){}},at:{sender:{replaceTrack:function(t){ got.push(t); }}},vGain:{gain:{value:1}},vSrc:null,vEl:null};
       NET.peers=[peer]; NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxpid01',name:'ZQX MATE'}];
       r=voiceMicOn();
       if(asked!==1) bad.push('MIC asked the browser '+asked+' times, not once');
       if(got[got.length-1]!==track) bad.push('the mic track was not sent down the link');
       if(track.enabled) bad.push('with HOLD Y and Y not held the mic is live');
       key('keydown','KeyY'); if(!track.enabled) bad.push('holding Y did not open the mic');
       key('keyup','KeyY'); if(track.enabled) bad.push('letting go of Y left the mic open');
       key('keydown','KeyY'); window.dispatchEvent(new Event('blur')); if(track.enabled) bad.push('the window losing the keyboard left the mic open');
       key('keyup','KeyY');
       NET.micMode='open'; voiceGate(); if(!track.enabled) bad.push('OPEN MIC did not keep the mic live');
       NET.micMode='ptt'; voiceGate();
       voiceMute('zqxpid01'); if(peer.vGain.gain.value!==0) bad.push('MUTE left his voice at '+peer.vGain.gain.value);
       voiceMute('zqxpid01'); if(peer.vGain.gain.value!==1) bad.push('UNMUTE left his voice at '+peer.vGain.gain.value);
       voiceMicOff(); if(!track.stopped||NET.micTrack) bad.push('switching the mic off did not let it go');
       // ALONE
       NET.on=false; NET.role=null; NET.peers=[]; track.enabled=false; NET.micTrack=track;
       key('keydown','KeyY'); if(track.enabled||NET.ptt) bad.push('alone, Y opened a mic'); key('keyup','KeyY');
       NET.micTrack=null;
     }
     finally{
       try{ md.getUserMedia=oG; }catch(_g){}
       try{ NET.ptt=false; NET.micTrack=null; NET.micStream=null; NET.micAsks=0; }catch(_m){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.seat=keepN.seat; NET.roster=keepN.roster||[]; NET.same=keepN.same; NET.micMode=keepN.micMode; }catch(_n){}
       try{ P.netMute=keepMute; }catch(_pm){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.08',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
