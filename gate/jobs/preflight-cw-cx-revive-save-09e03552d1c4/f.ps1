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

if ($s.Contains("  {v:'37.51',what:")) { throw "check 37.51 is in the fixture already" }

SubRx @'
  {v:'37.50',what:
'@ @'
  {v:'37.51',what:'bandages halve confirmed team pick-ups, fresh revive words hold bleed time, five-second alerts sound once and risky saves pay a medal',
   run:function(){
     var nk=Object.assign({},NET), kk=keys, cp=Object.assign({},CFG), xx=Object.assign({},XF), oldSend=netSend, oldFast=netSendFast, oldAc=ac, oldBus=sndBus, oldR=padRumble,
         sd=Object.assign({},SND_DOWN), bad=[], sent=[], relayed=[], tones=[], rumbles=0, p, g, peer, i, score0;
     function ok(v,m){ if(!v) bad.push(m); }
     function mate(dn){ NET.up[1]={seat:1,x:p.x+30,y:p.y,tx:p.x+30,ty:p.y,f:0,n:5,age:0,dn:dn?1:0,hp:dn?0:40,mh:100,sd:NET.upSeed>>>0}; }
     function reset(band){ G.bag=band?['bandage']:[]; G.netRevT=0; G.netRevS=-1; G.netRevDone=-1; G.netRevWait=-1; G.netRevBand=0; sent=[]; mate(1); keys={KeyE:true}; p.hurtAt=-99; }
     function step(dt){ G.t+=dt; netRevHold(p,dt); }
     function revs(){ return sent.filter(function(m){return m.t==='rev';}).length; }
     function word(dn,dt,rg){ return {t:'st',k:'r',s:1,x:p.x+30,y:p.y,f:0,sd:G.seed>>>0,dn:dn,hp:dn?0:40,dt:dt,rg:rg}; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=G; p=g.player;
       G.sim=0; G.over=false; p.wm=null; p.downed=false; p.roll=0; G.t=100; G.ents=[]; G.arcade=false; G.career=true; G.cs={s:0}; G.dmul=1; CFG.superhot=1; XF.xfStyle=1; CFG.volAlarm=1;
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.up=[]; NET.max=4; NET.specTick=false;
       peer={state:'in',seat:1}; NET.peers=[peer,{state:'in',seat:2}];
       NET.roster=[{seat:0,name:'test one'},{seat:1,name:'test two'},{seat:2,name:'test three'}];
       netSend=function(q,m){sent.push(m);return true;}; netSendFast=function(q,m){relayed.push(m);return true;};
       reset(true); step(1.7); ok(revs()===1,'bandage did not send by 1.7 s'); ok(G.bag.length===1,'bandage spent before confirmation');
       mate(0); step(0); ok(G.bag.indexOf('bandage')<0,'confirmed pick-up did not spend bandage');
       reset(true); step(0.8); keys={}; step(0); ok(G.bag.length===1,'interrupted hold spent bandage');
       reset(true); step(1.7); keys={}; step(NET_HUB_STALE+0.1); ok(G.bag.length===1&&!G.netRevBand,'unconfirmed pick-up spent or retained its cost');
       reset(false); step(1.7); ok(!revs(),'free pick-up sent by 1.7 s'); step(1.51); ok(revs()===1,'free pick-up did not send by 3.2 s');
       NET.role='join'; NET.peers=[peer]; reset(true); step(0.8); NET.upAcc=1; relayed=[]; netUpTick(0);
       ok(relayed.some(function(m){return m.t==='st'&&m.rg===1;}),'outgoing state has no active revive target');
       step(0.9); ok(revs()===1,'joining reviver did not send bandage pick-up'); mate(0); step(0); ok(!G.bag.length,'joining reviver did not spend confirmed bandage');
       NET.upAcc=1; relayed=[]; netUpTick(0); ok(relayed.some(function(m){return m.t==='st'&&!Object.prototype.hasOwnProperty.call(m,'rg');}),'finished hold still publishes rg');
       NET.role='host'; NET.peers=[peer,{state:'in',seat:2}];
       reset(false); p.downed=true; p.downT=10; NET.up[1].dn=0; NET.up[1].rg=NET.seat;
       tickDowned(2); ok(p.downT===10,'fresh revive word did not pause bleed');
       NET.up[1].rg=-1; tickDowned(2); ok(p.downT===8,'bleed did not resume without rg');
       p.downT=10; NET.up[1].rg=NET.seat; NET.up[1].age=0.4; tickDowned(2); ok(p.downT===8,'stale word held bleed');
       NET.up[1].age=0; NET.up[1].x=p.x+100; p.downT=10; tickDowned(2); ok(p.downT===8,'distant word held bleed'); p.downed=false;
       ac=function(){return {currentTime:0,createOscillator:function(){var o={type:'',frequency:{setValueAtTime:function(f,t){tones.push({f:f,t:t,o:o});}},connect:function(){},start:function(){},stop:function(){}};return o;},createGain:function(){return {gain:{setValueAtTime:function(){},exponentialRampToValueAtTime:function(){}},connect:function(){}};}};};
       sndBus=function(){return {};}; padRumble=function(a,t){if(a===0.8&&t===300)rumbles++;};
       mate(1); NET.up[1].dt=6; SND_DOWN.late=0;
       netOnState(peer,word(1,6,0)); netOnState(peer,word(1,5,0)); netOnState(peer,word(1,4,0));
       ok(SND_DOWN.late===1&&rumbles===1,'late alert did not fire exactly once');
       ok(tones.length===6&&tones.every(function(n,j){return n.f===(j%2?990:1320)&&Math.abs(n.t-j*0.09)<0.00001&&n.o.type==='square';}),'late alert notes differ');
       ok(NET.up[1].rg===0&&relayed.some(function(m){return m.t==='st'&&m.rg===0;}),'revive target not stored and relayed');
       netOnState(peer,word(0,0)); ok(NET.up[1].rg===-1&&!NET.up[1].revLate,'up word did not clear hold and late latch');
       netOnState(peer,word(1,6)); netOnState(peer,word(1,5)); ok(SND_DOWN.late===2,'second fall did not rearm late alert');
       CFG.volAlarm=0; ok(sndMateLate()===false&&SND_DOWN.late===2,'muted alarms played late alert'); CFG.volAlarm=1;
       G.sim=1; ok(sndMateLate()===false&&SND_DOWN.late===2,'simulation played late alert'); G.sim=0;
       ac=oldAc; sndBus=oldBus; padRumble=oldR;
       reset(false); G.sty=null; step(1); p.hurtAt=G.t; step(2.21); score0=G.cs.s; mate(0); step(0);
       ok(styS().pops.some(function(x){return x.txt==='SAVE'&&x.pts===150;}),'risky confirmed pick-up has no 150 sp save');
       ok(G.cs.s-score0===150,'save did not add 150 to run score');
       reset(false); G.sty=null; step(3.21); mate(0); step(0); ok(!styS().pops.some(function(x){return x.txt==='SAVE';}),'quiet pick-up paid save');
       reset(false); G.sty=null; step(3.21); G.ents=[{kind:'crawler',hp:20,state:'hunt',x:p.x+699,y:p.y}]; mate(0); step(0);
       ok(styS().pops.some(function(x){return x.txt==='SAVE';}),'nearby hunting hostile did not pay save');
       reset(false); G.sty=null; XF.xfStyle=0; step(1); p.hurtAt=G.t; step(2.21); mate(0); step(0); ok(!styS().pops.length,'style off paid save');
       ok(STY_TIER.SAVE===2&&!!STY_ICON.SAVE,'save emblem or tier missing');
       return bad.length?bad.join('; '):null;
     }finally{
       netSend=oldSend; netSendFast=oldFast; ac=oldAc; sndBus=oldBus; padRumble=oldR; keys=kk;
       Object.assign(NET,nk); Object.assign(CFG,cp); Object.assign(XF,xx); Object.assign(SND_DOWN,sd);
       try{ __endRaid('abandon'); }catch(_e){} __topClear();
     }
   }},
  {v:'37.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
