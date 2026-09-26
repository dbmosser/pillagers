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

if ($s.Contains("  {v:'16.06',what:")) { throw "check 16.06 is in the fixture already" }

SubRx @'
  {v:'16.05',what:
'@ @'
  {v:'16.06',what:'the host owns the raid clock, the weather, the lightning and the rings: the host world word carries the clock, the sky, the live bolts and every ring; a linked window takes them, draws a host bolt that never hits it, runs no weather turn of its own, and a beacon a teammate calls is called on the host',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile&&window.__loop)||typeof NET!=='object'||!NET||typeof netOnMsg!=='function'||typeof WEATHER==='undefined') return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster,upN:NET.upN}, keepSt=state, sent=[], p, peer, i, wd=null, TS=5000, oPick=pickWeather, WS=null, WF=null, WR=null, hp0;
     for(i=0;i<WEATHER.length;i++){ if(WEATHER[i].id==='storm') WS=WEATHER[i]; if(WEATHER[i].id==='fog') WF=WEATHER[i]; if(WEATHER[i].id==='rain') WR=WEATHER[i]; }
     function mk(seat){ return {state:'in',seat:seat,name:'ZQX',timers:[],dc:{readyState:'open',send:function(t){ sent.push(JSON.parse(t)); }}}; }
     function js(o){ return JSON.stringify(o); }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={};
       p=G.player; G.sim=0; G.over=false; state='raid';
       if(!G.zones||!G.zones.length||!WS||!WF||!WR) return 'SKIP: no rings or no storm, fog and rain in this build';
       // THE HOST WORD
       NET.on=true; NET.role='host'; NET.seat=0; peer=mk(1); NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,name:'HOST',host:true},{seat:1,name:'ZQX MATE'}];
       G.timeLeft=123.4; G.wx=WS; G.wxNext=null; G.strikes=[{x:p.x+300,y:p.y,t:0.8,hit:0,id:77}];
       sent.length=0;
       try{ if(typeof netWorldSend==='function') netWorldSend(); }catch(x0){ bad.push('netWorldSend threw: '+x0); }
       for(i=0;i<sent.length;i++) if(sent[i].t==='wd') wd=sent[i];
       if(!wd) bad.push('the host sends the party no word of the clock, the weather, the bolts or the rings, so each window runs its own');
       else{
         if(wd.tl!==123.4||wd.wx!=='storm') bad.push('the world word says clock '+wd.tl+' and sky '+wd.wx+', not 123.4 and storm');
         if(!wd.s||!wd.s.length||wd.s[0][0]!==77) bad.push('the world word does not carry the live bolt: '+js(wd.s));
         if(!wd.z||wd.z.length!==G.zones.length) bad.push('the world word carries '+(wd.z?wd.z.length:0)+' rings, not '+G.zones.length);
       }
       var bc=netOnMsg(peer,js({t:'bcn',i:0}));
       if(!(G.zones[0].beaconT>0)) bad.push('a beacon a teammate called at ring 0 was not called on the host ('+bc+')');
       // THE LINKED WINDOW
       NET.role='join'; NET.seat=1; peer=mk(0); NET.peers=[peer]; NET.up=[];
       NET.roster=[{seat:0,name:'ZQX HOST',host:true},{seat:1,name:'ME'}];
       G.zones[0].beaconT=null; G.strikes=[]; G.wx=WR; G.timeLeft=300;
       var zw=[]; for(i=0;i<G.zones.length;i++) zw.push([null,i===0?30:null,null,null,null]);
       var tk=netOnMsg(peer,js({t:'wd',sd:G.seed>>>0,tl:200,wx:'fog',wn:'',wt:0,ai:0,z:zw,s:[[91,Math.round(p.x),Math.round(p.y),0.04]]}));
       if(Math.abs(G.timeLeft-200)>0.01) bad.push('the linked window clock reads '+G.timeLeft+' after the host said 200 ('+tk+')');
       if(!G.wx||G.wx.id!=='fog') bad.push('the linked window sky is '+(G.wx&&G.wx.id)+' after the host said fog');
       if(G.zones[0].beaconT!==30) bad.push('the linked window ring 0 beacon reads '+G.zones[0].beaconT+' after the host said 30');
       var rb=null; for(i=0;i<G.strikes.length;i++) if(G.strikes[i].rid===91) rb=G.strikes[i];
       if(!rb) bad.push('the host bolt is not drawn on the linked window');
       G.wx=WS; hp0=p.hp; p.downed=false; G.lightning=0;
       strikeTick(0.1);
       if(p.hp!==hp0) bad.push('a host bolt on the linked window hit him there too ('+hp0+' to '+p.hp+'), so the host hit would land twice');
       else if(rb&&!(G.lightning>0)) bad.push('the host bolt did not flash on the linked window');
       // NO WEATHER TURN OF ITS OWN
       pickWeather=function(){ return WR; };
       G.wx=WF; G.wxNext=null; G.wxTurnsLeft=1; G.wxAt=0; G.paused=false;
       for(i=0;i<5;i++){ TS+=16; __loop(TS); }
       if(G.wxNext&&G.wxNext.id==='rain') bad.push('the linked window turned its own weather to rain, on its own stream');
     }
     finally{
       try{ pickWeather=oPick; }catch(_pw){}
       try{ keys={}; }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; NET.upN=keepN.upN; }catch(_n){}
       try{ G=null; state=keepSt; }catch(_g){}
       try{ if(typeof state==='undefined'||state!=='hub') __hubEnter(); }catch(_he){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.05',what:
'@


SubRx @'
       var ow2=netOnMsg(H,js({t:'up',s:0,st:'out',how:'dead'}));
       if(ow2!=='up:out'||NET.up[0]) bad.push('the host out word did not take it off the list ('+ow2+')');
       netUpTick(0);
       if(frame()!==n0) bad.push('after the host raid ended this window still draws it');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the words from up top');
       unspy();
       sentB.length=0;
       down();
       var outB=last(sentB,'up');
'@ @'
       sentB.length=0;   // v16.06: since v15.91 the host out word ends this raid as abandon, his ruling (check 15.91): the out word this window sends goes out then
       var ow2=netOnMsg(H,js({t:'up',s:0,st:'out',how:'dead'}));
       if(ow2!=='up:out'||NET.up[0]) bad.push('the host out word did not take it off the list ('+ow2+')');
       if(G&&G.player&&!G.over){ netUpTick(0); if(frame()!==n0) bad.push('after the host raid ended this window still draws it'); }
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the words from up top');
       unspy();
       down();
       var outB=last(sentB,'up');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
