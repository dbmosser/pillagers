$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'15.44',what:
'@ @'
  {v:'15.45',what:'a round into a pillager you downed keeps your kill when he bleeds out: downed by your round and left to bleed out he is one kill and one grudge, downed by your round and shot once more on the floor without finishing him he is still one kill and one grudge, and downed by a round that was not yours and then shot once by you on the floor he is no kill and no grudge (bodies audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof mkRaider!=='function'||typeof updateEnts!=='function'||typeof updateBullets!=='function'||typeof saveProfile!=='function'||typeof IDENTITIES==='undefined'||!IDENTITIES.length) return 'SKIP: this build has no pillagers, entity update, bullet update or profile save';
     if(typeof WORLD_W!=='number'||typeof WORLD_H!=='number') return 'SKIP: no world size in this build';
     var bad=[], g=null, p=null, P2=__P(), S=null, keepEnts=null, keepBul=null, keepTel=null, keepC=null, hadC=false;
     // Distinctive names and a rival record no identity carries, so only what is staged here is counted and removed.
     var TAG='QX BLEED PROBE ', PID='qx_bleed_probe_1545';
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     function grudge(){ var q=(P2.rivals||{})[PID]; return (q&&q.kills)||0; }
     // Open ground: well inside the world and no wall within 40, so the round 8 units short of him starts and flies in the open.
     function free(o){
       if(!(o.x>80&&o.y>80&&o.x<WORLD_W-80&&o.y<WORLD_H-80)) return false;
       var ws=g.map.walls;
       for(var j=0;j<ws.length;j++){
         var W=ws[j], qx=Math.max(W.x,Math.min(o.x,W.x+W.w)), qy=Math.max(W.y,Math.min(o.y,W.y+W.h)), ex=o.x-qx, ey=o.y-qy;
         if(ex*ex+ey*ey<1600) return false;
       }
       return true;
     }
     // A hostile pillager on that ground, facing the round, at one health, no armour, no pack, no roll, and the only thing in the raid.
     function stage(tag){
       var r=mkRaider(S.x,S.y,IDENTITIES[0],true);
       r.name=TAG+tag; r.ident=PID; r.elite=0; r.merc=0; r.ghost=0; r.hostile=true; r.friendlyPC=0; r.notoCharged=1;
       r.downed=0; r.finished=0; r.byPlayer=false; r.paidRevive=0; r.roll=0; r.rollCd=99; r.armor=0; r.bag=[]; r.healQ=0;
       r.x=S.x; r.y=S.y; r.face=Math.PI; r.hp=1; r.state='chase';
       g.ents.length=0; g.ents.push(r); g.bullets.length=0;
       return r;
     }
     // YOUR round, in the shape the fire path pushes, 8 units short of him and resolved by the game's own bullet loop. True when it was spent on him.
     function shoot(r,dmg){
       g.bullets.length=0;
       g.bullets.push({x:r.x-8,y:r.y,vx:1180,vy:0,dmg:dmg,life:0.5,player:true,owner:p,tint:'#ffd48a',thru:0});
       updateBullets(0.001);
       return g.bullets.length===0;
     }
     // Downed by your round at one health (a Scav Pistol's 19), or by a lethal round that was not yours, as the enemy bullet path marks it.
     function downByYou(r){ if(!shoot(r,19)) return false; updateEnts(0.016); return r.downed===1&&r.hp>0; }
     function downByOther(r){ r.hp=0; r.byPlayer=false; updateEnts(0.016); return r.downed===1&&r.hp>0; }
     // His clock runs out: one frame takes him past it, the next runs the ordinary death path. What that death credited.
     function bleed(r){
       var k0=g.tel.kills.raider||0, q0=grudge();
       r.downT=0.01; updateEnts(0.05); updateEnts(0.016);
       return {gone:g.ents.indexOf(r)<0, kills:(g.tel.kills.raider||0)-k0, grudge:grudge()-q0};
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over||g.sim||!g.ents||!g.bullets||!g.containers||!g.map||!g.map.walls||!g.tel||!g.tel.kills) return 'SKIP: no live raid with a kill tally';
       p=g.player;
       if(CFG.raiderDown===0) return 'SKIP: pillagers are not downed here';
       keepEnts=g.ents.slice(); keepBul=g.bullets.slice();
       keepTel={raider:g.tel.kills.raider,hits:g.tel.hits,elite:g.tel.eliteKills};
       // No contract to tick, so a credited kill pays nothing out; put back in finally.
       keepC=P2.contracts; hadC=true; P2.contracts=[];
       for(var rad=150;rad<=900&&!S;rad+=150) for(var a=0;a<16&&!S;a++){
         var o={x:p.x+Math.cos(a*Math.PI/8)*rad,y:p.y+Math.sin(a*Math.PI/8)*rad};
         if(free(o)) S=o;
       }
       if(!S) return 'SKIP: no open ground near the landing spot to stage a pillager on';
       // CONTROL: downed by your round and left alone, his bleed-out is one kill and one grudge on either build, so the tally can be read.
       var A=stage('ONE');
       if(!downByYou(A)) return 'SKIP: your round at one health did not put the staged pillager on the floor here';
       var a1=bleed(A);
       if(!a1.gone) return 'SKIP: the staged pillager did not die when his clock ran out here';
       if(a1.kills!==1||a1.grudge!==1) return 'SKIP: a pillager you downed and left to bleed out counted '+a1.kills+' kills and '+a1.grudge+' grudges here, not one of each, so the tally cannot be read';
       // THE FINDING: downed by your round, then one more round into him on the floor that does not finish him.
       var B=stage('TWO');
       if(!downByYou(B)) return skip('your round at one health did not put the second staged pillager on the floor here');
       var hb=B.hp;
       if(!shoot(B,10)) return skip('the round on the floor did not reach the downed pillager here');
       // CONTROL: the round landed and left him on the floor.
       if(!(B.downed===1&&B.hp>0&&B.hp<hb)) return skip('the round on the floor did not land without finishing him here (down '+B.downed+', health '+hb+' to '+B.hp+')');
       var b1=bleed(B);
       if(!b1.gone) return skip('the second staged pillager did not die when his clock ran out here');
       if(b1.kills!==1||b1.grudge!==1) bad.push('a pillager you downed, shot once more on the floor without finishing him and left to bleed out counted '+b1.kills+' kills and '+b1.grudge+' grudges, where the same man left alone counts one of each');
       // KEPT: downed by a round that was not yours, then shot once by you on the floor, his bleed-out is not your kill.
       var C=stage('THREE');
       if(!downByOther(C)) return skip('a lethal round that was not yours did not put the third staged pillager on the floor here');
       var hc=C.hp;
       if(!shoot(C,10)||!(C.downed===1&&C.hp>0&&C.hp<hc)) return skip('your round did not land on the third downed pillager without finishing him here');
       var c1=bleed(C);
       if(!c1.gone) return skip('the third staged pillager did not die when his clock ran out here');
       if(c1.kills!==0||c1.grudge!==0) bad.push('a pillager downed by a round that was not yours, shot once by you on the floor without finishing him and left to bleed out, counted '+c1.kills+' kills and '+c1.grudge+' grudges, where he is not your kill');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g&&keepBul){ g.bullets.length=0; for(var kb=0;kb<keepBul.length;kb++) g.bullets.push(keepBul[kb]); } }catch(_u){}
       try{ if(g&&keepEnts){ g.ents.length=0; for(var ke=0;ke<keepEnts.length;ke++) g.ents.push(keepEnts[ke]); } }catch(_n){}
       try{ if(g&&g.containers){ for(var ci=g.containers.length-1;ci>=0;ci--){ var cc=g.containers[ci]; if(cc&&typeof cc.fallen==='string'&&cc.fallen.indexOf(TAG)===0) g.containers.splice(ci,1); } } }catch(_b){}
       try{ if(g&&keepTel){ g.tel.kills.raider=keepTel.raider; g.tel.hits=keepTel.hits; g.tel.eliteKills=keepTel.elite; } }catch(_t){}
       try{ if(hadC) P2.contracts=keepC; if(P2.rivals) delete P2.rivals[PID]; saveProfile(); }catch(_s){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
