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

if ($s.Contains("  {v:'27.77',what:")) { throw "check 27.77 is in the fixture already" }

SubRx @'
  {v:'27.76',what:
'@ @'
  {v:'27.77',what:'his order (add the sounds): the sound pack is in the game and adopted at boot: 42 cues in SNDA_GEN on their buses, the 13 recordings decode, the rings of the world cues, and every cue builds and returns a handle the LMG whirr cut can use',
   run:function(){
     var bad=[], names, worldRings, roles, i, k, FK, MADE=[], h, b, n0, lastN;
     function P(v){ var q={value:v}; q.setValueAtTime=function(x){ q.value=x; return q; }; q.setTargetAtTime=q.setValueAtTime; q.linearRampToValueAtTime=q.setValueAtTime; q.exponentialRampToValueAtTime=q.setValueAtTime; q.cancelScheduledValues=function(){ return q; }; return q; }
     function N(kind,ps){ var o={kind:kind,on:0}; o.connect=function(t){ return t; }; o.disconnect=function(){}; o.start=function(){ o.on++; }; o.stop=function(){}; (ps||[]).forEach(function(nm){ o[nm]=P(nm==='gain'?1:0); }); MADE.push(o); return o; }
     FK={currentTime:1,sampleRate:48000,state:'running',resume:function(){},destination:N('dest'),
       createGain:function(){ return N('gain',['gain']); },
       createBiquadFilter:function(){ var o=N('filter',['frequency','Q','gain','detune']); o.type='lowpass'; return o; },
       createOscillator:function(){ var o=N('osc',['frequency','detune']); o.type='sine'; return o; },
       createBufferSource:function(){ var o=N('src',['playbackRate','detune']); o.buffer=null; o.loop=false; return o; },
       createWaveShaper:function(){ var o=N('shaper'); o.curve=null; o.oversample='none'; return o; },
       createBuffer:function(c,l,sr){ var d=new Float32Array(l); return {length:l,numberOfChannels:c,sampleRate:sr,duration:l/sr,getChannelData:function(){ return d; }}; }};
     names=['evDebrisWarn','debrisFall','debrisLand','evConvoyWarn','convoyRoll','evBountyWarn','bountyPaid','evCoolantWarn','coolantBurst','evRampageWarn','rampageRoar',
       'airConfirm','airInbound','airBoom','pwrAppear','pwrGetClip','pwrGetDmg','pwrGetRapid','pwrGetShield','pwrGetNuke','pwrEnd','pwrLast','pwrBubbleHit',
       'medal1','medal2','medal3','medal4','medal5','gateBreach','barrelBlast','barrelChain','arHit','arMiss','lmgSpinUp','lmgWindDown','finishBlow','goldAppear',
       'haulTick','haulUncommon','haulRare','haulElite','haulGold'];
     worldRings=['debrisLand','airBoom','gateBreach','barrelBlast','barrelChain','debrisFall','convoyRoll','coolantBurst','rampageRoar'];
     roles=['xplBig','xplMid','xplShort','xplLow','subBoom','metalCrash','metalHit','drumBonk','punch','stomp','thruster','engineLow','forceField'];
     try{
       if(typeof SNDA_GEN!=='object'||!SNDA_GEN||typeof SND_CAT!=='object'||typeof NOISEMARK!=='object'||typeof SND_CATS!=='object') return 'SKIP: no sound tables in this build';
       if(typeof SPK_GEN!=='object'||typeof spkAdopt!=='function'||typeof SPK_BANK!=='object') return 'the sound pack is not in this build (no SPK_GEN or spkAdopt)';
       for(i=0;i<names.length;i++){
         k=names[i];
         if(typeof SNDA_GEN[k]!=='function') bad.push(k+' is not adopted into SNDA_GEN');
         else if(SND_CATS.indexOf(SND_CAT[k])<0) bad.push(k+' rides the bus '+SND_CAT[k]);
       }
       for(i=0;i<worldRings.length;i++){ k=worldRings[i]; if(!NOISEMARK[k]||!(NOISEMARK[k].r>=60)||!(NOISEMARK[k].hear>=1200)) bad.push(k+' leaves no ring or cannot be heard far enough'); }
       if(spkAdopt()!==0) bad.push('a second spkAdopt() added '+spkAdopt()+' cues (it overwrote or re-added)');
       for(i=0;i<roles.length;i++){ b=spkBuf(FK,roles[i]); if(!b||!(b.duration>0.05)) bad.push('the recording '+roles[i]+' does not decode'); }
       lastN=0;
       for(i=0;i<names.length;i++){
         k=names[i]; if(typeof SNDA_GEN[k]!=='function') continue;
         SPK.at={}; n0=MADE.length; h=null;
         try{ h=SNDA_GEN[k](FK,FK.destination,1,1,2,300); }catch(e){ bad.push(k+' threw: '+(e&&e.message||e)); continue; }
         if(!h||!h.g||!h.g.gain) bad.push(k+' returned no handle');
         else if(k==='lmgSpinUp'&&(!h.o||typeof h.o.stop!=='function')) bad.push('lmgSpinUp has no source for lmgWhirrStop to stop');
         if(MADE.length-n0<3) bad.push(k+' builds only '+(MADE.length-n0)+' nodes');
         lastN=MADE.length-n0;
       }
       if(typeof SPK_MAP!=='undefined') bad.push('the wiring table SPK_MAP is still carried');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ SPK.at={}; }catch(_f){} }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
