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

if ($s.Contains("  {v:'17.33',what:")) { throw "check 17.33 is in the fixture already" }

SubRx @'
  {v:'17.32',what:
'@ @'
  {v:'17.33',what:'while the host spectates, a ring player 2 calls runs on the host: its clock counts down, a siege machine arrives within one siege interval at least 700 from player 2, and once the boarding window has passed a second call on that ring is taken as new instead of refused as called already',
   run:function(){
     if(typeof netSpecStart!=='function'||typeof netSpecTick!=='function'||typeof netOnMsg!=='function'||typeof netBeaconTake!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no spectating host';
     var keep={}, k, oSend=netSend, oFast=netSendFast, oShown=netUpShown, oRef=netRefresh, oET=netEntsTick, oCT=netContTick, oWS=netWorldSend, oCrash=noteCrash, oSay=say, oSWF=sayWhenFree,
         oMS=mkSentry, oMC=mkCrawler, keepSH=CFG.superhot, bad=[], S=null, peer=null, Z=null, r, i, b0, had, got=[], born=[], crashed=[], iv, secs;
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     function js(o){ return JSON.stringify(o); }
     function spec(secs){ var j; for(j=0;j<Math.round(secs/0.1);j++) netSpecTick(0.1); }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player||!G.zones||!G.zones.length) return 'SKIP: staging: no live raid with a ring';
       CFG.superhot=0;
       peer={state:'in',seat:1,name:'ZQX MATE',timers:[],dc:{readyState:'open',send:function(){}}};
       netSend=function(){ return true; }; netSendFast=function(){ return true; }; netUpShown=function(g){ return !!g; }; netRefresh=function(){};
       netEntsTick=function(){ return 0; }; netContTick=function(){ return 0; }; netWorldSend=function(){ return 0; };
       noteCrash=function(a,b){ crashed.push(String(b||a)); }; say=function(){}; sayWhenFree=function(){};
       mkSentry=function(x,y){ born.push({x:x,y:y}); return oMS.apply(null,arguments); }; mkCrawler=function(x,y){ born.push({x:x,y:y}); return oMC.apply(null,arguments); };
       Z=G.zones[0];
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[peer]; NET.upOut=undefined; NET.specG=null; NET.specTick=false;
       NET.roster=[{seat:0,name:'HOST',host:true},{seat:1,name:'ZQX MATE'}];
       NET.up=[{seat:1,n:1,age:0,sd:G.seed>>>0,tx:Z.x,ty:Z.y,tf:0,dn:0}];
       if(!netSpecStart('dead')) return 'SKIP: staging: the host did not start to spectate';
       G.over=true; S=G; G=null;   // past his run card: he is in the Undercroft and the raid runs on for player 2 standing in ring A
       for(i=0;i<S.zones.length;i++) if(S.zones[i]!==Z){ S.zones[i].beaconT=null; S.zones[i].hold=null; }
       r=netOnMsg(peer,js({t:'bcn',i:0,g:0.2}));
       if(r!=='called') return 'SKIP: staging: the beacon call was not taken against the kept raid ('+r+')';
       b0=Z.beaconT;
       iv=(8-4.6*0.2)/((CFG.siegeVol===undefined)?1:CFG.siegeVol);   // the siege interval at this greed and the siege dial as set (11.8 s at the default 0.6)
       if(!(iv>0&&iv<20)) return 'SKIP: staging: the siege dial gives an interval of '+iv+' seconds, too long to watch';
       secs=Math.ceil(iv)+1;
       if(!(b0>=secs+2)) return 'SKIP: staging: the ship is due in '+b0+' seconds, too soon to watch '+secs+' seconds of siege';
       had=S.ents.slice(); born=[];
       spec(secs);
       if(crashed.length) bad.push('the kept raid faulted: '+crashed[0]);
       if(!(Z.beaconT<=b0-(secs-1))) bad.push(secs+' seconds after player 2 called ring A with the host spectating, the ring clock reads '+Z.beaconT+' of '+b0+': nothing counts it down');
       for(i=0;i<S.ents.length;i++) if(S.ents[i]&&S.ents[i].siegeBorn&&had.indexOf(S.ents[i])<0) got.push(S.ents[i]);
       if(!got.length) bad.push(secs+' seconds into the call no siege machine arrived on the kept raid (a call at this greed brings one every '+iv.toFixed(1)+' seconds)');
       for(i=0;i<born.length;i++) if(dist(born[i],Z)<700){ bad.push('a machine was made '+Math.round(dist(born[i],Z))+' from player 2 at the ring'); break; }
       // THE SHIP COMES AND GOES: the boarding window opens and runs out, and ring A is free to call again.
       Z.beaconT=0.05; Z.hold=null;
       spec(0.2);
       if(Z.beaconT===null||Z.beaconT===undefined||Z.hold===null||Z.hold===undefined) bad.push('the ship came down on the kept raid with no boarding window (hold '+Z.hold+')');
       Z.hold=0.05;
       spec(0.2);
       if(Z.beaconT!==null&&Z.beaconT!==undefined) bad.push('the boarding window ran out on the kept raid and ring A is still held as called ('+Z.beaconT+')');
       r=netOnMsg(peer,js({t:'bcn',i:0,g:0.2}));
       if(r!=='called') bad.push('player 2 called ring A again after the ship left without him and the host answered '+r+', so the call made no sound in the world');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netSendFast=oFast; netUpShown=oShown; netRefresh=oRef; netEntsTick=oET; netContTick=oCT; netWorldSend=oWS; noteCrash=oCrash; say=oSay; sayWhenFree=oSWF;
       mkSentry=oMS; mkCrawler=oMC; CFG.superhot=keepSH;
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k];
       for(k in keep) NET[k]=keep[k];
       if(S){ G=S; try{ if(G.player) G.player.specOut=0; G.over=false; __endRaid('abandon'); __topClear(); }catch(e2){} }
       else { try{ if(G&&!G.over) __endRaid('abandon'); __topClear(); }catch(e3){} }
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
