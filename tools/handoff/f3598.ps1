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

if ($s.Contains("  {v:'35.98',what:")) { throw "check 35.98 is in the fixture already" }

SubRx @'
  {v:'35.97',what:
'@ @'
  {v:'35.98',what:'two player run over keeps crown and shows lowest health survived and actual total damage in both seats',
   run:function(){
     var sv, src, tried, bk, oldPost, messages=[], g, p, e, c, tx, end, b1, b2, id, bad=[];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(typeof arcadeBmDamage!=='function'||typeof arcadeBmHealth!=='function') return 'closest call and damage tracking are missing';
       bk=localStorage.getItem(ARCADE_BOARD_KEY); sv={bc:NET.bc,same:NET.same,pair:NET.pair,on:NET.on,role:NET.role,upSeed:NET.upSeed,entMap:NET.entMap};
       src=ATT.src; tried=ATT.tried; ATT.src=null; ATT.tried=true;
       oldPost=netSamePost; netSamePost=function(m){messages.push(m);return true;};
       NET.bc={postMessage:function(){},close:function(){}}; NET.same='host'; NET.pair='moments'; NET.on=false;
       if(!arcadeEnter('host')||!arcadeDeploy({mapIx:0,seed:4242})) return 'could not stage demo';
       g=__state(); p=g.player; id=ARCADE.run.id; ARCADE.solo=0;
       p.arcSh=0; p.iv=0; p.armor=0; p.hp=40; p.downed=false; p.dying=false; g.pwr={};
       CFG.eDmg=1; ARCADE.easy=0;
       damagePlayer(5,'fire','fire',p.x+80,p.y);
       if(!(p.hp>0&&p.hp<40&&ARCADE.bm.cc===p.hp)) bad.push('a survived hit was not recorded at actual health');
       var health=ARCADE.bm.cc;
       p.hp=0; arcadeBmHealth(p); p.hp=1; p.downed=true; arcadeBmHealth(p); p.downed=false; p.hp=100;
       if(ARCADE.bm.cc!==health) bad.push('zero or downed health displaced a survived hit');
       e={x:p.x+60,y:p.y,r:12,hp:30,kind:'crawler',finished:false};
       finishHim(p,e);
       if(ARCADE.bm.dm!==30) bad.push('finisher damage did not cap at remaining health');
       e={x:p.x+80,y:p.y,r:12,hp:100,kind:'crawler',burnT:1,burnDps:10,burnBy:0};
       g.ents=[e]; elemTick(0.5);
       if(ARCADE.bm.dm!==35||e.hp!==95) bad.push('element damage not counted once');
       arcadeBmDamage({hp:100,merc:true},40,0); arcadeBmDamage({hp:100},40,-1);
       if(ARCADE.bm.dm!==35) bad.push('hire or environmental damage counted');
       e.hp=50; NET.on=true; NET.role='host'; NET.upSeed=g.seed; NET.entMap={7:e};
       netShotTake({state:'in',seat:1},{id:7,dmg:500});
       if(!ARCADE.mateBm||ARCADE.mateBm.dm!==50) bad.push('partner shot did not count actual damage');
       NET.on=false;
       arcadeScTake({run:id,s:200,k:1,x:0,bm:[4,100,70,7,9999]});
       if(ARCADE.mateBm.dm!==50) bad.push('peer could replace authoritative damage');
       ARCADE.mine=400; ARCADE.mate=200; ARCADE.kills=2;
       b1=arcadeBmFinal();
       if(b1.cc.v!==7||b1.cc.who!=='p2'||b1.dm.v!==50||b1.dm.who!=='p2'||b1.cr.v!==400||b1.cr.who!=='p1') bad.push('wrong winner or total');
       arcadeRunEnd('idle'); end=messages.filter(function(m){return m.t==='arcend';}).pop();
       if(!end||!end.bm||end.bm.dm.v!==50) bad.push('final moments missing from run end message');
       ARCADE.ini=null; ARCADE.over.at=Date.now()-3000; arcadeAttShow();
       c=document.querySelector('#attract .arcover'); tx=c?c.textContent.toLowerCase():'';
       if(tx.indexOf('crown')<0||tx.indexOf('closest call')<0||tx.indexOf('7 hp')<0||tx.indexOf('most damage')<0) bad.push('host card lacks the three callouts');
       ARCADE.role='p2'; ARCADE.mine=200; ARCADE.mate=400; ARCADE.bm={st:0,hl:0,ls:0,cc:90,dm:0}; ARCADE.mateBm=null;
       arcadeOverMirror(end); b2=ARCADE.over.bm;
       if(JSON.stringify(b1)!==JSON.stringify(b2)) bad.push('player 2 snapshot differs from host');
       ARCADE.over.at=Date.now()-3000; arcadeAttShow();
       c=document.querySelector('#attract .arcover'); tx=c?c.textContent.toLowerCase():'';
       if(tx.indexOf('closest call')<0||tx.indexOf('7 hp')<0||tx.indexOf('most damage')<0) bad.push('player 2 card lacks moments');
       ARCADE.role='host'; ARCADE.bm=arcadeBmNew(); ARCADE.mateBm=arcadeBmNew();
       ARCADE.bm.cc=ARCADE.mateBm.cc=7; ARCADE.bm.dm=ARCADE.mateBm.dm=50;
       var tie=arcadeBmFinal(); if(tie.cc.who!=='p1 + p2'||tie.dm.who!=='p1 + p2') bad.push('ties not shared');
       if(arcadeBmTake([1,2,3]).cc!==0||arcadeBmTake([1,2,3]).dm!==0) bad.push('old score words are not compatible');
       if(!arcadeDeploy({mapIx:0,seed:4242})||ARCADE.bm.cc||ARCADE.bm.dm||ARCADE.mateBm) bad.push('new run kept moments');
       return bad.length?bad.join('; '):null;
     }finally{
       if(oldPost) netSamePost=oldPost;
       try{ARCADE.over=null;ARCADE.ini=null;if(ARCADE.on) arcadeLeave();}catch(_l){}
       try{__endRaid('abandon');}catch(_e){}
       if(sv){NET.bc=sv.bc;NET.same=sv.same;NET.pair=sv.pair;NET.on=sv.on;NET.role=sv.role;NET.upSeed=sv.upSeed;NET.entMap=sv.entMap;ATT.src=src;ATT.tried=tried;}
       if(bk===null)localStorage.removeItem(ARCADE_BOARD_KEY);else if(bk!==undefined)localStorage.setItem(ARCADE_BOARD_KEY,bk);
       __topClear();
     }
   }},
  {v:'35.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
