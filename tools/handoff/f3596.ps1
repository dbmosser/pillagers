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

if ($s.Contains("  {v:'35.96',what:")) { throw "check 35.96 is in the fixture already" }

SubRx @'
  {v:'35.95',what:
'@ @'
  {v:'35.96',what:'cw-cx-bothsearch: both search inputs required at the same or adjacent box, immediate release/menu/down/range changes, all three doors and both packet directions, demo and career',
   run:function(){
     var nk=Object.assign({},NET), cfg=Object.assign({},CFG), kk=keys, md=mouse.down, bs=buzzSlow, ns=netSend, nf=netSendFast, nb=netBroadcast, ax=ARCADE.xOut,
         g,p,ct,beside,word,mode,door,base,fast,peer,packets=[],bad=[];
     function reset(){
       ct.prog=0; ct.pulled=0; ct.opened=false; ct.loot=['bandage']; ct.time=100; ct.netBy=-1;
       g.searching=null; g.searchT=0; NET.srch=null; NET.srchOwn=-1; NET.holds={}; NET.role='host'; NET.seat=0;
       keys={KeyE:true}; p.x=ct.x-30; p.y=ct.y; p.downed=false; p.dying=false; p.specOut=false; p.roll=0; p.hp=100;
       g.paused=false; g.bagOpen=false; g.mapOpen=false; g.mapFirst=false; g.trade=null; g.forgeUI=null; g.wheel=null; g.legendOn=0;
       word.seat=1; word.x=ct.x+30; word.y=ct.y; word.tx=word.x; word.ty=word.y; word.shold=0; word.pz=0; word.dn=0; word.hp=100; word.age=0; NET.up=[null,word];
     }
     function tick(which){
       var before=ct.prog;
       if(which===0) updatePlayer(1/60);
       if(which===1){ ct.netBy=1; NET.holds={1:{cid:ct.cid,slow:1}}; netSrchTick(1/60); }
       if(which===2){ NET.role='join'; NET.seat=1; word.seat=0; g.searching=ct; NET.srch={cid:ct.cid,ok:1}; netSrchHold(ct,1/60); }
       return ct.prog-before;
     }
     function ratio(got,want,label){ if(Math.abs(got/base-want)>0.00001) bad.push(label+': '+got/base+' expected '+want); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242}); g=__state(); p=g&&g.player;
       if(!p||g.over) return 'could not stage a live raid';
       __topClear(); CFG.xfPix=0; g.ents=[]; g.zones=[]; g.vseg=[]; p.iv=9999;
       ct=g.containers.filter(function(c){return !c.opened;})[0]; if(!ct) return 'no searchable box';
       ct.x=p.x+30; ct.y=p.y; ct.auto=false;
       beside={cid:99999,x:ct.x+100,y:ct.y,time:100,prog:0,opened:false,loot:['bandage'],auto:false}; g.containers=[ct,beside];
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=g.seed>>>0; NET.specG=null; NET.upOut={}; NET.upHow={}; ARCADE.xOut='';
       NET.roster=[{seat:0,name:'player 1'},{seat:1,name:'player 2'}]; NET.peers=[{seat:0,state:'in'},{seat:1,state:'in'}];
       word={n:1,age:0,seat:1,sd:g.seed>>>0,hp:100,dn:0,f:0,tf:0,bob:0,x:ct.x+30,y:ct.y}; netContInit(g);
       buzzSlow=function(){return 1;}; netSend=function(){return true;}; netBroadcast=function(){return 1;};
       netSendFast=function(q,m){packets.push(JSON.parse(JSON.stringify(m)));return true;};
       for(mode=0;mode<2;mode++){
         g.arcade=!!mode;
         for(door=0;door<3;door++){
           reset(); base=tick(door); if(!(base>0)) return 'no baseline for door '+door;
           if(Math.abs(base-(g.arcade?ARCADE_SRCH:1)/60)>0.00001) bad.push('standing partner changed base speed door '+door);
           word.shold=1; fast=tick(door); ratio(fast,1.5,'same box door '+door);
           word.x=beside.x+10; word.tx=word.x; ratio(tick(door),1.5,'adjacent box door '+door);
           word.shold=0; ratio(tick(door),1,'released same tick door '+door);
           word.shold=1; word.pz=1; ratio(tick(door),1,'remote menu door '+door); word.pz=0;
           word.dn=1; ratio(tick(door),1,'remote downed door '+door); word.dn=0;
           word.tx=ct.x+201; ratio(tick(door),1,'latest remote position door '+door); word.tx=ct.x+30;
           delete word.shold; ratio(tick(door),1,'older packet door '+door);
         }
       }
       reset(); word.shold=1; ct.netBy=1; g.searching=null;
       if(!duoAt(ct,1)) bad.push('host input on occupied same box refused');
       keys={}; if(duoAt(ct,1)) bad.push('host release retained bonus');
       keys={PadSearch:true}; if(!duoAt(ct,1)) bad.push('pad search did not help');
       g.bagOpen=true; if(duoAt(ct,1)) bad.push('host backpack still helped'); g.bagOpen=false;
       g.paused=true; if(duoAt(ct,1)) bad.push('host menu still helped'); g.paused=false;
       p.downed=true; if(duoAt(ct,1)) bad.push('downed host helped'); p.downed=false;
       p.x=ct.x-100; if(duoAt(ct,1)) bad.push('holding E without a reachable box helped'); p.x=ct.x-30;
       reset(); peer=NET.peers[1]; NET.up=[]; packets=[];
       if(netOnState(peer,{t:'st',k:'r',sd:g.seed,x:ct.x+30,y:ct.y,hp:100,shold:1})!=='state'||NET.up[1].shold!==1||!duoAt(ct,0)) bad.push('host did not receive held input');
       if(!packets.some(function(m){return m.shold===1;})) bad.push('host did not forward held input');
       netOnState(peer,{t:'st',k:'r',sd:g.seed,x:ct.x+30,y:ct.y,hp:100,shold:0});
       if(duoAt(ct,0)||!packets.some(function(m){return m.shold===0;})) bad.push('host release/forward delayed');
       NET.role='join'; NET.seat=1; NET.up=[];
       netOnState(NET.peers[0],{t:'st',s:0,k:'r',sd:g.seed,x:ct.x+30,y:ct.y,hp:100,shold:1});
       if(!duoAt(ct,1)) bad.push('partner did not receive host held input');
       netOnState(NET.peers[0],{t:'st',s:0,k:'r',sd:g.seed,x:ct.x+30,y:ct.y,hp:100});
       if(duoAt(ct,1)) bad.push('missing held bit retained old input');
       for(door=0;door<2;door++){
         reset(); NET.role=door?'join':'host'; NET.seat=door; NET.up=[]; NET.upAcc=0; NET.upHold=0; packets=[];
         netUpTick(0); if(!packets.some(function(m){return m.k==='r'&&m.shold===1;})) bad.push('press not sent this frame role '+door);
         keys={}; packets=[]; netUpTick(0); if(!packets.some(function(m){return m.k==='r'&&m.shold===0;})) bad.push('release not sent this frame role '+door);
       }
       return bad.length?bad.join('; '):null;
     }finally{
       keys={}; if(g) g.searching=null;
       try{__endRaid('abandon');}catch(_e){} __topClear();
       Object.keys(NET).forEach(function(n){delete NET[n];}); Object.assign(NET,nk);
       Object.assign(CFG,cfg); ARCADE.xOut=ax; buzzSlow=bs; netSend=ns; netSendFast=nf; netBroadcast=nb; keys=kk; mouse.down=md;
     }
   }},
  {v:'35.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
