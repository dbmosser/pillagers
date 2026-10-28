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

if ($s.Contains("  {v:'35.59',what:")) { throw "check 35.59 is in the fixture already" }

SubRx @'
  {v:'35.58',what:
'@ @'
  {v:'35.59',what:'a partner bullet jolts along its travel direction in both seats, with unchanged damage, position, jolt size and fade',
   run:function(){
     var NK={}, k, g, e, p, row, cp, s, r, x, y, hp, oSend=netSend, oFast=netSendFast, oRay=rayHitG, walls, brl, origEnts, bad=[];
     for(k in NET) NK[k]=NET[k];
     function left(body,tag){ var v=animHitShift(body); if(!v||Math.abs(v.x+8)>0.02||Math.abs(v.y)>0.02) bad.push(tag+' '+JSON.stringify(v)); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       NET.on=false; NET.role=null; NET.peers=[];
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'no live fixture raid';
       p=g.player; e=g.ents.filter(function(b){return b.kind==='crawler'&&b.hp>0;})[0];
       if(!e) return 'no crawler to shoot';
       origEnts=g.ents; g.ents=[e]; e.x=p.x+100; e.y=p.y; e.hp=e.maxhp=1000; e.armor=0; e.affix=null;
       e.nid=9101; e.nIn=1; e.nT=0; x=e.x; y=e.y;
       netSend=netSendFast=function(){return true;};
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=g.seed>>>0; NET.entMap={9101:e}; NET.peers=[{seat:1,state:'in'}]; NET.up=[]; NET.specG=null;
       hp=e.hp;
       r=netShotTake(NET.peers[0],{t:'shot',id:9101,dmg:10,a:Math.PI,x:e.x+100,y:e.y,sk:1});
       if(r!=='shot'||e.hp!==hp-10) bad.push('partner damage changed: '+r+' '+e.hp);
       left(e,'host saw partner shot toward shooter');
       if(e.x!==x||e.y!==y) bad.push('jolt moved simulation position');
       row=JSON.parse(JSON.stringify(netEntRow(e)));
       cp=Object.assign({},e); delete cp.hitJoltA; delete cp.hitJoltUntil; cp.hitT=0; cp.nIn=1; cp.nT=0;
       g.ents=[cp]; NET.entMap={9101:cp}; NET.role='join'; NET.seat=1; NET.peers=[{seat:0,state:'in'}]; NET.entLast=0; NET.entGone={};
       r=netEntsApply(NET.peers[0],{sd:g.seed>>>0,n:1,e:[row]});
       if(r!=='ents') bad.push('partner snapshot refused '+r);
       left(cp,'linked window lost partner bearing');
       p.x=e.x+100; left(cp,'bearing changed with viewer position');
       cp.hitT=.08; s=animHitShift(cp); if(!s||Math.abs(s.x+4)>0.02) bad.push('half flash no longer 4 px');
       cp.hitT=0; if(animHitShift(cp)!==null) bad.push('jolt after flash');
       g.t+=1; cp.hitT=.16; if(typeof animHitAngle==='function'&&animHitAngle(cp)!==null) bad.push('old bearing leaked to another hit');
       // Exercise the actual local collision path with a round moving left, opposite the viewer-to-body vector.
       NET.on=false; p.x=x-100; g.ents=[e]; e.x=x; e.y=y; e.hp=1000; e.hitT=0;
       walls=g.map.walls; brl=g.brl; g.map.walls=[]; g.brl=[]; CFG.destruct=0; rayHitG=function(){return 1e9;};
       g.bullets=[{x:x+5,y:y,vx:-100,vy:0,dmg:10,life:1,player:true,owner:p}];
       updateBullets(.01); left(e,'local player collision did not record incoming round');
       if(e.hp!==990||e.x!==x||e.y!==y) bad.push('local hit damage or position changed');
       e.hitT=0; g.bullets=[{x:x+5,y:y,vx:-100,vy:0,dmg:10,life:1,player:false,owner:{kind:'raider',name:'fixture',x:x+100,y:y}}];
       updateBullets(.01); left(e,'bot round used this window player');
       if(e.hp!==980) bad.push('bot round damage changed');
       // A zero-radian bearing must survive JSON and snapshots as a real direction.
       NET.on=true; NET.role='host'; NET.upSeed=g.seed>>>0; NET.entMap={9101:e}; e.hitT=0;
       netShotTake({seat:1,state:'in'},{t:'shot',id:9101,dmg:10,a:0,x:x-100,y:y,sk:1});
       row=JSON.parse(JSON.stringify(netEntRow(e))); cp.hitT=0;
       NET.role='join'; NET.entMap={9101:cp}; g.ents=[cp]; NET.entLast=0;
       netEntsApply({seat:0,state:'in'},{sd:g.seed>>>0,n:2,e:[row]});
       s=animHitShift(cp); if(!s||Math.abs(s.x-8)>0.02||Math.abs(s.y)>0.02) bad.push('zero bearing lost in snapshot');
     }catch(ex){bad.push('threw: '+(ex&&ex.message||ex));}
     finally{
       netSend=oSend; netSendFast=oFast; rayHitG=oRay;
       if(g){if(walls)g.map.walls=walls; if(brl)g.brl=brl; if(origEnts)g.ents=origEnts; g.bullets=[];}
       for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k];
       try{__endRaid('abandon');}catch(_e){} __topClear(); __resetCfg();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'35.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
