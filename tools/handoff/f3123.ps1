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

if ($s.Contains("  {v:'31.23',what:")) { throw "check 31.23 is in the fixture already" }

SubRx @'
  {v:'31.22',what:
'@ @'
  {v:'31.23',what:'cw-mapfirst2, from the critic on the opening map: the prompt on the opening map is one primary button, click to start with the key e (start with the pad a on a pad), and the map leaves the footer it sits in, at 1080 and at 4k; waiting for p2 keeps the same button',
   run:function(){
     if(typeof MAPFIRST!=='object'||typeof mapFirstFoot!=='function') return 'no footer for the opening prompt in this build (mapFirstFoot is missing)';
     if(!(window.__loop&&window.__state&&window.__endRaid&&window.__hubEnter&&window.__station&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot walk from the Undercroft into a raid';
     var bad=[], g=null, p=null, txt, mp, w0=W, h0=H, gp=null, padK={}, rumK={}, pk, rk, got, peer, box=[], NK={}, k,
         hasGp=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), oGp=navigator.getGamepads, oSay=say, oSkip=MAPFIRST.skip, oDev=INDEV.dev, oLeg=INDEV.legacy,
         alive=(typeof __vpAlive!=='function')||__vpAlive(), T0=performance.now();
     for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)) padK[pk]=PAD[pk];
     for(rk in RUMBLE) if(Object.prototype.hasOwnProperty.call(RUMBLE,rk)) rumK[rk]=RUMBLE[rk];
     for(k in NET) NK[k]=NET[k];
     function frames(n){ var b=performance.now(), q; for(q=0;q<n;q++){ __loop(b+q*50); if(performance.now()-T0>70000) throw new Error('too slow'); } }
     function seen(fn){ var h=txRecord(fn), out=[], q; for(q=0;q<h.length;q++) out.push(String(h[q].t)); return out; }
     function has(list,rx){ for(var q=0;q<list.length;q++) if(rx.test(list[q])) return true; return false; }
     function padStub(){ var b=[], q; for(q=0;q<17;q++) b.push({pressed:false,value:0}); gp={connected:true,id:'Xbox Wireless Controller',index:0,axes:[0,0,0,0],buttons:b,mapping:'standard'}; navigator.getGamepads=function(){ return [gp]; }; }
     function padOff(){ gp=null; if(hasGp) navigator.getGamepads=oGp; else delete navigator.getGamepads; for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)&&!Object.prototype.hasOwnProperty.call(padK,pk)) delete PAD[pk]; for(pk in padK) PAD[pk]=padK[pk]; for(rk in rumK) RUMBLE[rk]=rumK[rk]; try{ padBodyCls(); }catch(_pb){} }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       MAPFIRST.skip=0; keys={}; mouse.down=false; P.mapIx=0; pendSeed=4242;
       __hubEnter();
       got=__station('lift','KeyR');
       if(!got||got.err) return 'the quick ascent act did not fire ('+JSON.stringify(got)+')';
       g=__state(); if(!g||g.over||g.sim||!g.player||state!=='raid') return 'no raid came up from the quick ascent';
       p=g.player;
       if(!(g.mapFirst===1&&g.mapOpen)) return 'the raid did not open on the map ('+JSON.stringify({mapFirst:g.mapFirst,mapOpen:g.mapOpen})+')';
       // ONE: the words and the key, by the last device used
       if(alive){
         INDEV.legacy=false; INDEV.dev='kb'; g.mapFirstT=0.5;
         txt=seen(function(){ frames(2); });
         if(!has(txt,/^click to start$/)) bad.push('ONE: the keyboard prompt does not read click to start ('+txt.filter(function(s){ return /start|click/.test(s); }).join(' | ')+')');
         if(!has(txt,/^e$/)) bad.push('ONE: the keyboard prompt shows no E key');
         if(has(txt,/\bor click\b/)||has(txt,/drop in/)) bad.push('ONE: the old wording is still on the opening map');
         padStub(); INDEV.dev='pad'; g.mapFirstT=0.5;
         txt=seen(function(){ frames(2); });
         if(!has(txt,/^start$/)||has(txt,/click/)) bad.push('ONE: the pad prompt does not read start ('+txt.filter(function(s){ return /start|click/.test(s); }).join(' | ')+')');
         if(!has(txt,/^a$/)) bad.push('ONE: the pad prompt shows no A button');
         padOff(); INDEV.dev='kb';
       }
       // TWO: the map leaves the footer: at 1080 and at 4k the frame ends at least one button high above the bottom edge, and a map the player opens himself is centred as ever
       W=1920; H=1080; mp=mapProj();
       if(!(H-(mp.oy+WORLD_H*mp.sc)>=(LH(43)+8)*hudRes())) bad.push('TWO: at 1080 the map frame leaves '+Math.round(H-(mp.oy+WORLD_H*mp.sc))+' px under it, less than the prompt button needs');
       W=3840; H=2160; mp=mapProj();
       if(!(H-(mp.oy+WORLD_H*mp.sc)>=(LH(43)+8)*hudRes())) bad.push('TWO: at 4k the map frame leaves '+Math.round(H-(mp.oy+WORLD_H*mp.sc))+' px under it, less than the prompt button needs ('+Math.round((LH(43)+8)*hudRes())+')');
       if(!(mp.sc>0&&mp.oy>=60)) bad.push('TWO: the map under the opening prompt has a bad projection ('+JSON.stringify(mp)+')');
       W=w0; H=h0;
       mapFirstEnd('test'); W=3840; H=2160; mp=mapProj(); W=w0; H=h0;
       if(Math.abs(mp.oy-(2160-WORLD_H*mp.sc)/2)>0.5) bad.push('TWO: the map the player opens himself is no longer centred at 4k (oy '+mp.oy+')');
       // THREE: after the press the button is the same one, waiting for the other window
       MAPFIRST.skip=0; g.mapFirst=0; g.mapOpen=false;
       if(!mapFirstBegin()) bad.push('THREE: could not put the opening map back up');
       g.mapFirstT=0.5;
       peer={id:991,pc:null,dc:{readyState:'open',send:function(s){ try{ box.push(JSON.parse(s)); }catch(_j){} }},fc:null,state:'in',seat:1,pid:'zqxseat1',name:'ZQX MATE',timers:[]};
       NET.specG=null; NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.upSeed=g.seed>>>0; NET.peers=[peer]; NET.up=[]; NET.upOut=undefined; NET.upAcc=0;
       NET.roster=[{seat:0,name:'ZQX HOST',host:true},{seat:1,name:'ZQX MATE'}];
       try{ netEntsInit(g); }catch(_ei){}
       say=function(){ return 0; };
       netOnState(peer,{t:'st',k:'r',sd:g.seed>>>0,x:p.x+120,y:p.y,f:0,m:0,r:0,c:0,sp:0,dn:0,w:'',pz:0,hp:100,mh:100,ar:0,ac:0,dt:0,sa:1,mf:1});
       mapFirstGo('key');
       if(!(g.mapFirst===1&&g.mapFirstMe===1)) bad.push('THREE: the press did not wait for the other seat');
       if(alive){
         txt=seen(function(){ drawMapOverlay(); });
         if(!has(txt,/^waiting for zqx mate$/)) bad.push('THREE: no waiting for line after the press ('+txt.filter(function(s){ return /wait|start/.test(s); }).join(' | ')+')');
         if(has(txt,/^click to start$/)) bad.push('THREE: the start prompt is still up after the press');
       }
       return bad.length?bad.join('; '):null;
     } finally {
       padOff(); say=oSay; W=w0; H=h0; MAPFIRST.skip=oSkip; INDEV.dev=oDev; INDEV.legacy=oLeg; keys={}; mouse.down=false;
       try{ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }catch(_n){}
       try{ if(G&&!G.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     } }},
  {v:'31.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
