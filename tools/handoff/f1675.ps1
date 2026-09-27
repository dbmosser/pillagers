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

if ($s.Contains("  {v:'16.75',what:")) { throw "check 16.75 is in the fixture already" }

SubRx @'
  {v:'16.74',what:
'@ @'
  {v:'16.75',what:'Superhot is the host setting for the whole party: the host world word carries it, a linked window puts it on its live dial, refuses its own row and key and never writes its saved word, and gets its own back when the party ends; and in Superhot time stands still for a window paused in a shared raid and for the kept raid a spectating host runs, unless a teammate is acting',
   run:function(){
     if(typeof netWorldSend!=='function'||typeof netWorldTake!=='function'||typeof netSpecTick!=='function'||typeof netSpecStart!=='function'||typeof netReset!=='function'||typeof cycleGameOpt!=='function'||typeof applyGameOpts!=='function'||typeof NET!=='object'||!NET||typeof lastTs!=='number'||!window.__deploy||!window.__endRaid||!window.__loop) return 'SKIP: this build has no party world word';
     var bad=[], keep={}, cfgSnap={}, k, oFast=netSendFast, oSend=netSend, oShown=netUpShown, oRef=netRefresh, oSay=say, oSay2=(typeof say2==='function')?say2:null, sent=[], st0=null, k0=null, S=null, t0, m, r, hadGoObj=!!P.gameOpts, hadGo=false, go0, tuned0=null,
         pr={state:'in',seat:1,name:'CHECKKID',timers:[],dc:{readyState:'open',send:function(){}}}, hp={state:'in',seat:0,name:'CHECKHOST',timers:[],dc:{readyState:'open',send:function(){}}};
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     for(k in CFG) cfgSnap[k]=CFG[k];
     P.gameOpts=P.gameOpts||{}; hadGo=Object.prototype.hasOwnProperty.call(P.gameOpts,'superhot'); go0=P.gameOpts.superhot;
     try{ tuned0=JSON.stringify(P.tuned||{}); }catch(e0){ tuned0=null; }
     function wd(sh){ return {t:'wd',sd:G.seed>>>0,tl:G.timeLeft,wx:'',wn:'',wt:0,ai:-1,z:[],s:[],sh:sh}; }
     function mate(sa){ return {seat:1,x:G.player.x+300,y:G.player.y,f:0,tx:G.player.x+300,ty:G.player.y,tf:0,n:5,age:0,dn:0,sd:NET.upSeed>>>0,pz:0,sa:sa}; }
     function frames(n){ for(var j=0;j<n;j++){ __loop(lastTs+50); if(NET.up[1]) NET.up[1].age=0; } }
     function stage(role){
       NET.on=true; NET.role=role; NET.seat=(role==='host')?0:1; NET.upSeed=G.seed>>>0; NET.peers=[(role==='host')?pr:hp]; NET.up=[]; NET.specG=null; NET.upHold=1; NET.shHost=null; NET.shOwn=null;
       NET.roster=[{seat:0,pid:'me',name:'CHECKHOST',host:true},{seat:1,pid:'kid',name:'CHECKKID'}];
       NET.entMap={}; NET.entGone={}; NET.entN=0; NET.entRot=0; NET.entLast=-1; NET.contMap={}; NET.contN=0; NET.contN0=0; NET.holds={}; NET.srch=null; NET.srchOwn=-1;
     }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player) return 'SKIP: staging: no raid';
       st0=state; state='raid'; G.sim=0; G.over=false; G.paused=false; k0=keys; keys={};
       netSend=function(){ return true; }; netSendFast=function(q,mm){ sent.push(mm); return true; }; netRefresh=function(){}; say=function(){}; if(oSay2) say2=function(){};
       // 1. the host sends its dial in the world word
       stage('host');
       CFG.superhot=1; sent=[]; netWorldSend(); m=sent.length?sent[sent.length-1]:null;
       if(!m||m.t!=='wd') bad.push('staging: the host world word did not go out');
       else if(m.sh!==1) bad.push('the host world word does not carry Superhot ON (sh='+m.sh+')');
       CFG.superhot=0; sent=[]; netWorldSend(); m=sent.length?sent[sent.length-1]:null;
       if(m&&m.t==='wd'&&m.sh!==0) bad.push('the host world word does not carry Superhot OFF (sh='+m.sh+')');
       // 2. a linked window puts the host value on its live dial, never writes its saved word, refuses its own row, and gets its own back on netReset
       stage('join'); CFG.superhot=0;
       r=netWorldTake(hp,wd(1));
       if(r!=='wd') bad.push('staging: the host world word was not taken ('+r+')');
       if(CFG.superhot!==1) bad.push('a linked window did not put the host Superhot ON on its live dial');
       else {
         if(typeof gameOptLive==='function'&&gameOptLive('superhot')!==1) bad.push('the Settings row on a linked window does not show the host value');
         cycleGameOpt('superhot');
         if(CFG.superhot!==1) bad.push('the Superhot row on a linked window moved off the host value');
         applyGameOpts();
         if(CFG.superhot!==1) bad.push('another Settings row click put the window own word back over the host value');
         netWorldTake(hp,wd(0));
         if(CFG.superhot!==0) bad.push('the host turning Superhot off did not reach the linked window');
         netWorldTake(hp,wd(1));
         NET.on=false; NET.peers=[]; netReset();
         if(CFG.superhot!==0) bad.push('when the party ends the window own Superhot word (OFF) is not put back ('+CFG.superhot+')');
       }
       if(Object.prototype.hasOwnProperty.call(P.gameOpts,'superhot')!==hadGo||P.gameOpts.superhot!==go0) bad.push('a linked window wrote its own saved Superhot word ('+go0+' to '+P.gameOpts.superhot+')');
       // 3. a window paused in a shared raid: Superhot still stops time unless a teammate is acting
       stage('host'); NET.up[1]=mate(0);
       CFG.superhot=1; G.paused=true; G.over=false; state='raid'; keys={};
       t0=G.t; frames(10);
       if(G.t!==t0) bad.push('paused in a shared raid with Superhot on and the teammate still, this window ran the clock ('+(G.t-t0).toFixed(2)+' s)');
       NET.up[1].sa=1; t0=G.t; frames(10);
       if(!(G.t>t0)) bad.push('control: paused in a shared raid with the teammate acting, the world stood still');
       G.paused=false;
       // 4. a spectating host in Superhot: the kept raid stands still unless a teammate is acting
       NET.up[1]=mate(0); netUpShown=function(g){ return !!g; };
       if(!netSpecStart('dead')) bad.push('staging: the host did not start to spectate');
       else {
         G.over=true; S=G;
         t0=G.t; netSpecTick(0.5); netSpecTick(0.5);
         if(G.t!==t0) bad.push('in Superhot with the teammate still, the kept raid a spectating host runs went on ('+(G.t-t0).toFixed(2)+' s)');
         NET.up[1].sa=1; t0=G.t; netSpecTick(0.5);
         if(!(G.t>t0)) bad.push('control: with the teammate acting the kept raid stood still');
       }
     } finally {
       try{ netSend=oSend; netSendFast=oFast; netUpShown=oShown; netRefresh=oRef; say=oSay; if(oSay2) say2=oSay2; }catch(e1){}
       try{ if(S) G=S; if(G&&G.player) G.player.specOut=0; if(G) G.paused=false; }catch(e2){}
       try{ if(k0) keys=k0; }catch(e3){}
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k];
       for(k in keep) NET[k]=keep[k];
       try{ for(k in cfgSnap) CFG[k]=cfgSnap[k]; }catch(e4){}
       try{ if(!hadGoObj) delete P.gameOpts; else if(hadGo) P.gameOpts.superhot=go0; else delete P.gameOpts.superhot; if(tuned0!==null) P.tuned=JSON.parse(tuned0); }catch(e5){}
       if(st0!==null) state=st0;
       try{ __endRaid('abandon'); __topClear(); }catch(e6){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
