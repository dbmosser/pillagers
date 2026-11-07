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

if ($s.Contains("  {v:'37.53',what:")) { throw "check 37.53 is in the fixture already" }

SubRx @'
  {v:'37.52',what:
'@ @'
  {v:'37.53',what:'sleeping sentries and bulwarks preserve seed counts, sleep through sight, wake on noise, hits or close steps, and pause before firing',
   run:function(){
     var g,p,e,k,n=0,s=0,oFire=fireWeapon,oBoss=bossTick,oSfx=sfx,shots=0,charges=0,nk={},bad=[];
     for(k in NET) nk[k]=NET[k];
     function expect(v,m){ if(!v) bad.push(m); }
     function stage(kind){
       NET.on=false;
       e=kind==='bulwark'?mkBulwark(2250,2000):mkSentry(2250,2000);
       e.face=Math.PI; e.sleep=1; e.sleepHp=e.hp; e.state='dormant'; e.alert=0; e.cd=0;
       g.ents=[e]; p.x=2000; p.y=2000; p.downed=0; p.specOut=0; shots=0; charges=0;
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); NET.on=false;
       for(var mi=0;mi<2;mi++){
         __pinDefaults(mi); __deploy({kit:[],safe:null,mapIx:mi,seed:4242}); g=__state();
         expect(g.ents.length===(mi?374:85),'entity fingerprint '+mi+': '+g.ents.length);
         expect(g.containers.length===(mi?593:165),'container fingerprint '+mi+': '+g.containers.length);
       }
       __pinDefaults(0);
       for(var sd=1;sd<=20;sd++){
         P.mapIx=0; pendSeed=sd; G=null; G=buildRaid(true); g=G;
         for(var i=0;i<g.ents.length;i++){
           var q=g.ents[i], eligible=machineSleepCandidate(q,g.map.spawns||[]);
           if(eligible){
             n++; if(q.sleep) s++;
             var hashed=((Math.imul(Math.round(q.x),73856093)^Math.imul(Math.round(q.y),19349663)^g.seed)>>>0)%5===0;
             expect(!!q.sleep===hashed,'sleep hash at seed '+sd);
           } else expect(!q.sleep,'ineligible sleeper '+q.kind);
         }
       }
       expect(s>0&&s/n>=.1&&s/n<=.3,'sleeper share '+s+'/'+n);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); p=g.player;
       g.sim=true; g.map.walls=[]; g.map.segs=[]; g.grid=null; g.vseg=[]; g.vgrid=null; g.brl=[]; g.containers=[]; g.reinfT=1e9;
       bossTick=function(){}; fireWeapon=function(){ shots++; }; sfx=function(t){ if(t==='charge') charges++; };
       ['sentry','bulwark'].forEach(function(kind){
         stage(kind); var face=e.face,x=e.x,y=e.y;
         for(var j=0;j<300;j++) updateEnts(.01);
         expect(e.state==='dormant'&&!e.windup&&shots===0&&e.face===face&&e.x===x&&e.y===y,kind+' quiet sight woke or fired');
         g.sim=false; ping(p.x,p.y,330,false,true,'player','fire',null,true); g.sim=true;
         expect(e.state==='investigate'&&!e.sleep&&e.wakeT===.6&&e.alert===2.4&&e.tx===p.x&&charges===1,kind+' noise wake');
         for(j=0;j<59;j++) updateEnts(.01);
         expect(shots===0&&!e.windup,kind+' fired during wake beat');
         stage(kind); g.sim=false; e.hp--; updateEnts(.01); g.sim=true;
         expect(e.state==='chase'&&e.wakeT>0&&charges===1,kind+' hit wake');
         stage(kind); p.x=e.x-69; g.sim=false; updateEnts(.01); g.sim=true;
         expect(e.state==='chase'&&e.wakeT>0&&charges===1,kind+' close wake');
         updateEnts(.01); expect(charges===1,kind+' repeated charge');
         stage(kind); listenersHearInner(e.x+LISTEN_R*.6+1,e.y,1000,true);
         expect(e.state==='dormant',kind+' exceeded hearing cap');
         listenersHearInner(e.x+200,e.y,20,true); expect(e.state==='dormant',kind+' ignored loudness falloff');
         e.nid=997; var row=netEntRow(e),word=netEntNewWord(e),peer={state:'in'};
         expect(NET_ENT_STATES[row[5]]==='dormant',kind+' dormant packet');
         NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=g.seed>>>0; NET.entMap={}; NET.entLast=-1; g.ents=[]; g.sim=false;
         netEntWord(peer,word); expect(netEntsApply(peer,{sd:g.seed>>>0,n:1,e:[row]})==='ents',kind+' snapshot apply');
         var copy=NET.entMap[997];
         expect(machineAsleep(copy)&&mbEye(copy,0)[1]===0&&sprEyeOf(copy).a===0,kind+' peer lamps lit');
         row[5]=NET_ENT_STATES.indexOf('investigate'); netEntsApply(peer,{sd:g.seed>>>0,n:2,e:[row]});
         expect(!machineAsleep(copy)&&mbEye(copy,0)[1]>0,kind+' peer stayed asleep after wake');
         NET.on=false; g.sim=true;
       });
     }catch(ex){bad.push('threw: '+(ex.message||ex));}
     finally{
       fireWeapon=oFire; bossTick=oBoss; sfx=oSfx;
       for(k in NET) if(!(k in nk)) delete NET[k]; for(k in nk) NET[k]=nk[k];
       try{__endRaid('abandon');}catch(_end){} __topClear();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'37.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
