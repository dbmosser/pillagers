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

if ($s.Contains("  {v:'37.56',what:")) { throw "check 37.56 is in the fixture already" }

SubRx @'
  {v:'37.55',what:
'@ @'
  {v:'37.56',what:'a quarter of elite pillagers hold a takeable MK III element gun, without extra random draws; body and held gun forge cross the party words',
   run:function(){
     var oldR=RNGS, oldCfg={rate:CFG.eliteRate,guns:CFG.eliteGuns}, total=0, forged=0, sample=null, i,j,e,before,expect,g,p,c,copy,k,el,other,w,all,ct,role,nb;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_rifle','gun_shotgun'],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; CFG.eliteRate=.08; CFG.eliteGuns=1;
       for(i=1;i<=200;i++){
         srand(i);
         for(j=0;j<64;j++){
           before=RNGS; rr(); rr(); expect=RNGS; RNGS=before;
           e=blessElite({kind:'raider',hp:100,maxhp:100,r:16,wep:WEAPONS.rifle});
           if(RNGS!==expect) return 'elite blessing changed the random stream';
           if(!e.elite) continue;
           total++;
           if(e.wep.fk===2&&ELEM[e.wep.el]){ forged++; if(e.dmg!==e.wep.dmg||e.wep.tint!==ELEM[e.wep.el].c) return 'elite damage or tint differs from its forged gun'; if(!sample) sample=e.wep; }
         }
       }
       if(!sample||forged/total<.15||forged/total>.35) return 'forged elite share '+forged+'/'+total+' is outside 15 to 35 percent';
       e=mkRaider(p.x+80,p.y); e.elite=1; e.wep=sample; e.dmg=sample.dmg; e.noGunDrop=null; e.paidRevive=0; e.bag=[];
       k='gun_'+sample.id; el=sample.el; g.ents=[e];
       nb=g.bullets.length; fireWeapon(e,e.wep,p.x,p.y,false);
       if(g.bullets.length<=nb) return 'forged elite fired no round';
       for(i=nb;i<g.bullets.length;i++) if(g.bullets[i].el||g.bullets[i].tint!==ENEMY_TRACER) return 'enemy round gained an element or lost warning red';
       e.hp=0; e.finished=1; e.downed=0; e.byPlayer=true;
       updateEnts(0);
       c=g.containers.filter(function(x){return x.type==='body'&&x.fallen===e.name;}).pop();
       if(!c||!c.fw||c.fw.gk!==k||c.fw.fk!==2||c.fw.el!==el||c.loot.indexOf(k)<0) return 'death did not preserve the held forged gun';
       c.cid=999;
       copy=netContMake(999,JSON.parse(JSON.stringify(netContNewWord(c))));
       if(!copy||!copy.fw||copy.fw.gk!==k||copy.fw.el!==el||copy.fw.fk!==2) return 'party body word lost the forge';
       w={kind:'raider'}; netEntFill(w,JSON.parse(JSON.stringify(netEntNewWord(e))));
       if(!w.wep||w.wep.fk!==2||w.wep.el!==el||w.wep.tint!==sample.tint) return 'party held gun lost the element tint';
       other=k==='gun_shotgun'?'gun_rifle':'gun_shotgun';
       for(role=0;role<2;role++){
         ct=role?copy:c;
         p.wep=WEAPONS.rifle; p.sec=WEAPONS.shotgun; g.bag=[]; g.stowQ={};
         openContainer(ct,[other,k,k]);
         all=[p.wep,p.sec]; Object.keys(g.stowQ||{}).forEach(function(id){all=all.concat(g.stowQ[id]);});
         w=all.filter(function(x){return x&&x.fk===2;});
         if(w.length!==1||w[0].id!==sample.id||w[0].el!==el||!ct.fw.used) return 'body loot must grant exactly the matching forged gun once, role '+role;
       }
       ct={fw:{gk:k,fk:2,el:el}};
       w=netForgeLoot(ct,[other]); if(ct.fw.used) return 'another gun spent the body forge';
       w=netForgeLoot(ct,[k]); if(!w||w.used||!ct.fw.used) return 'host did not reserve the first forged pull';
       if(!netForgeLoot(ct,[k]).used) return 'host offered a second forged copy';
       return null;
     } finally {
       CFG.eliteRate=oldCfg.rate; CFG.eliteGuns=oldCfg.guns; RNGS=oldR;
       try{ __endRaid('abandon'); }catch(_e){} __topClear();
     }
   }},
  {v:'37.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
