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

if ($s.Contains("  {v:'16.14',what:")) { throw "check 16.14 is in the fixture already" }

SubRx @'
  {v:'16.13',what:
'@ @'
  {v:'16.14',what:'the host spectates: with a friend up top the host extracting keeps the raid, tells the party spec and not out, runs the world on with the host back in the Undercroft, targets the friend and not the host, calls a beacon a friend asks for, holds the host at the lift, and when the friend is gone ends and tells the party out; a friend told spec runs on; control, with nobody up top the host ending tells out at once',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile&&window.__hubEnter&&window.__loop)||typeof NET!=='object'||!NET||typeof netOnMsg!=='function'||typeof endRaid!=='function') return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, keepSt=state, sent=[], peer, S=null, t0, e=null, i, TS=9000, oc=document.getElementById('outcome');
     function mk(seat){ return {state:'in',seat:seat,name:'ZQX MATE',timers:[],dc:{readyState:'open',send:function(t){ sent.push(JSON.parse(t)); }}}; }
     function js(o){ return JSON.stringify(o); }
     function frames(n){ for(var k=0;k<n;k++){ TS+=16; __loop(TS); } }
     function upw(st){ return sent.filter(function(m){ return m.t==='up'&&m.st===st; }).length; }
     function stage(withMate){
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={}; state='raid'; G.sim=0; G.over=false; G.tel.shots=1;
       NET.on=true; NET.role='host'; NET.seat=0; peer=mk(1); NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[]; NET.specG=null;
       NET.roster=[{seat:0,pid:'zqxhost',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       if(withMate) NET.up[1]={seat:1,x:G.player.x+400,y:G.player.y,f:0,tx:G.player.x+400,ty:G.player.y,tf:0,n:5,age:0,dn:0,sd:NET.upSeed>>>0,mv:0,roll:0,bob:0,cr:0,sp:0,w:''};
       sent.length=0;
     }
     try{
       // CONTROL: nobody up top, the host ending tells out at once
       stage(false); endRaid('extract');
       if(NET.specG) bad.push('control: with nobody up top the host kept the raid running');
       if(!upw('out')) bad.push('control: with nobody up top the host ending did not tell the party out');
       if(oc) oc.classList.remove('on'); G=null; NET.up=[];
       // THE HOST SPECTATES
       stage(true); S=G;
       for(i=0;i<G.ents.length&&!e;i++) if(G.ents[i].kind!=='raider'&&G.ents[i].hp>0) e=G.ents[i];
       endRaid('extract');
       if(NET.specG!==S) bad.push('with a friend up top the host extracting did not keep the raid running');
       if(upw('out')) bad.push('with a friend up top the host extracting told the party out, which ends the friend as abandon');
       if(!upw('spec')) bad.push('the party was not told the host is out and spectating');
       if(NET.specG!==S) return bad.join('; ');   // nothing below can run: the raid was not kept
       if(oc) oc.classList.remove('on'); G=null; keys={}; __hubEnter(); if(NET.up[1]) NET.up[1].age=0;
       t0=S.t; frames(10); if(NET.up[1]) NET.up[1].age=0;
       if(!(S.t>t0)) bad.push('with the host back in the Undercroft the raid stood still ('+t0+' to '+S.t+')');
       if(e){ var tg=null, kg=G; G=S; try{ tg=netTargetFor(e); }finally{ G=kg; } if(!tg||tg===S.player) bad.push('a machine still goes for the host who is out'); }
       var bc=netOnMsg(peer,js({t:'bcn',i:0,g:0.2}));
       if(!(S.zones[0].beaconT>0)) bad.push('a beacon the friend called while the host spectates was not called ('+bc+')');
       if(ascendNow()!==false||G) bad.push('the spectating host went up again');
       // THE FRIEND IS OUT
       NET.up[1]=null; sent.length=0;
       frames(120);
       if(NET.specG) bad.push('with the friend out the host still runs the raid after 2 s');
       else if(!upw('out')) bad.push('when spectating ended the party was not told out');
       // A FRIEND TOLD SPEC RUNS ON
       NET.specG=null; stage(false); NET.role='join'; NET.seat=1; peer=mk(0); NET.peers=[peer];
       var sw=netOnMsg(peer,js({t:'up',st:'spec',how:'extract'}));
       if(!G||G.over) bad.push('a friend told the host spectates was ended ('+sw+')');
     }
     finally{
       try{ NET.specG=null; NET.specTick=false; keys={}; if(oc) oc.classList.remove('on'); }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; state=keepSt; }catch(_g){}
       try{ if(typeof state==='undefined'||state!=='hub') __hubEnter(); }catch(_he){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.13',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
