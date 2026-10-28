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

# COMBAT SOUND VOICE CAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function blip(type,d,pan){
'@ @'
// v28.xx (cw-cx-combatvoices): Q27, stutter or harsh sound. A voice is the whole cue, including delayed gun action and tails.
// The unity gate leaves a lone shot unchanged. Oldest voices yield on a 4 ms fade; at most two fading tails survive a burst.
var SNDV={ac:null,live:[],fade:[],limits:{gun:6,impact:8,explosion:3},max:12,stolen:0};
function sndVoiceKind(type){
  if(/^(boom|airBoom|gateBreach|barrelBlast|barrelChain|barrelShock|barrelAcid|barrelCryo|coolantBurst)$/.test(type)) return 'explosion';
  return SND_CAT[type]==='gun'?'gun':(SND_CAT[type]==='imp'?'impact':null);
}
function sndVoiceFree(v){
  if(v.freed) return;
  v.freed=true;
  v.nodes.forEach(function(n){ try{ n.disconnect(); }catch(e){} });
  try{ v.g.disconnect(); }catch(e){}
  var i=SNDV.live.indexOf(v); if(i>=0) SNDV.live.splice(i,1);
  i=SNDV.fade.indexOf(v); if(i>=0) SNDV.fade.splice(i,1);
}
function sndVoiceStop(v,t,fade){
  var end=t+(fade?0.004:0);
  v.end=end; v.retired=true;
  try{ v.g.gain.cancelScheduledValues(t); v.g.gain.setValueAtTime(1,t); v.g.gain.linearRampToValueAtTime(0,end); }catch(e){}
  v.sources.forEach(function(s){ try{ s.stop(end); }catch(e){} });
  var i=SNDV.live.indexOf(v); if(i>=0) SNDV.live.splice(i,1);
  if(!fade) sndVoiceFree(v);
  else { SNDV.fade.push(v); while(SNDV.fade.length>2) sndVoiceStop(SNDV.fade[0],t,false); }
}
function sndVoicePrune(a,t){
  SNDV.live.concat(SNDV.fade).forEach(function(v){
    if(v.a!==a) sndVoiceStop(v,v.a.currentTime,false);
    else if(v.end<=t) sndVoiceFree(v);
  });
  SNDV.ac=a;
}
function sndVoiceOpen(a,out,type,t){
  var k=sndVoiceKind(type); if(!k) return null;
  sndVoicePrune(a,t);
  var v={a:a,kind:k,g:a.createGain(),nodes:[],sources:[],ends:[],end:Infinity,pending:0,sealed:false,freed:false,retired:false};
  v.g.gain.value=1; v.g.connect(out);
  // v28.xx (cw-cx-combatvoices): only this synchronous generator sees the facade; native methods keep their real context as receiver.
  v.audio=new Proxy(a,{get:function(target,key){
    if(key==='__sndVoiceRaw') return target;
    var f=target[key]; if(typeof f!=='function') return f;
    return function(){
      var n=f.apply(target,arguments);
      if(/^create/.test(key)&&n&&typeof n.disconnect==='function') v.nodes.push(n);
      if(key==='createBufferSource'||key==='createOscillator'){
        var ix=v.sources.length, start=n.start, stop=n.stop, done=false;
        v.sources.push(n); v.ends.push(Infinity); v.pending++;
        n.start=function(at,off,dur){
          var r=start.apply(n,arguments), when=at===undefined?a.currentTime:at, rate=(n.playbackRate&&n.playbackRate.value)||1;
          if(n.buffer&&!n.loop){ var len=n.buffer.duration||n.buffer.length/a.sampleRate; v.ends[ix]=Math.min(v.ends[ix],when+(dur===undefined?Math.max(0,len-(off||0)):dur)/rate); }
          return r;
        };
        n.stop=function(at){ var r=stop.apply(n,arguments); v.ends[ix]=at===undefined?a.currentTime:at; return r; };
        var ended=function(){ if(done) return; done=true; v.pending--; if(v.sealed&&v.pending===0) sndVoiceFree(v); };
        if(n.addEventListener) n.addEventListener('ended',ended,{once:true}); else n.onended=ended;
      }
      return n;
    };
  }});
  return v;
}
function sndVoiceSeal(v){
  if(!v) return;
  v.sealed=true;
  if(!v.pending){ sndVoiceFree(v); return; }
  v.end=Math.max.apply(Math,v.ends);
  var t=v.a.currentTime, same=SNDV.live.filter(function(x){ return x.kind===v.kind; });
  while(same.length>=SNDV.limits[v.kind]){ sndVoiceStop(same.shift(),t,true); SNDV.stolen++; }
  while(SNDV.live.length>=SNDV.max){ sndVoiceStop(SNDV.live[0],t,true); SNDV.stolen++; }
  SNDV.live.push(v);
}
function blip(type,d,pan){
'@

SubRx @'
  if(SNDA_GEN[type]){ try{ SNDA_GEN[type](a,OUT,vol,t,arguments[3],d); }catch(_sa){} return; }   // v24.xx (sndA1): the new noises
'@ @'
  // v28.xx (cw-cx-combatvoices): budget the complete generator after distance culling, with the existing pan and muffle intact.
  var _sv=sndVoiceOpen(a,OUT,type,t); if(_sv){ OUT=_sv.g; a=_sv.audio; }
  try{
  if(SNDA_GEN[type]){ try{ SNDA_GEN[type](a,OUT,vol,t,arguments[3],d); }catch(_sa){} return; }   // v24.xx (sndA1): the new noises
'@

SubRx @'
  }
}

// ================================================================ utils
'@ @'
  }
  }finally{ sndVoiceSeal(_sv); }
}

// ================================================================ utils
'@

SubRx @'
function spkCtx(a){ if(SPK.ac!==a){ SPK.ac=a; SPK.buf={}; SPK.nz=null; SPK.shp={}; } }
'@ @'
function spkCtx(a){ a=a.__sndVoiceRaw||a; if(SPK.ac!==a){ SPK.ac=a; SPK.buf={}; SPK.nz=null; SPK.shp={}; } } // v28.xx (cw-cx-combatvoices): keep decoded clips cached across budgeted cues
'@

SubRx @'
var VER='35.37';
'@ @'
var VER='35.38';
'@

$pat = "(?m)^  now:'v35\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.38: Gunfire, impacts and explosions have bounded overlap; oldest sounds yield during heavy fights. Check 35.38 fails on v35.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
