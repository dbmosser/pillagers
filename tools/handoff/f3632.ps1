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

if ($s.Contains("  {v:'36.32',what:")) { throw "check 36.32 is in the fixture already" }

SubRx @'
  {v:'36.31',what:
'@ @'
  {v:'36.32',what:'Lance full and active reloads in either window, and Lance, Longshot and rocket shots, fall below .001 within 1.5 seconds; room feedback cannot sustain a resonance',
   run:function(){
    class Param {
 constructor(v=0){this.value=v;this.e=[];}
 setValueAtTime(v,t){this.e.push(['set',v,t]);return this;}
 linearRampToValueAtTime(v,t){this.e.push(['lin',v,t]);return this;}
 exponentialRampToValueAtTime(v,t){this.e.push(['exp',v,t]);return this;}
 setTargetAtTime(v,t,c){this.e.push(['target',v,t,c]);return this;}
 cancelScheduledValues(t){this.e=this.e.filter(e=>e[2]<t);}
 at(t){let v=this.value,pt=0;for(let e of this.e){if(e[2]>t){if(e[0]==='lin')return v+(e[1]-v)*(t-pt)/(e[2]-pt);if(e[0]==='exp')return v*Math.pow(e[1]/v,(t-pt)/(e[2]-pt));break;}v=e[0]==='target'?e[1]+(v-e[1])*Math.exp(-(t-e[2])/e[3]):e[1];pt=e[2];}return v;}
}
class Audio {
 constructor(){this.currentTime=0;this.sampleRate=22050;this.nodes=[];this.tag='';this.destination=this.node('dest');}
 node(kind){let n={id:this.nodes.length,kind,tag:this.tag,ins:[],gain:new Param(1),frequency:new Param(350),Q:new Param(1),pan:new Param(0),playbackRate:new Param(1),delayTime:new Param(0),startTime:Infinity,end:Infinity};n.connect=d=>{d.ins.push(n);return d;};n.disconnect=()=>{};n.start=(t=0,off=0,dur)=>{n.startTime=t;n.off=off;if(n.buffer&&!n.loop)n.end=t+(dur===undefined?n.buffer.duration-off:dur)/n.playbackRate.value;};n.stop=t=>{n.end=t;};this.nodes.push(n);return n;}
 createGain(){return this.node('gain');} createOscillator(){return this.node('osc');} createBiquadFilter(){return this.node('filter');} createBufferSource(){return this.node('buffer');} createDelay(){return this.node('delay');} createStereoPanner(){return this.node('pan');}
 createBuffer(c,len,sr){let data=new Float32Array(len);return {length:len,sampleRate:sr,duration:len/sr,getChannelData:()=>data};}
 render(seconds){let sr=this.sampleRate,N=Math.ceil(seconds*sr),out=new Float32Array(N),delays=this.nodes.filter(n=>n.kind==='delay');for(let n of delays)n.ring=new Float32Array(sr);let stamp=new Int32Array(this.nodes.length).fill(-1),vals=new Float64Array(this.nodes.length);
  const evalN=(n,i,t)=>{if(stamp[n.id]===i)return vals[n.id];stamp[n.id]=i;let y=0;if(n.kind==='delay')y=n.ring[(i+sr-Math.round(n.delayTime.at(t)*sr))%sr];else if(n.kind==='buffer'){if(t>=n.startTime&&t<n.end){let k=Math.floor(((t-n.startTime)*n.playbackRate.at(t)+(n.off||0))*n.buffer.sampleRate);y=n.buffer.getChannelData(0)[k]||0;}}else if(n.kind==='osc'){if(t>=n.startTime&&t<n.end){n.phase=(n.phase||0)+n.frequency.at(t)/sr;let p=n.phase%1;y=n.type==='sine'?Math.sin(2*Math.PI*p):n.type==='sawtooth'?2*p-1:n.type==='triangle'?1-4*Math.abs(p-.5):(p<.5?1:-1);}}else{let x=0;for(let s of n.ins)x+=evalN(s,i,t);y=x;if(n.kind==='gain')y*=n.gain.at(t);if(n.kind==='filter'){
   let f=n.frequency.at(t),q=n.Q.at(t),key=f+':'+q+':'+n.type;if(n.key!==key){let w=2*Math.PI*Math.min(sr*.49,f)/sr,c=Math.cos(w),al=Math.sin(w)/(2*(n.type==='bandpass'?Math.max(.01,q):Math.pow(10,q/20))),a0=1+al,b=n.type==='highpass'?[(1+c)/2,-(1+c),(1+c)/2]:n.type==='bandpass'?[al,0,-al]:[(1-c)/2,1-c,(1-c)/2];n.cf=[b[0]/a0,b[1]/a0,b[2]/a0,-2*c/a0,(1-al)/a0];n.key=key;}let b=n.cf;y=b[0]*x+b[1]*(n.x1||0)+b[2]*(n.x2||0)-b[3]*(n.y1||0)-b[4]*(n.y2||0);n.x2=n.x1;n.x1=x;n.y2=n.y1;n.y1=y;
  }}vals[n.id]=y;return y;};
  for(let i=0;i<N;i++){let t=i/sr;for(let d of delays)evalN(d,i,t);out[i]=evalN(this.destination,i,t);let writes=delays.map(d=>d.ins.reduce((v,s)=>v+evalN(s,i,t),0));delays.forEach((d,j)=>d.ring[i%sr]=writes[j]);}return out;
 }
}

    var old={ac:ac,sndBus:sndBus,netSndOut:netSndOut,netSynth:netSynth,foley:foley,blip:blip,BUS:BUS,REV:REV,SFXB:SFXB,RLFX:RLFX,SNDV:SNDV,on:NET.on,spec:NET.specTick,ctx:SND_CTX,pan:PAN_OK},g,p,a,events=[],results=[],savedMap,rs,real=(typeof _realBlip==='function')?_realBlip:blip;
    function prime(room){
     a=new Audio(); BUS=null; REV=null; SFXB={buf:{},ac:null,nb:0,n:{},at:{},last:'',fail:0}; RLFX={on:false,p:null,w:null,tot:0,st:[],i:0,dry:false,hum:null};
     SNDV={ac:null,live:[],fade:[],limits:{gun:6,impact:8,explosion:3},max:12,stolen:0};
     g.map={locked:[],buildings:[],woods:[]};
     if(room==='vault')g.map.locked=[{x:p.x-10,y:p.y-10,w:20,h:20}];
     if(room==='inside')g.map.buildings=[{x:p.x-10,y:p.y-10,w:20,h:20}];
     var r=verb(),sp=spaceAt(p.x,p.y); r.send.gain.value=sp.wet;
     r.cells.forEach(function(c){c.fb.gain.value=sp.fb;c.lp.frequency.value=sp.damp;});
     return r;
    }
    function measure(label,end){
     var src=a.nodes.filter(function(n){return n.kind==='osc'||n.kind==='buffer';}),data=a.render(end+2),peak=0,i;
     if(!src.length)throw Error(label+' made no audio nodes');
     for(i=0;i<src.length;i++)if(!isFinite(src[i].end)||src[i].end>end+1.5)throw Error(label+' source '+src[i].id+' ends at '+src[i].end);
     for(i=Math.ceil((end+1.5)*a.sampleRate);i<data.length;i++)peak=Math.max(peak,Math.abs(data[i]));
     results.push(label+': '+peak.toFixed(7));
     if(peak>.001)throw Error(label+' still audible after 1.5 seconds (peak '+peak.toFixed(7)+')');
    }
    try{
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     __deploy({kit:['gun_lance','gun_rifle'],safe:null,mapIx:0,seed:4242});
     g=__state(); if(!g||!g.player||g.over)return 'no raid for Lance audio check';
     p=g.player;savedMap=g.map;rs=g.sim;g.sim=false;NET.on=false;NET.specTick=null;SND_CTX=null;
     // Unity mix is a conservative input to the actual BUS and room graph; no compressor masks a long tail.
     ac=function(){return a;}; sndBus=function(){return bus();}; netSndOut=function(){return a.destination;}; blip=real;
     netSynth=function(r,who,w){events.push({t:a.currentTime,r:r,w:w});};
     foley=function(r,x,y,o){events.push({t:a.currentTime,clip:r});return old.foley.apply(this,arguments);};
     for(var ri=0;ri<2;ri++){
      var room=ri?'inside':'vault';
      for(var active=0;active<2;active++){
       prime(room);events=[];p.wep=cloneObj(WEAPONS.lance);p.ammo=0;p.reserve=9;p.reloading=4000;p.rlTot=4000;p.rlArm=1;p.arStk=0;p.arHot=0;
       reloadFoley(p);var end=active?2:4;
       for(var n=1;n<=end*100;n++){a.currentTime=n/100;if(active&&n===end*100){var oldKeys=keys;keys={KeyR:true};try{if(!activeReloadTick(p))throw Error('active reload did not finish');}finally{keys=oldKeys;}}else tickReload(.01);}
       var replay=events.slice(),tags=replay.filter(function(e){return !!e.r;}).map(function(e){return e.r;}).join(',');
       if(tags!=='~whine,~ping,~whinex')throw Error('teammate charge/ping/cut order: '+tags);
       measure(room+' '+(active?'active':'full')+' own',end);
       // Replay the exact wire order into the partner receiver. Its bank cues intentionally use receiver defaults.
       prime(room);var ownHum=RLFX.hum;
       replay.forEach(function(e){a.currentTime=e.t;if(e.clip)old.foley(e.clip,p.x,p.y,{local:1,gap:0});else synthAt(e.r.slice(1),p.x,p.y,e.w);});
       if(RLFX.far||RLFX.hum!==ownHum)throw Error('teammate whine did not cut independently');
       measure(room+' '+(active?'active':'full')+' teammate',end);
      }
      for(var wi=0;wi<3;wi++){prime(room);a.currentTime=0;var wid=['lance','sniper','rocket'][wi];real('shot',0,undefined,wid);measure(room+' '+wid+' last shot',0);}
     }
     return null;
    }catch(e){return e.message||String(e);}
    finally{
     ac=old.ac;sndBus=old.sndBus;netSndOut=old.netSndOut;netSynth=old.netSynth;foley=old.foley;blip=old.blip;BUS=old.BUS;REV=old.REV;SFXB=old.SFXB;RLFX=old.RLFX;SNDV=old.SNDV;NET.on=old.on;NET.specTick=old.spec;SND_CTX=old.ctx;PAN_OK=old.pan;
     if(g){g.map=savedMap;g.sim=rs;}
     try{__endRaid('abandon');}catch(_end){} __topClear();
    }
   }},
  {v:'36.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
