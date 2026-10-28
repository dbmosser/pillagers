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

if ($s.Contains("  {v:'35.38',what:")) { throw "check 35.38 is in the fixture already" }

SubRx @'
  {v:'35.37',what:
'@ @'
  {v:'35.38',what:'combat voices: each player role hears at most 6 guns, 8 impacts, 3 explosions and 12 active cues; oldest complete cue yields, sources stop, natural ends and muted cues release slots',
   run:function(){
     var hasCap=typeof sndVoiceOpen==='function';
     var saved={AC:AC,BUS:BUS,REV:REV,SND:SND,SNDV:hasCap?SNDV:null,ctx:SND_CTX,sim:G&&G.sim,same:NET.same,spec:NET.specTick,on:NET.on,fx:NET.fxIn,sndG:NET.sndG,sndAc:NET.sndAc,sndP:NET.sndP,sndOn:NET.sndOn,pan:PAN_OK}, bad=[], made=[], clock=10, FK, role, i, cueId=0;
     function param(){ return {value:1,setValueAtTime:function(){},linearRampToValueAtTime:function(){},exponentialRampToValueAtTime:function(){},setTargetAtTime:function(){},cancelScheduledValues:function(){}}; }
     function node(k){ var n={kind:k,cue:cueId,outs:[],startAt:Infinity,stopAt:Infinity,endAt:Infinity,done:false,connect:function(x){ this.outs.push(x); return x; },disconnect:function(){ this.outs=[]; },start:function(t,off,dur){this.startAt=t; if(this.buffer&&!this.loop)this.endAt=t+(dur===undefined?this.buffer.duration-(off||0):dur)/(this.playbackRate.value||1);},stop:function(t){this.stopAt=t;},gain:param(),frequency:param(),Q:param(),pan:param(),playbackRate:param(),detune:param(),threshold:param(),knee:param(),ratio:param(),attack:param(),release:param(),delayTime:param()}; made.push(n); return n; }
     FK={currentTime:clock,sampleRate:48000,state:'running',destination:node('dest'),createGain:function(){return node('gain');},createBufferSource:function(){return node('src');},createOscillator:function(){return node('osc');},createStereoPanner:function(){return node('pan');},createBiquadFilter:function(){return node('filter');},createDynamicsCompressor:function(){return node('comp');},createDelay:function(){return node('delay');},createWaveShaper:function(){return node('shape');},createBuffer:function(c,l,s){return {length:l,duration:l/s,getChannelData:function(){return new Float32Array(l);}};}};
     function reset(){ if(hasCap) SNDV={ac:null,live:[],fade:[],limits:{gun:6,impact:8,explosion:3},max:12,stolen:0}; }
     function cue(t,w){ cueId++; _realBlip(t,40,0,w); }
     function advance(t){ FK.currentTime=t; made.forEach(function(n){if(!n.done&&Math.min(n.endAt,n.stopAt)<=t){n.done=true;if(n.onended)n.onended();}}); }
     function measure(r){
       reset(); made=[]; NET.same=r; var ev=[],t,p,max=0,srcMax=0,activeMax=0;
       for(t=0;t<2;t+=0.105) ev.push([t,'shot','lmg'],[t+0.012,'hit','armor'],[t+0.014,'clank','metal']);
       for(t=0;t<2;t+=0.650){ev.push([t,'shot','shotgun']);for(p=0;p<6;p++)ev.push([t+0.012+p*0.001,'hit','metal']);}
       for(t=0.01;t<2;t+=0.075) ev.push([t,'boom']);
       ev.sort(function(a,b){return a[0]-b[0];});
       ev.forEach(function(e){
         advance(10+e[0]); cue(e[1],e[2]); var ids={},ns=0;
         made.forEach(function(n){if((n.kind==='src'||n.kind==='osc')&&!n.done&&n.startAt<=FK.currentTime&&Math.min(n.endAt,n.stopAt)>FK.currentTime&&n.outs.length){ids[n.cue]=1;ns++;}});
         max=Math.max(max,Object.keys(ids).length); srcMax=Math.max(srcMax,ns); activeMax=Math.max(activeMax,hasCap?SNDV.live.length:Object.keys(ids).length);
       });
       advance(15); if(hasCap)sndVoicePrune(FK,15);
       return {role:r,emissions:ev.length,peakAudibleCues:max,peakActiveCues:activeMax,peakSources:srcMax};
     }
     function count(k){return SNDV.live.filter(function(v){return v.kind===k;}).length;}
     function bound(){ if(count('gun')>6||count('impact')>8||count('explosion')>3||SNDV.live.length>12||SNDV.fade.length>2) bad.push(role+' exceeds voice budget'); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_lmg','gun_shotgun'],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player||G.over) return 'staging failed: no raid';
       G.sim=false; AC=FK; BUS=null; REV=null; SND=null; SND_CTX=null; NET.specTick=false; NET.on=false;
       window.__combatVoiceMeasure={capped:hasCap,results:[measure('host'),measure('p2')]};
       if(typeof console!=='undefined'&&console.info) console.info('combat voice measurement '+JSON.stringify(window.__combatVoiceMeasure));
       if(!hasCap) return 'no combat voice cap; '+JSON.stringify(window.__combatVoiceMeasure);
       ['host','p2'].forEach(function(r){
         role=r; NET.same=r; NET.fxIn=(r==='p2'); reset();
         cue('shot','shotgun'); var lone=SNDV.live[0];
         if(!lone||lone.g.gain.value!==1||lone.sources.length<5) bad.push(r+' isolated shotgun lost layers or unity gain');
         if(lone&&lone.end<FK.currentTime+0.26) bad.push(r+' shotgun pump is outside its lifetime');
         var first=lone;
         for(i=0;i<6;i++) cue('shot','lmg');
         if(count('gun')!==6||!first.retired||first.sources.some(function(s){return s.stopAt>FK.currentTime+0.00401;})) bad.push(r+' oldest gun or its delayed sources survived stealing');
         reset(); for(i=0;i<9;i++) cue('hit','metal'); if(count('impact')!==8) bad.push(r+' impact cap missing');
         reset(); for(i=0;i<4;i++) cue('boom'); if(count('explosion')!==3) bad.push(r+' explosion cap missing');
         reset();
         for(i=0;i<8;i++) cue('clank','concrete');
         var oldest=SNDV.live[0];
         for(i=0;i<5;i++) cue('shot',i%2?'shotgun':'lmg');
         if(SNDV.live.length!==12||!oldest.retired) bad.push(r+' overall cap did not steal oldest across kinds');
         for(i=0;i<60;i++){ cue('shot',i%2?'shotgun':'lmg'); cue('hit','armor'); cue('clank','metal'); if(i%4===0) cue('boom'); bound(); }
         if(!SNDV.stolen) bad.push(r+' burst never stole a voice');
         FK.currentTime+=3; sndVoicePrune(FK,FK.currentTime);
         if(SNDV.live.length||SNDV.fade.length) bad.push(r+' completed sounds still occupy slots');
         cue('shot','lmg'); var natural=SNDV.live[0]; natural.sources.forEach(function(s){if(s.onended)s.onended();});
         if(SNDV.live.length) bad.push(r+' ended callbacks did not release a voice');
         var before=SNDV.live.length; _realBlip('shot',99999,0,'lmg'); if(SNDV.live.length!==before) bad.push(r+' inaudible shot occupied a slot');
       });
       return bad.length?bad.join('; '):null;
     }finally{
       try{ if(hasCap) SNDV.live.concat(SNDV.fade).forEach(function(v){sndVoiceStop(v,FK.currentTime,false);}); }catch(e){}
       AC=saved.AC; BUS=saved.BUS; REV=saved.REV; SND=saved.SND; if(hasCap)SNDV=saved.SNDV; SND_CTX=saved.ctx;
       NET.same=saved.same; NET.specTick=saved.spec; NET.on=saved.on; NET.fxIn=saved.fx; NET.sndG=saved.sndG; NET.sndAc=saved.sndAc; NET.sndP=saved.sndP; NET.sndOn=saved.sndOn; PAN_OK=saved.pan;
       try{__endRaid('abandon');}catch(e){} if(G) G.sim=saved.sim; __topClear();
     }
   }},
  {v:'35.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
