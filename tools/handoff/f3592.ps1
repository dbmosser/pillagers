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

if ($s.Contains("  {v:'35.92',what:")) { throw "check 35.92 is in the fixture already" }

SubRx @'
  {v:'35.91',what:
'@ @'
  {v:'35.92',what:'cw-cx-duosearch: every search door is 1.5 times faster with a nearby live party member, demo and career; solo, stale, downed and departed members give no bonus',
   run:function(){
     var nk=Object.assign({},NET), cfg=Object.assign({},CFG), kk=keys, md=mouse.down, bs=buzzSlow, ns=netSend, nb=netBroadcast, ax=ARCADE.xOut,
         g,p,ct,word,k,mode,door,base,fast,bad=[];
     function reset(){ ct.prog=0; ct.pulled=0; ct.opened=false; ct.loot=['bandage']; ct.time=100; ct.netBy=-1; g.searching=null; g.searchT=0; NET.srch=null; NET.srchOwn=-1; NET.holds={}; keys={}; p.downed=false; p.dying=false; p.specOut=false; p.hand=null; p.reloading=0; p.roll=0; }
     function pos(d){ word.x=ct.x+d; word.y=ct.y; word.tx=word.x; word.ty=word.y; }
     function step(which,d){
       reset(); pos(d); NET.role='host'; NET.seat=0; word.seat=1; p.x=ct.x-30; p.y=ct.y;
       if(which===0){ keys.KeyE=true; for(var n=0;n<60;n++) updatePlayer(1/60); keys={}; }
       if(which===1){ p.x=ct.x-d; word.x=ct.x+30; word.tx=word.x; NET.holds={1:{cid:ct.cid,slow:1}}; ct.netBy=1; for(var j=0;j<60;j++) netSrchTick(1/60); }
       if(which===2){ NET.role='join'; NET.seat=1; word.seat=0; G.searching=ct; NET.srch={cid:ct.cid,ok:1}; for(var t=0;t<60;t++) netSrchHold(ct,1/60); }
       return ct.prog;
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242}); g=__state(); p=g&&g.player;
       if(!p||g.over) return 'could not stage a live raid';
       __topClear(); CFG.xfPix=0; g.mapFirst=false; g.mapOpen=false; g.bagOpen=false; g.paused=false; g.legendOn=0; g.ents=[]; g.zones=[]; g.vseg=[]; p.iv=9999;
       ct=g.containers.filter(function(c){return !c.opened;})[0]; if(!ct) return 'no searchable box';
       ct.x=p.x+30; ct.y=p.y; ct.auto=false; g.containers=[ct];
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=g.seed>>>0; NET.specG=null; NET.upOut={}; NET.upHow={}; ARCADE.xOut='';
       NET.roster=[{seat:0,name:'player 1'},{seat:1,name:'player 2'}]; NET.peers=[{seat:0,state:'in'},{seat:1,state:'in'}];
       word={n:1,age:0,seat:1,sd:g.seed>>>0,hp:100,dn:0}; NET.up=[word]; netContInit(g);
       buzzSlow=function(){return 1;}; netSend=function(){return true;}; netBroadcast=function(){return 1;};
       for(mode=0;mode<2;mode++){
         g.arcade=!!mode;
         for(door=0;door<3;door++){
           base=step(door,600); fast=step(door,120);
           if(!(base>0)||Math.abs(fast/base-1.5)>0.00001) bad.push('mode '+mode+' door '+door+': '+fast+' / '+base+' is not 1.5');
         }
       }
       g.arcade=false; reset(); NET.role='host'; NET.seat=0; word.seat=1; pos(120); p.x=ct.x-30;
       if(typeof duoAt!=='function') return bad.join('; ')||'duoAt missing';
       if(!duoAt(ct,0)) bad.push('fresh nearby partner missing');
       word.age=NET_HUB_STALE; if(duoAt(ct,0)) bad.push('stale partner helped'); word.age=0;
       word.sd=4243; if(duoAt(ct,0)) bad.push('other seed helped'); word.sd=4242;
       word.dn=1; if(duoAt(ct,0)) bad.push('downed partner helped'); word.dn=0;
       word.hp=0; if(duoAt(ct,0)) bad.push('dead partner helped'); word.hp=100;
       word.specOut=1; if(duoAt(ct,0)) bad.push('spectator helped'); word.specOut=0;
       word.xo=1; if(duoAt(ct,0)) bad.push('extracted partner helped'); word.xo=0;
       NET.upOut[1]=4242; if(duoAt(ct,0)) bad.push('departed partner helped'); NET.upOut={};
       pos(200); if(!duoAt(ct,0)) bad.push('200 radius excluded'); pos(201); if(duoAt(ct,0)) bad.push('outside radius helped');
       NET.up=[]; if(duoAt(ct,0)) bad.push('solo helped'); NET.up=[word];
       if(!duoAt(ct,1)) bad.push('nearby host did not help partner');
       p.downed=true; if(duoAt(ct,1)) bad.push('downed host helped'); p.downed=false;
       p.specOut=true; if(duoAt(ct,1)) bad.push('spectating host helped'); p.specOut=false;
       NET.on=false; if(duoAt(ct,0)) bad.push('offline bonus');
       base=step(0,120); if(Math.abs(base-1)>0.00001) bad.push('solo search speed changed: '+base);
       return bad.length?bad.join('; '):null;
     }finally{
       keys={}; if(g) g.searching=null;
       try{__endRaid('abandon');}catch(_e){} __topClear();
       Object.keys(NET).forEach(function(n){delete NET[n];}); Object.assign(NET,nk);
       Object.assign(CFG,cfg); ARCADE.xOut=ax; buzzSlow=bs; netSend=ns; netBroadcast=nb; keys=kk; mouse.down=md;
     }
   }},
  {v:'35.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
