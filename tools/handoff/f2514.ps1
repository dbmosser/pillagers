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

if ($s.Contains("  {v:'25.14',what:")) { throw "check 25.14 is in the fixture already" }

SubRx @'
  {v:'25.13',what:
'@ @'
  {v:'25.14',what:'forge3: a MK III fire round (and every Burst Carbine echo) carries fire, the body burns for 3 s with the kill yours, a burning pillager panics and runs without firing, the number is fire coloured, and a forged gun keeps its MK and element through the backpack',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof forgeApply!=='function'||typeof updateBullets!=='function'||typeof updateThrowables!=='function') return 'SKIP: no raid or forge model here';
     if(typeof elemHit!=='function'||typeof elemTick!=='function') return 'no elemental rounds (elemHit, elemTick)';
     var bad=[], g, p, all=null, oW, oA, oPX, oPY, cr, rd, n0, b, i, h0, dps, X0, Y0, dx=1, dy=0, k, d0, d1, mine, oWK=null, wkKind=null, dn, q, ok=false;
     try{
       __topClear(); __runPrep(); __resetCfg(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       all=g.ents.slice(); oW=p.wep; oA=p.ammo; oPX=p.x; oPY=p.y; X0=p.x; Y0=p.y;
       for(k=0;k<8;k++){ var ax=Math.cos(k*0.7854), ay=Math.sin(k*0.7854); if(losClear(X0,Y0,X0+ax*160,Y0+ay*160,g.map.segs)){ dx=ax; dy=ay; ok=true; break; } }
       if(!ok) return 'SKIP: staging: no open line from the drop point';
       g.ents=[];
       p.wep=forgeApply(WEAPONS.carbine,2,'fire'); p.ammo=p.wep.mag; g.bullets.length=0; g.throws.length=0;
       fireWeapon(p,p.wep,p.x+dx*200,p.y+dy*200,true);
       n0=g.bullets.length;
       if(!n0||g.bullets[n0-1].el!=='fire') bad.push('a MK III fire round does not carry fire ('+(n0?g.bullets[n0-1].el:'no round')+')');
       g.bullets.length=0;
       for(i=0;i<5;i++) updateThrowables(0.05);
       if(g.bullets.length!==2) bad.push('the burst fired '+g.bullets.length+' echo rounds, want 2');
       else if(g.bullets.some(function(x){ return x.el!=='fire'; })) bad.push('a Burst Carbine echo round lost the element');
       g.bullets.length=0;
       cr=all.filter(function(x){ return x.kind==='crawler'&&x.hp>0&&!x.downed; })[0];
       if(!cr) return 'SKIP: no crawler on this map';
       wkKind=cr.kind; oWK=WEAKPTS[wkKind]; WEAKPTS[wkKind]=null;
       g.ents=[cr]; cr.x=X0; cr.y=Y0; cr.hp=cr.maxhp=2000; cr.burnT=0; cr.burnDps=0; cr.face=Math.atan2(dy,dx); cr.state='patrol'; cr.alert=0;
       p.x=X0-dx*150; p.y=Y0-dy*150;
       g.dmgN=[];
       g.bullets.push({x:X0+dx*6,y:Y0+dy*6,vx:-dx*1180,vy:-dy*1180,dmg:20,life:0.5,player:true,owner:p,tint:ELEM.fire.c,el:'fire',thru:0});
       h0=cr.hp; updateBullets(0.001);
       if(!(cr.hp<h0)) bad.push('the staged fire round did not land on the crawler');
       else {
         if(!(cr.burnT>0)) bad.push('a fire round did not set the crawler burning');
         dps=cr.burnDps;
         if(Math.abs(dps-Math.min(18,4+0.25*(h0-cr.hp)))>0.01) bad.push('burn per second '+dps+' for a hit of '+(h0-cr.hp));
         dn=g.dmgN&&g.dmgN.length?g.dmgN[g.dmgN.length-1]:null;
         if(!dn) bad.push('no damage number for the fire round');
         else if(dn.c!==ELEM.fire.c) bad.push('the fire round number is '+dn.c+', want '+ELEM.fire.c);
         h0=cr.hp;
         for(i=0;i<12;i++) elemTick(0.25);
         if(Math.abs((h0-cr.hp)-dps*3)>1) bad.push('the burn took '+(h0-cr.hp).toFixed(1)+' over 3 s, want '+(dps*3).toFixed(1));
         if(cr.burnT>0) bad.push('the burn is still on after 3 s');
         elemHit(cr,'fire',20,0,p.x,p.y); cr.hp=1; cr.byPlayer=false;
         elemTick(0.5);
         if(!(cr.hp<=0)) bad.push('a burn did not finish a crawler on 1 health');
         else if(cr.byPlayer!==true) bad.push('a burn kill is not the player kill');
       }
       rd=all.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC&&x.hp>0&&!x.downed; })[0];
       if(!rd) return bad.length?bad.join('; '):'SKIP: no pillager on this map';
       g.ents=[rd]; rd.x=X0; rd.y=Y0; rd.hp=rd.maxhp=2000; rd.hostile=true; rd.state='chase'; rd.alert=3; rd.tx=p.x; rd.ty=p.y;
       rd.downed=0; rd.finished=0; rd.roll=0; rd.rollCd=9; rd.cd=0; rd.panicT=0; rd.panicCd=0; rd.armor=0; rd.burnT=0;
       elemHit(rd,'fire',20,0,p.x,p.y);
       if(!(rd.panicT>0)) bad.push('a pillager hit by fire did not panic');
       g.bullets.length=0; d0=Math.hypot(rd.x-p.x,rd.y-p.y);
       for(i=0;i<6;i++) __ents(0.1);
       d1=Math.hypot(rd.x-p.x,rd.y-p.y);
       if(!(d1>d0+20)) bad.push('the panicking pillager did not run away ('+d0.toFixed(0)+' to '+d1.toFixed(0)+')');
       mine=g.bullets.filter(function(x){ return x.owner===rd; }).length;
       if(mine) bad.push('the panicking pillager fired '+mine+' rounds');
       rd.panicT=0; elemHit(rd,'fire',20,0,p.x,p.y);
       if(rd.panicT>0) bad.push('a pillager panicked again inside 5 s');
       q=forgeApply(WEAPONS.rifle,2,'fire');
       gunQPush(q); var back=gunQTake('rifle');
       if(!back||back.fk!==2||back.el!=='fire'||back.name!=='Auto Rifle MK III') bad.push('the backpack lost the MK or the element ('+(back&&back.fk)+' '+(back&&back.el)+')');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       try{ if(wkKind) WEAKPTS[wkKind]=oWK; }catch(_w){}
       try{ var g2=__state(); if(g2){ if(all) g2.ents=all; g2.bullets.length=0; if(g2.player){ g2.player.wep=oW; g2.player.ammo=oA; g2.player.x=oPX; g2.player.y=oPY; } if(!g2.over){ g2.player.downed=false; g2.player.hp=100; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
