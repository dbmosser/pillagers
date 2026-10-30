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

if ($s.Contains("  {v:'36.64',what:")) { throw "check 36.64 is in the fixture already" }

SubRx @'
  {v:'36.63',what:
'@ @'
  {v:'36.64',what:'golden enemies bolt on damage without attacking, recover after 3.5 s, and stay despite haul, empty map, arcade cull or convoy departure',
   run:function(){
     var g=null,p,e,b,c,px,py,a,x,y,i,j,found=false,bul,sm,role,oldPeer=flowPeer,oldAway=evBodyAway;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no raid';
       p=g.player; keys={}; mouse.down=false; p.iv=9999;
       g.ents=[]; g.containers=[]; g.bossDone=1;
       for(y=350;y<WORLD_H-350&&!found;y+=120) for(x=350;x<WORLD_W-900&&!found;x+=120){
         if(!navReachable(g.map,x,y)) continue;
         found=true;
         for(j=0;j<=15;j++) if(!spotFree(g.map,x+j*60,y,24)){ found=false; break; }
         if(found){ px=x; py=y; }
       }
       if(!found) return 'staging: no 900 unit clear chase lane';
       p.x=px; p.y=py; p.face=0;
       e=goldMake(mkCrawler(px+200,py)); e.state='chase'; e.tx=px; e.ty=py; e.alert=3; e.affix=null;
       g.ents=[e]; e.hp*=0.8; bul=g.bullets.length;
       for(i=0;i<60;i++){ g.navBudget=4; updateEnts(1/60); }
       if(!(e.gRunT>0)||dist(e,p)<300) return 'golden crawler failed to open 100 units in one second: '+dist(e,p);
       if(g.bullets.length!==bul) return 'golden fired during its flee turn';
       for(i=0;i<150;i++){ g.navBudget=4; updateEnts(1/60); }
       if(e.gRunT>0||!(e.gRunCd>4.9)||e.state!=='chase'||e.alert<2.55) return 'flee did not end in a five second cooldown and chase';
       e.hp-=1; g.navBudget=4; updateEnts(1/60);
       if(e.gRunT>0) return 'a cooldown hit restarted the flee';
       e.gRunCd=0; e.hp-=1; g.navBudget=4; updateEnts(1/60);
       if(!(e.gRunT>0)) return 'a later hit did not restart the flee';
       b=goldMake(mkRaider(px+500,py)); b.hostile=true; b.hp=b.maxhp*0.25; b.gHp=b.hp; b.looted=CFG.raiderHaul; b.state='loot'; b.bag=[]; b.healQ=0;
       g.ents=[b]; sm=g.smokes.length;
       p.downed=true;
       for(i=0;i<1200;i++){ g.navBudget=4; updateEnts(1/60); if(b.state==='extract'||g.ents.indexOf(b)<0) return 'hurt full-haul golden left at frame '+i; }
       p.downed=false;
       if(g.smokes.length!==sm) return 'hurt golden dropped smoke';
       b.state='loot'; b.goal=null; g.navBudget=4; updateEnts(1/60);
       if(b.state==='extract') return 'empty map sent a golden to extract';
       e=goldMake(mkCrawler(px+200,py)); e.hp-=1; flowPeer=function(){return true;};
       if(goldRunTick(e,1)||e.gRunT>0) return 'peer owns a golden flee';
       flowPeer=oldPeer;
       evBodyAway=function(){return true;}; g.ents=[e]; e.carrier=1;
       convoyLeave({d:{crew:[e]}});
       if(g.ents.indexOf(e)<0||e.carrier) return 'convoy removed a golden crew member';
       evBodyAway=oldAway;
       goldS().ref=e; goldS().dead=0; g.ents=[]; j=g.containers.length;
       goldTick(0.01);
       if(g.containers.length!==j||goldS().dead) return 'a missing living golden paid a hoard';
       e.hp=0; goldTick(0.01); goldTick(0.01);
       if(g.containers.length!==j+1||!goldS().dead) return 'a real golden death did not pay exactly one hoard';
       __endRaid('abandon'); __topClear(); __runPrep();
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: no demo';
       g=__state(); role=ARCADE.role; ARCADE.role='host';
       p=g.player; e=goldMake(mkCrawler(p.x+2300,p.y)); e.arcWave=1; e.state='patrol';
       c=mkCrawler(p.x-2300,p.y); c.arcWave=1; c.state='patrol'; g.ents=[e,c];
       arcadeCullTick(70);
       if(g.ents.indexOf(e)<0) return 'demo culled a living golden';
       if(g.ents.indexOf(c)>=0) return 'staging: ordinary far wave body was not culled';
       return null;
     } finally {
       flowPeer=oldPeer; evBodyAway=oldAway;
       if(g&&g.player) g.player.downed=false;
       if(role!==undefined) ARCADE.role=role;
       try{ if(ARCADE.on) arcadeLeave(); }catch(_al){}
       try{ __endRaid('abandon'); }catch(_er){}
       __topClear();
     } }},
  {v:'36.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
