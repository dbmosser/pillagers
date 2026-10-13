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

if ($s.Contains("  {v:'25.02',what:")) { throw "check 25.02 is in the fixture already" }

SubRx @'
  {v:'25.01',what:
'@ @'
  {v:'25.02',what:'his order (2026-10-12): equipping a different gun tells nothing about the backpack or the belt. With the rifle up, the SMG stowed, a shotgun and a marksman rifle packed on keys 3 and 4 and a Medkit and Bandages in the backpack, keys 2, 3, 4 and 1, the mouse wheel, and the pad walk with the trigger bring guns up, and no line, detail, label by him or gun card text names a gun other than the one in his hands or on the key he highlights, or an item in the backpack',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||!window.__sim) return 'SKIP: this fixture cannot deploy or step a raid';
     if(typeof raidKey!=='function'||typeof beltStep!=='function'||typeof bagGunCell!=='function'||typeof hotbarSlots!=='function'||typeof hotSel!=='function'||typeof drawHUD!=='function'||typeof GUNKEYS==='undefined'||GUNKEYS<4) return 'SKIP: no four gun keys, key handler or HUD here';
     if(!WEAPONS.rifle||!WEAPONS.smg||!WEAPONS.shotgun||!WEAPONS.dmr||!ITEMS.gun_shotgun||!ITEMS.gun_dmr||!ITEMS.medkit||!ITEMS.bandage) return 'SKIP: no rifle, smg, shotgun, marksman rifle, medkit or bandage here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], g=null, p=null, s0=say, md0=mouse.down, KIT=['gun_shotgun','gun_dmr'], NM={}, ITN=[], lines=[], swaps=0, lab0=0, z0=null,
         w0=P.weapons, e0=P.equipped, es0=P.equippedSec, h0=P.hotAssign, own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), of=ctx.fillText, OG='OTHER'+' GUN', hc, want, sl;
     function gid(c){ return (c&&c.kind==='gun'&&!c.vacant)?String(c.icon||'').replace(/^gun_/,''):''; }
     function note(w){ if(w&&w.id&&w.id!=='fists'&&w.name) (NM[w.id]=NM[w.id]||{})[String(w.name).toUpperCase()]=1; }
     function hud(){ var t=[]; ctx.fillText=function(s){ t.push(String(s)); return of.apply(this,arguments); }; try{ drawHUD(); } finally { if(own) ctx.fillText=of; else delete ctx.fillText; } return t; }
     function look(what){
       note(p.wep); note(p.sec);
       var s2=hotbarSlots(), h=s2[hotSel()], okId={}, okNm=[], k, n, j, t;
       okId[p.wep.id]=1; if(gid(h)) okId[gid(h)]=1;
       if(h&&h.name) okNm.push(String(h.name).toUpperCase());
       for(k in okId) for(n in (NM[k]||{})) okNm.push(n);
       okNm.sort(function(a,b){ return b.length-a.length; });
       function clean(s){ s=String(s==null?'':s).toUpperCase(); for(var q=0;q<okNm.length;q++) s=s.split(okNm[q]).join(' '); return s; }
       function scan(src,s,items){
         var c=clean(s), kk, nn, jj;
         if(c.indexOf(OG)>=0){ bad.push(what+': '+src+' says '+JSON.stringify(String(s))); return; }
         for(kk in NM){ if(okId[kk]) continue; for(nn in NM[kk]) if(nn.length>=3&&c.indexOf(nn)>=0){ bad.push(what+': '+src+' names the '+nn+' ('+JSON.stringify(String(s))+')'); return; } }
         if(items) for(jj=0;jj<ITN.length;jj++) if(ITN[jj].length>=3&&c.indexOf(ITN[jj])>=0){ bad.push(what+': '+src+' names the '+ITN[jj]+' in the backpack ('+JSON.stringify(String(s))+')'); return; }
       }
       for(j=0;j<lines.length;j++) scan('the line',lines[j],true);
       for(j=lab0;j<(g.labels||[]).length;j++) scan('a label by him',g.labels[j]&&g.labels[j].txt,true);
       t=hud(); for(j=0;j<t.length;j++) scan('the HUD',t[j],false);
       lines=[]; lab0=(g.labels||[]).length;
     }
     function fresh(){ g.msgT=0; g.msg=''; g.msgSub=''; g.feed=[]; g.msgQ=[]; g.msgQM=[]; g.alert=null; g.alertQ=[]; g.pick=[]; lines=[]; lab0=(g.labels||[]).length; }
     function press(n){ var was=p.wep.id, w=gid(hotbarSlots()[n-1]); fresh(); keys={}; raidKey('Digit'+n,false,null); keys={}; if(p.wep.id!==was&&p.wep.id===w) swaps++; look('key '+n); }
     function pull(){ fresh(); p.reloading=0; p.fired=false; p.lastShot=-1e9; p.cooking=false; p.trigYield=false; p.jam=0; keys={}; mouse.down=true; __sim(0.016); mouse.down=false; __sim(0.016); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P.weapons=['rifle','smg']; P.equipped='rifle'; P.equippedSec='smg'; P.hotAssign={};
       __deploy({kit:KIT.slice(),safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       if(!(p.wep&&p.wep.id==='rifle'&&p.sec&&p.sec.id==='smg')) return 'SKIP: staging: did not deploy with the rifle up and the SMG stowed';
       sl=hotbarSlots();
       if(!(gid(sl[2])==='shotgun'&&gid(sl[3])==='dmr')) return 'SKIP: staging: keys 3 and 4 do not show the packed shotgun and marksman rifle';
       g.ents.length=0; p.iv=99; p.roll=0; p.downed=false; p.dying=false; g.paused=false; g.bagOpen=false; g.mapOpen=false; g.drag=null; keys={};
       g.bag.push('medkit','bandage','bandage');
       ITN=[String(ITEMS.medkit.name).toUpperCase(),String(ITEMS.bandage.name).toUpperCase()];
       ['rifle','smg','shotgun','dmr'].forEach(function(id){ note(WEAPONS[id]); });
       say=function(m,k,o){ lines.push(String(m)+((o&&o.sub)?(' | '+String(o.sub)):'')); try{ return s0.apply(this,arguments); }catch(_s){} };
       lab0=(g.labels||[]).length;
       fresh(); look('the raid start');
       // ONE: the number keys, the SMG swapped up, the shotgun and the marksman rifle drawn off keys 3 and 4, the rifle back on key 1.
       press(2); press(3); press(4); press(1);
       // TWO: the mouse wheel, both ways.
       try{ z0=(typeof zoomTarget==='function')?zoomTarget():null; }catch(_z){}
       fresh(); cv.dispatchEvent(new WheelEvent('wheel',{deltaY:120,bubbles:true,cancelable:true}));
       cv.dispatchEvent(new WheelEvent('wheel',{deltaY:-120,bubbles:true,cancelable:true}));
       try{ if(z0!==null&&typeof setZoom==='function') setZoom(z0); }catch(_z2){}
       look('the mouse wheel');
       // THREE: the pad, RB onto a packed gun and the trigger drawing it, twice.
       for(var r=0;r<2;r++){
         fresh(); beltStep(1); look('the pad walk (RB)');
         hc=hotbarSlots()[hotSel()];
         if(bagGunCell(hc)){ want=gid(hc); pull(); if(p.wep.id===want) swaps++; look('the pad trigger on the packed '+want); }
       }
       if(swaps<4&&!bad.length) return 'SKIP: staging: only '+swaps+' of the presses brought a different gun up';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=s0; mouse.down=md0; keys={};
       try{ if(own) ctx.fillText=of; else delete ctx.fillText; }catch(_f){}
       try{ var g2=__state(); if(g2){ g2.drag=null; if(g2.player){ g2.player.iv=0; g2.player.downed=false; g2.player.reloading=0; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       P.weapons=w0; P.equipped=e0; P.equippedSec=es0; P.hotAssign=h0;
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.slice(0,4).join('; '):null; }},
  {v:'25.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
