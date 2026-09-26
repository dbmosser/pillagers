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

if ($s.Contains("  {v:'16.11',what:")) { throw "check 16.11 is in the fixture already" }

SubRx @'
  {v:'16.10',what:
'@ @'
  {v:'16.11',what:'co-op fixes from the backcheck: a shared-raid pause lets the storm land its bolt; YES, ABANDON refuses a player who went down after arming it; holding E over a downed teammate inside an open ring calls no extraction, and E held on after the pick-up sends nothing more; the host world word leaves a never-closing ring open-ended, leaves a pull this player began alone and does not move his called ring; the link to the host learns the host id',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof NET!=='object'||!NET||typeof netOnMsg!=='function'||typeof updatePlayer!=='function') return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, sent=[], p, peer, i, Z, W1=null, ca=document.getElementById('confirmabandon');
     for(i=0;i<WEATHER.length;i++) if(WEATHER[i].id==='storm') W1=WEATHER[i];
     function mk(seat){ return {state:'in',seat:seat,name:'ZQX',timers:[],dc:{readyState:'open',send:function(t){ sent.push(JSON.parse(t)); }}}; }
     function js(o){ return JSON.stringify(o); }
     function party(role){ NET.on=true; NET.role=role; NET.seat=(role==='host')?0:1; peer=mk(role==='host'?1:0); NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[]; NET.roster=[{seat:0,pid:'zqxhost',name:'ZQX HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}]; }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={}; p=G.player; G.sim=0; G.over=false; G.t=200;
       if(!W1||!G.zones||!G.zones.length||!ca) return 'SKIP: no storm, rings or confirm button';
       // THE STORM UNDER A SHARED PAUSE
       party('host'); G.wx=W1; G.paused=true; G.strikes=[{x:p.x+900,y:p.y,t:0.05,hit:0,id:5}];
       strikeTick(0.1);
       if(G.strikes.length) bad.push('paused in a shared raid the storm held its bolt, so the party saw it land late or not at all');
       G.paused=false; G.strikes=[];
       // THE PICK-UP TAKES E
       Z=G.zones[0]; Z.open=true; Z.beaconT=null; Z.hold=null; Z.callT=0; p.x=Z.x; p.y=Z.y;
       NET.up[1]={seat:1,x:p.x+30,y:p.y,f:0,n:5,age:0,dn:1,sd:NET.upSeed>>>0};
       sent.length=0;
       for(i=0;i<40;i++){ keys['KeyE']=true; updatePlayer(0.05); if(G.netRevEat){ G.netRevEat=0; keys['KeyE']=true; } }
       if(Z.beaconT!==null&&Z.beaconT!==undefined) bad.push('holding E to pick up a teammate inside an open ring called the extraction too');
       var rv=sent.filter(function(m){ return m.t==='rev'; }).length;
       if(rv!==0) bad.push('a pick-up was sent after 2 s of holding, before the hire time');
       for(i=0;i<60;i++){ keys['KeyE']=true; updatePlayer(0.05); if(G.netRevEat){ G.netRevEat=0; keys['KeyE']=true; } }
       rv=sent.filter(function(m){ return m.t==='rev'; }).length;
       if(rv!==1) bad.push('holding E 5 s over a downed teammate sent '+rv+' pick-ups, not one');
       keys={}; Z.beaconT=null; NET.up=[];
       // THE HOST WORD ON A LINKED WINDOW
       party('join');
       var zw=[]; for(i=0;i<G.zones.length;i++) zw.push([true,null,null,null,null]);
       G.zones[0].closeAt=undefined;
       netOnMsg(peer,js({t:'wd',sd:G.seed>>>0,tl:G.timeLeft,wx:W1.id,wn:'',wt:0,ai:-1,z:zw,s:[]}));
       if(G.zones[0].closeAt!==undefined) bad.push('a ring that never closes came through the host word with closeAt '+G.zones[0].closeAt);
       if(G.zones.length>1){
         Z=G.zones[1]; p.x=Z.x; p.y=Z.y; Z.open=true; Z.pullT=0.5; zw[1]=[false,null,null,null,100];
         netOnMsg(peer,js({t:'wd',sd:G.seed>>>0,tl:G.timeLeft,wx:W1.id,wn:'',wt:0,ai:-1,z:zw,s:[]}));
         if(Z.open===false) bad.push('the host word shut a ring while this player was pulling in it');
         Z.pullT=null;
         G.zones[0].beaconT=12; G.active=G.zones[0]; zw[1]=[true,30,null,null,null];
         netOnMsg(peer,js({t:'wd',sd:G.seed>>>0,tl:G.timeLeft,wx:W1.id,wn:'',wt:0,ai:1,z:zw.map(function(a,k){ return k===0?[true,12,null,null,null]:a; }),s:[]}));
         if(G.active!==G.zones[0]) bad.push('the host word moved the ring this player called');
       }
       // THE HOST ID
       NET.role='join'; NET.seat=-1; peer=mk(0); peer.state='open'; NET.peers=[peer];
       netOnMsg(peer,js({t:'welcome',you:1,roster:[{seat:0,pid:'zqxhost',name:'ZQX HOST',host:true},{seat:1,pid:'zqxmate',name:'ME'}],ver:VER}));
       if(peer.pid!=='zqxhost') bad.push('the link to the host does not know the host id ('+peer.pid+'), so MUTE beside the host does nothing');
       // THE CONFIRM WHILE DOWN (last: on the old build it ends the raid)
       NET.on=false; NET.role=null; NET.peers=[];
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={}; p=G.player; G.sim=0; G.over=false; G.t=200;
       p.downed=true; ca.style.display=''; ca.onclick.call(ca);
       if(!G||G.over) bad.push('YES, ABANDON pressed while down ended the run'+(G?' as '+G.over:'')+', turning a death into an abandon');
     }
     finally{
       try{ keys={}; if(G){ G.paused=false; G.netRevEat=0; } if(ca) ca.style.display='none'; }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; }catch(_g){}
       try{ if(typeof state==='undefined'||state!=='hub') __hubEnter(); }catch(_he){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.10',what:
'@


SubRx @'
     function hold(sec){ keys['KeyE']=true; for(var t=0;t<sec;t+=0.05) updatePlayer(0.05); keys['KeyE']=false; }
'@ @'
     // v16.11: held the way the loop holds it: a pick-up takes E for its step (netRevHold) and the loop hands it back after; one
     // step with E up at the end lets go, so the next hold starts a fresh pick-up
     function hold(sec){ for(var t=0;t<sec;t+=0.05){ keys['KeyE']=true; updatePlayer(0.05); if(G.netRevEat) G.netRevEat=0; } keys['KeyE']=false; updatePlayer(0.05); }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
