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

if ($s.Contains("  {v:'37.68',what:")) { throw "check 37.68 is in the fixture already" }

SubRx @'
  {v:'37.67',what:
'@ @'
  {v:'37.68',what:'cw-cx-survivallevel: career SP from kills, shared machines, styles, vaults, bounties and strongholds fills the saved living pillager survival bar through several levels; extraction SP adds only the uncounted bonus once; cap 20; old saves start at 0 without losing account data and reload twice; actual saved SP and level survive a reload; death keeps the level in the hall and a newborn starts at 0; host and join earn only their own SP and show separate cleaned levels over peer heads; sim, finished raids and the demo award nothing, with no survival bar or picks in the demo',
   run:function(){
     if(!(window.__runPrep&&window.__topClear&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__deploy&&window.__endRaid&&window.__state&&window.__drawHUD)) return 'SKIP: fixture cannot stage the survival bar';
     if(typeof pilSurvivalAdd!=='function'||typeof pilSurvivalDraw!=='function'||typeof pilSurvivalMig!=='function'||typeof netPilLevelPut!=='function') return 'no pillager survival level in this build';
     var saved=P, cfg={}, k, oldStore=storeSet, oldSave=saveProfile, oldSay=say, oldFast=netSendFast, oldBoard=careerBoardAdd,
         arc=ARCADE.on, stale=SAVE_STALE, crash=CRASH_RESTART, n0={on:NET.on,role:NET.role,seat:NET.seat,peers:NET.peers,roster:NET.roster,up:NET.up,upSeed:NET.upSeed,pn:NET.pn,pnSent:NET.pnSent,upHold:NET.upHold,upOut:NET.upOut,upHow:NET.upHow},
         bad=[], g, q, snap, legacy, A, B, i, j, n, before, points, levels=[], written='', sent=[], txt=[], oldFill=ctx.fillText, oldWorldFill=wc.fillText, oldBar=bar, bars=[], state0=state, p2=(typeof NETP2==='undefined'?false:NETP2), s;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function J(o){ return JSON.stringify(o); }
     function keep(p){ var r=p.pil?JSON.parse(J(p.pil)):null; if(r){delete r.lvl;delete r.lsp;} return J({c:p.credits,s:p.stash,w:p.weapons,eq:p.equipped,eq2:p.equippedSec,ct:p.contracts,fg:p.forged||{},le:p.lifeEarn,a:p.acctName,pg:p.pilGen,h:p.hall,g:p.gear,gn:p.gearN,wn:p.worn,p:r}); }
     function stage(){
       ARCADE.on=false; NET.on=false; NET.role=null; NET.peers=[]; NET.up=[]; NET.upHold=0; NET.upOut={}; NET.upHow={};
       if(typeof NETP2!=='undefined') NETP2=false;
       if(!P.pil){ P.hall=[]; P.pilGen=0; acctEnsure(P); }
       __deploy({kit:[],mapIx:0,seed:4242}); g=__state(); g.ents.length=0; g.hotZone=null; g.player.iv=999; g.player.hp=100; g.player.downed=false;
       need(!!g.career&&!g.arcade&&!g.sim,'staging did not enter a career raid');
       P.pil.lsp=0; P.pil.lvl=0; P.mig4a=1;
       g.cs.s=0; g.cs.k=0; g.cs.b={}; delete g.careerPaid;
       return g;
     }
     function earn(fn,label){ var a=P.pil.lsp, b=g.cs.s; n=fn(); need(n>0&&P.pil.lsp-a===g.cs.s-b,label+' SP did not fill by the exact score increase'); }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(t){ written=t; }; saveProfile=function(){ written=J(P); };
       say=function(t){ if(/^level \d+$/.test(String(t))) levels.push(String(t)); };
       // ONE: a pre-m4 save, retaining its stash, contracts, forge, worn gear, lineage and account values.
       P.contracts=[]; ensureContracts();
       q=wornAdd(P,wornMake('boots',1,35,7)); wornWear(P,q.id,'boots'); wornAdd(P,wornMake('gloves',2,40,11));
       snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
       snap.credits=12345; snap.stash=['scrap','core']; snap.weapons=['pistol','smg']; snap.equipped='smg'; snap.equippedSec='none';
       snap.forged={smg:{fk:1,el:''}}; snap.lifeEarn=321; snap.pil.traits=['lightstep'];
       snap.pil.gen=2; snap.pilGen=2; snap.hall=[{name:'vosk',gen:1,num:1,traits:[],lvl:1,lsp:0,picks:[],raids:1,ext:0,kills:2,best:0,born:1000,end:{at:2000,how:'dead'}}];
       snap.pil.name='rusk'; snap.pil.raids=3; snap.pil.lvl=1; snap.pil.lsp=0; delete snap.mig4a;
       legacy=J(snap); A=keep(snap);
       for(j=0;j<2;j++){
         snap=JSON.parse(legacy); if(j) delete snap.pil.lsp;
         for(i=0;i<2;i++){
           applyLoadedProfile({value:J(snap)});
           need(!!P.pil&&P.pil.lvl===0&&P.pil.lsp===0&&P.mig4a===1,'old save shape '+j+' load '+i+' did not start at level 0');
           need(keep(P)===A,'old save shape '+j+' load '+i+' moved account data');
           snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
         }
       }
       B=JSON.parse(legacy); B.pil=null; pilHeirs(B);
       B.heirs.forEach(function(r){ r.lvl=1; r.lsp=0; });
       q=pilBirth(B); need(q&&q.lvl===0&&q.lsp===0,'a cached pre-m4 heir inherited level 1 at birth');
       // TWO: every real career score door contributes its exact paid SP.
       stage();
       earn(function(){ return careerKill('sentry',0,false,g.player.x+40,g.player.y,null); },'kill');
       earn(function(){ return sharedMachineScore({kind:'crawler',x:g.player.x+40,y:g.player.y,elite:0}); },'shared machine');
       earn(function(){ return scoreBonus(100,g.player.x,g.player.y,''); },'style');
       earn(function(){ var a=g.cs.s; arcadeVaultPayN({},125); return g.cs.s-a; },'vault');
       earn(function(){ return flowChip(75,'BOUNTY',''); },'bounty');
       earn(function(){ return flowChip(90,'STRONGHOLD',''); },'stronghold');
       need(written&&JSON.parse(written).pil.lsp===P.pil.lsp,'a live score award did not request a save');
       // THREE: actual next-bar fractions, repeated level crossings, a short callout, and cap 20.
       P.pil.lsp=0; P.pil.lvl=0; levels=[];
       pilSurvivalAdd(PIL_SURVIVAL_SP[1]-1); s=pilSurvivalState(P.pil);
       need(s.lvl===0&&s.f>0.99&&s.f<1,'the first bar did not move before its level threshold');
       pilSurvivalAdd(2); s=pilSurvivalState(P.pil);
       need(P.pil.lvl===1&&s.lvl===1&&s.f>0&&s.f<0.01&&levels.indexOf('level 1')>=0,'the bar did not carry its remainder into level 1');
       pilSurvivalAdd(PIL_SURVIVAL_SP[5]-P.pil.lsp+17); s=pilSurvivalState(P.pil);
       need(P.pil.lvl===5&&s.lvl===5&&s.sp===PIL_SURVIVAL_SP[5]+17&&s.f>0&&s.f<1&&levels.indexOf('level 5')>=0,'one award did not keep filling through several levels');
       pilSurvivalAdd(1e9); need(P.pil.lvl===20&&P.pil.lsp===PIL_SURVIVAL_SP[20]&&pilSurvivalState(P.pil).f===1,'cap 20 did not hold');
       need(pilSurvivalAdd(999)===0&&P.pil.lsp===PIL_SURVIVAL_SP[20],'SP grew past the cap');
       need(P.pil.picks.length===0,'the bar granted picks in the raid');
       // FOUR: use the existing saver with a captured storage sink, then reload the resulting profile twice.
       P.pil.lsp=PIL_SURVIVAL_SP[7]+61; P.pil.lvl=7;
       SAVE_STALE=false; CRASH_RESTART=false;
       saveProfile=oldSave; written=''; saveProfile(); saveProfile=function(){ written=J(P); };
       need(!!written,'the real profile saver did not serialize the level');
       snap=JSON.parse(written||J(P)); A=keep(snap);
       for(i=0;i<2;i++){
         applyLoadedProfile({value:J(snap)});
         need(P.pil.lvl===7&&P.pil.lsp===PIL_SURVIVAL_SP[7]+61&&keep(P)===A,'earned level or save data changed on reload '+i);
         snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
       }
       // FIVE: an extraction counts its extra SP exactly once, after the live total, and a death keeps earned SP in the hall.
       stage(); scoreBonus(500,g.player.x,g.player.y,''); before=P.pil.lsp; points=g.cs.s;
       g.over='extract'; n=careerSettle('extract',[]);
       need(P.pil.lsp===before+Math.max(0,n-points),'extraction SP double counted the live score or missed its bonus');
       before=P.pil.lsp; careerSettle('extract',[]); need(P.pil.lsp===before,'a second settlement gave SP twice');
       g.over=false; delete g.careerPaid; __endRaid('dead');
       q=P.hall[P.hall.length-1]; need(q&&q.lsp===before&&q.lvl===pilSurvivalLevel(before)&&!P.pil,'death did not keep the ended level in the hall');
       pilBirth(P); need(P.pil.lvl===0&&P.pil.lsp===0,'a new pillager inherited the dead level');
       // SIX: render the actual HUD and trace its label and six-pixel progress fill; host and join each earn into their own record.
       stage(); P.pil.lsp=200; P.pil.lvl=0; CFG.xfPix=0;
       ctx.fillText=function(t){ txt.push(String(t).toLowerCase()); return oldFill.apply(this,arguments); };
       bar=function(x,y,w,h,f,c,bg){ bars.push({h:h,f:f,c:c}); return oldBar.apply(this,arguments); };
       __drawHUD();
       need(txt.indexOf('pillager survival level')>=0&&bars.some(function(b){ return b.h===6&&b.c==='#e6ff3d'&&Math.abs(b.f-200/PIL_SURVIVAL_SP[1])<0.001; }),'the actual HUD did not paint the partial survival bar next to health');
       need(HUDBOX.body&&VITBOX&&VITBOX.y+VITBOX.h<=H&&HUDBOX.body.y+HUDBOX.body.h<=H,'the health and survival stack ran below the screen');
       ctx.fillText=oldFill; bar=oldBar;
       for(i=0;i<2;i++){
         NET.on=true; NET.role=i?'join':'host'; NET.seat=i; NET.roster=[{seat:0,name:'hostacct'},{seat:1,name:'joinacct'}]; NET.up=[]; NET.pn={}; NET.upSeed=g.seed>>>0;
         NET.peers=[{state:'in',seat:1-i}]; if(!i) NET.peers.push({state:'in',seat:2}); sent=[]; netSendFast=function(peer,m){ sent.push(m); return true; };
         before=P.pil.lsp; scoreBonus(80,g.player.x,g.player.y,''); need(P.pil.lsp-before===spMul(80),'role '+NET.role+' did not earn its own SP');
         s={}; netPilLevelPut(s); need(s.pl===pilSurvivalLevel(P.pil.lsp),'role '+NET.role+' did not send its own level');
         A=J(P.pil);
         netOnState(NET.peers[0],{t:'st',k:'r',s:0,sd:g.seed>>>0,x:g.player.x+60,y:g.player.y,f:0,m:0,pn:'brakka',pl:4});
         q=NET.up[1-i]; need(q&&q.pl===4&&pilSurvivalTag(q,netSeatName(1-i))==='brakka  level 4','role '+NET.role+' did not show the peer name and level');
         __frame(0.016);
         txt=[]; wc.fillText=function(t){ txt.push(String(t).toLowerCase()); };
         try{ netUpTags(); }finally{ wc.fillText=oldWorldFill; }
         need(txt.indexOf('brakka  level 4')>=0,'role '+NET.role+' actual raid head label did not draw the name and level');
         need(J(P.pil)===A&&netSeatName(1-i)==='brakka','a peer level changed own progress or the name');
         if(!i) need(sent.some(function(m){ return m.pl===4&&m.s===1; }),'host did not relay the cleaned level');
         netOnState(NET.peers[0],{t:'st',k:'r',s:0,sd:g.seed>>>0,x:g.player.x+60,y:g.player.y,f:0,m:0,pl:999});
         need(q.pl===20,'peer level was not clamped');
         netOnState(NET.peers[0],{t:'st',k:'r',s:0,sd:g.seed>>>0,x:g.player.x+60,y:g.player.y,f:0,m:0,pl:'bad'});
         need(q.pl===undefined&&pilSurvivalTag(q,'brakka')==='brakka','an invalid level did not fall back to the name');
         netOnState(NET.peers[0],{t:'st',k:'r',s:0,sd:g.seed>>>0,x:g.player.x+60,y:g.player.y,f:0,m:0,pl:5});
         netOnState(NET.peers[0],{t:'st',k:'r',s:0,sd:g.seed>>>0,x:g.player.x+60,y:g.player.y,f:0,m:0});
         need(q.pl===undefined,'an older packet retained a stale peer level');
       }
       NET.on=false; NET.role=null; NET.peers=[];
       // SEVEN: no progress, callout, packet field or bar in the demo, the simulator, or a finished raid.
       before=P.pil.lsp; g.sim=true; need(pilSurvivalAdd(100)===0&&P.pil.lsp===before,'the sim earned survival SP'); g.sim=false;
       g.over='dead'; need(pilSurvivalAdd(100)===0&&P.pil.lsp===before,'a finished raid earned survival SP'); g.over=false;
       ARCADE.on=true; g.arcade=true; g.career=false; txt=[];
       ctx.fillText=function(t){ txt.push(String(t).toLowerCase()); return oldFill.apply(this,arguments); };
       __drawHUD(); s={}; netPilLevelPut(s);
       need(!pilSurvivalOn()&&pilSurvivalLift()===0&&pilSurvivalAdd(100)===0&&P.pil.lsp===before,'the demo has survival progression');
       need(txt.indexOf('pillager survival level')<0&&s.pl===undefined&&pilSurvivalTag({pl:20},'player 2')==='player 2','the demo drew or sent a survival level');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       ctx.fillText=oldFill; wc.fillText=oldWorldFill; bar=oldBar; say=oldSay; netSendFast=oldFast; careerBoardAdd=oldBoard;
       ARCADE.on=false; NET.on=false; NET.role=null; NET.peers=[];
       try{ g=__state(); if(g&&!g.over){ g.sim=false; g.arcade=false; g.player.downed=false; g.tel.shots=0; g.tel.containers=0; g.tel.distance=0; __endRaid('abandon'); } }catch(_end){}
       P=saved; storeSet=oldStore; saveProfile=oldSave; ARCADE.on=arc; SAVE_STALE=stale; CRASH_RESTART=crash;
       if(typeof NETP2!=='undefined') NETP2=p2;
       for(k in n0) NET[k]=n0[k];
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_clean){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
