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

if ($s.Contains("  {v:'36.07',what:")) { throw "check 36.07 is in the fixture already" }

SubRx @'
  {v:'36.06',what:
'@ @'
  {v:'36.07',what:'g-84 and g-85: real Auto Rifle hits grow one number per target and colour for half a second; solo hurt draws red over you; party words keep their target id',
   run:function(){
     var g,p,e,e2,w,i,sum=0,d,bad=[],all,baseT,oNum=CFG.dmgNumbers,oOn=NET.on,oRole=NET.role,oPeers=NET.peers,oUp=netUpShared,oSend=netSendFast,oDN=dmgNum,sent=[];
     function fire(en){
       g.ents=[en]; g.bullets=[]; p.bloom=0; p.bloomK=0; p.arBonus=0;
       fireWeapon(p,w,en.x,en.y,true); updateBullets(0.1); g.bullets=[];
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       NET.on=false; __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over||g.sim) return 'no live fixture raid';
       p=g.player; all=g.ents.slice(); CFG.dmgNumbers=1; keys={}; mouse.down=false; p.iv=999; g.mapOpen=false; g.bagOpen=false;
       var ax=1,ay=0,found=false;
       for(i=0;i<16;i++){ ax=Math.cos(i*Math.PI/8); ay=Math.sin(i*Math.PI/8); if(losClear(p.x,p.y,p.x+ax*110,p.y+ay*110,g.map.segs)){ found=true; break; } }
       if(!found) return 'no clear line for the real rounds';
       e=mkSentry(p.x+ax*80,p.y+ay*80); e.hp=e.maxhp=100000; e.face=Math.atan2(ay,ax)+Math.PI; e.elite=false;
       e2=mkSentry(e.x,e.y); e2.hp=e2.maxhp=100000; e2.face=e.face; e2.elite=false;
       w=cloneObj(WEAPONS.rifle); w.spread=0; p.wep=w; p.ammo=w.mag; g.dmgN=[]; baseT=g.t;
       dmgNum=function(x,y,n,c,k,key){ if(key===e) sum+=n; return oDN.apply(this,arguments); };
       for(i=0;i<3;i++){ g.t+=0.1; tickDmgNums(0.1); fire(e); }
       dmgNum=oDN;
       d=g.dmgN[0];
       if(g.dmgN.length!==1||!d||d.key!==e||d.hits!==3||d.n!==sum||!(sum>0)) bad.push('three real rifle rounds did not merge with the true sum and hits 3 ('+g.dmgN.length+' numbers, sum '+sum+')');
       fire(e2); if(g.dmgN.length!==2) bad.push('a second sentry did not get its own number');
       g.t+=0.7; tickDmgNums(0.7); fire(e);
       if(g.dmgN.filter(function(q){return q.key===e;}).length!==2) bad.push('a hit after 0.7 seconds reused the old number');
       g.dmgN=[]; dmgNum(e.x,e.y,7,'#FFF6DC',false,e); dmgNum(e.x,e.y,9,'#ff8a3c',false,e);
       if(g.dmgN.length!==2) bad.push('different hit colours merged');
       dmgNum(e.x,e.y,5,'#FFF6DC',true,e); d=g.dmgN[0];
       if(!d.kill||d.life!==1.05||d.n!==12||d.hits!==2||d.pop!==0.12) bad.push('the added kill did not keep its total, life and pop');
       var oFill=wc.fillText,oStroke=wc.strokeText,fonts=[];
       try{ wc.fillText=function(){fonts.push(parseFloat((wc.font.match(/([\d.]+)px/)||[])[1]));};wc.strokeText=function(){};drawDmgNums(); }
       finally{wc.fillText=oFill;wc.strokeText=oStroke;}
       var want=parseFloat((FS(TYPE.head).match(/([\d.]+)px/)||[])[1])*1.06*1.25;
       if(!fonts.length||Math.abs(fonts[0]-want)>0.15) bad.push('the growing number did not draw at its hit and pop scale');
       tickDmgNums(0.06); if(Math.abs(d.pop-0.06)>0.001) bad.push('the hit pop did not ease down');
       g.dmgN=[]; dmgNum(e.x,e.y,1); dmgNum(e.x,e.y,1); if(g.dmgN.length!==2) bad.push('unkeyed hits merged');
       g.dmgN=[]; p.iv=0; p.armor=0; p.hp=100; p.downed=0; p.arcSh=0;
       damagePlayer(20,'sentry','SENTRY K',p.x+100,p.y);
       d=g.dmgN[0];
       if(!d||d.c!=='#ff5a4a'||d.key!=='self'||d.n!==p.lastDmg||Math.hypot(d.x-p.x,d.y-(p.y-26))>40) bad.push('solo damage did not draw the true red amount over your pillager');
       else { var n=d.n; p.iv=0; g.t+=0.1; tickDmgNums(0.1); damagePlayer(10,'sentry','SENTRY K',p.x+100,p.y); if(g.dmgN.length!==1||d.hits!==2||d.n!==n+p.lastDmg) bad.push('your incoming burst did not merge'); }
       CFG.dmgNumbers=0; g.dmgN=[]; p.iv=0; damagePlayer(10,'sentry','SENTRY K',p.x+100,p.y); dmgNum(p.x,p.y,10,'#ff5a4a',false,'self');
       if(g.dmgN.length) bad.push('the damage number setting did not turn numbers off');
       CFG.dmgNumbers=1; g.dmgN=[]; NET.on=true; NET.role='join'; NET.peers=[{state:'in',seat:0}];
       netUpShared=function(){return true;}; netSendFast=function(q,m){sent.push(m);return true;};
       netFxDmg(e.x,e.y,11,'#FFF6DC',false,71);
       if(!sent.length||sent[0].d[5]!==71) bad.push('the party damage word lost its target id');
       var peer={state:'in',seat:0},msg={t:'fx',k:'d',s:0,d:[e.x,e.y,11,'#FFF6DC',0,71]};
       netFxTake(peer,msg); g.t+=0.1; tickDmgNums(0.1); netFxTake(peer,msg);
       d=g.dmgN[0]; if(g.dmgN.length!==1||!d||d.key!=='p71'||d.n!==22||d.hits!==2) bad.push('received party hits did not merge');
       msg.d=msg.d.slice(0,5); netFxTake(peer,msg); netFxTake(peer,msg);
       if(g.dmgN.length!==3) bad.push('legacy party words merged without a target id');
       g.t=baseT;
     }catch(err){bad.push('threw: '+(err&&err.message||err));}
     finally{
       dmgNum=oDN; netUpShared=oUp; netSendFast=oSend; NET.on=oOn; NET.role=oRole; NET.peers=oPeers; CFG.dmgNumbers=oNum;
       try{if(g){g.dmgN=[];g.bullets=[];if(all)g.ents=all;} __endRaid('abandon');}catch(_e){} __topClear();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'36.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
