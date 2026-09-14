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

# v13.42 CHECK, inserted before the v13.41 entry, plus repairs to 12.08 and 12.31,
# which asserted the fall-back to the gun that his ruling of 2026-09-13 removes.
SubRx @'
  {v:'13.41',what:'the raised decks are gone from both sectors:
'@ @'
  {v:'13.42',what:'out of a consumable he switches back to the gun himself: spending the last Bandage and clicking on fires nothing and keeps the Medical cell, throwing the last cooked Frag and clicking on fires nothing and keeps the Frag cell, the use key on the empty Frag cell keeps it too, every empty press names the gun key, selecting the gun and clicking fires it, and a raid with the gun bound to key 5 starts on key 5 (his ruling of 2026-09-13)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof updatePlayer!=='function'||typeof hotbarSlots!=='function'||typeof setHot!=='function'||typeof hotSel!=='function'||typeof useHot!=='function'||typeof gunCell!=='function') return 'SKIP: no belt or player update in this build';
     var bad=[], keepHA=P.hotAssign, i;
     function press(nf){ mouse.down=true; for(var f=0;f<nf;f++) updatePlayer(0.016); }
     function release(){ mouse.down=false; updatePlayer(0.016); }
     function heard(g){ return String(window.__lastSay||'')+' | '+String((g&&g.msg)||''); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!p.wep||!p.wep.id||p.wep.id==='fists') return 'SKIP: no gun in hand at the drop';
       g.ents.length=0; p.downed=false; p.iv=99; p.hp=40;
       p.ammo=Math.max(p.ammo||0,8); p.reloading=0; p.jam=0; p.wep.jam=0; p.cooking=0; p.fired=false; p.trigYield=0;
       var gc=gunCell(), KEY='Press '+(gc+1);
       // ARM A, HIS CASE: one Bandage, the Medical cell selected, one click spends it, and he keeps clicking.
       g.bag=['bandage']; g.pouch.frag=0; g.pouch.smoke=0; g.pouch.decoy=0;
       var sl=hotbarSlots(), hc=-1, fc=-1;
       for(i=0;i<sl.length;i++){ if(hc<0&&sl[i]&&sl[i].kind==='heal') hc=i; if(fc<0&&sl[i]&&sl[i].k==='throw:frag') fc=i; }
       if(hc<0) return 'SKIP: no Medical cell on the belt';
       setHot(hc); p.fired=false; var sh0=g.tel.shots||0;
       press(1); release();
       if(g.bag.indexOf('bandage')>=0) bad.push('control: the click on the Medical cell did not spend the last Bandage');
       else {
         if(hotSel()!==hc) bad.push('spending the last Bandage moved the highlight from the Medical cell to cell '+(hotSel()+1));
         window.__lastSay=null; g.msg='';
         for(i=0;i<3;i++){ p.lastShot=-9999; press(20); release(); }
         if((g.tel.shots||0)!==sh0) bad.push('three held clicks after the last Bandage fired the gun '+((g.tel.shots||0)-sh0)+' time(s)');
         if(heard(g).indexOf(KEY)<0) bad.push('a click on the spent Medical cell did not name key '+(gc+1)+' for the gun (heard: '+heard(g)+')');
       }
       // ARM B: the last Frag, cooked and let go, then clicks.
       p.prep=null; p.healQ=0; p.fired=false;
       if(fc<0) bad.push('staging: no Frag cell on the belt');
       else {
         g.pouch.frag=1; setHot(fc); p.fired=false; p.cooking=0; p.trigYield=0;
         var sh1=g.tel.shots||0, th0=g.throws.length;
         press(3); release();
         if(g.throws.length!==th0+1) bad.push('control: a cooked press and release on the last Frag put '+(g.throws.length-th0)+' in the air');
         if(hotSel()!==fc) bad.push('throwing the last Frag moved the highlight from the Frag cell to cell '+(hotSel()+1));
         window.__lastSay=null; g.msg='';
         for(i=0;i<3;i++){ p.lastShot=-9999; press(20); release(); }
         if((g.tel.shots||0)!==sh1) bad.push('held clicks on the empty Frag cell fired the gun '+((g.tel.shots||0)-sh1)+' time(s)');
         if(p.cooking) bad.push('a click on the empty Frag cell started a cook');
         if(heard(g).indexOf(KEY)<0) bad.push('a click on the empty Frag cell did not name key '+(gc+1)+' for the gun (heard: '+heard(g)+')');
         // ARM C: the use key on the same empty cell.
         g.throws.length=0; setHot(fc); window.__lastSay=null; g.msg='';
         useHot();
         if(hotSel()!==fc) bad.push('the use key on the empty Frag cell moved the highlight to cell '+(hotSel()+1));
         if(heard(g).indexOf(KEY)<0) bad.push('the use key on the empty Frag cell did not name key '+(gc+1)+' for the gun (heard: '+heard(g)+')');
       }
       // ARM D, THE WAY BACK: select the gun cell, click, and it fires.
       setHot(gc); p.fired=false; p.trigYield=0; p.reloading=0; p.jam=0; p.wep.jam=0; p.lastShot=-9999; p.cooking=0;
       var sh3=g.tel.shots||0;
       press(2); release();
       if(!((g.tel.shots||0)>sh3)) bad.push('control: selecting the gun cell and clicking did not fire the gun, so the zeros above prove nothing');
       var gk='gun_'+p.wep.id;
       try{ mouse.down=false; __endRaid('abandon'); }catch(_e0){}
       // ARM E, THE RAID START: the held gun bound to key 5 blanks cell 1; the raid must start on key 5.
       if(ITEMS[gk]){
         __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
         P.hotAssign={4:gk};
         __deploy({kit:[],safe:null,mapIx:0,seed:4242});
         var g5=__state();
         if(!(g5&&g5.player&&g5.player.wep&&('gun_'+g5.player.wep.id)===gk)) bad.push('staging: the second drop did not issue the same gun, so key 5 could not be bound to it');
         else {
           var s5=hotbarSlots();
           if(!(s5[0]&&s5[0].kind==='empty'&&s5[4]&&s5[4].kind==='gun')) bad.push('staging: binding the held gun to key 5 did not blank cell 1 at the raid start (cell 1 '+(s5[0]&&s5[0].kind)+', cell 5 '+(s5[4]&&s5[4].kind)+')');
           else if(hotSel()!==4) bad.push('with the held gun bound to key 5 the raid started on cell '+(hotSel()+1)+' instead of the gun cell');
         }
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ mouse.down=false; }catch(_m){}
       try{ P.hotAssign=keepHA||{}; }catch(_h){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; g2.player.cooking=0; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.41',what:'the raised decks are gone from both sectors:
'@

# REPAIR 12.08: the press on an empty Frag cell keeps the Frag cell and says the Frag is gone.
SubRx @'
  {v:'12.08',what:'the trigger on an empty grenade cell selects the gun and says so, fires nothing on that same hold, and a loaded cell still cooks (2026-09-06 first-ten-minutes audit)',
'@ @'
  {v:'12.08',what:'the trigger on an empty grenade cell keeps the grenade cell and says the grenade is gone, fires nothing, and a loaded cell still cooks (2026-09-06 first-ten-minutes audit; repaired to his ruling of 2026-09-13 at v13.42)',
'@
SubRx @'
       if(hotSel()!==0) bad.push('the press on the empty Frag cell left cell '+hotSel()+' selected instead of the gun');
'@ @'
       if(hotSel()!==fi) bad.push('the press on the empty Frag cell moved the highlight to cell '+hotSel()+'; since v13.42 it stays on the Frag cell');
'@
SubRx @'
       if(!/Nothing in that cell/.test(String(window.__lastSay||''))) bad.push('the press did not say the cell is empty (said "'+String(window.__lastSay||'')+'")');
'@ @'
       if(String(window.__lastSay||'').indexOf(' left. Press ')<0) bad.push('the press did not say the Frag is gone and which key brings the gun up (said: '+String(window.__lastSay||'')+')');
'@

# REPAIR 12.31: the arms asserted the fall-back to the gun cell; they now assert no fall-back,
# no shot, and that the message names key 5, the cell that holds the gun, rather than cell 1.
SubRx @'
  {v:'12.31',what:'the trigger never dies on a blanked belt cell 1: with the gun in hand bound to key 5 a click on the blank cell selects the gun cell and yields, the next click fires, and the empty-throwable yield lands on the gun cell rather than the blank (2026-09-07 audit P1)',
'@ @'
  {v:'12.31',what:'with the gun in hand bound to key 5, which blanks cell 1: a click on the blank cell, on an empty throwable and after the last Bandage keeps its cell, fires nothing, and names key 5 rather than cell 1 (2026-09-07 audit P1; repaired to his ruling of 2026-09-13 at v13.42)',
'@
SubRx @'
       press(1);
       var c1=hotbarSlots()[hotSel()];
       if(!(c1&&c1.kind==='gun')) bad.push('a click on the blank cell 1 left cell '+(hotSel()+1)+' ('+(c1&&c1.kind)+') selected instead of the gun in hand');
       press(2); release();
       if((g.tel.shots||0)!==sh0) bad.push('the click that raised the gun fired it on the same hold');
       p.lastShot=-9999; press(2); release();
       if(!((g.tel.shots||0)>sh0)) bad.push('the next click after the blank cell did not fire the gun (shots '+sh0+' to '+(g.tel.shots||0)+', cell '+(hotSel()+1)+' '+((hotbarSlots()[hotSel()]||{}).kind)+')');
'@ @'
       window.__lastSay=null; press(1);
       if(hotSel()!==0) bad.push('a click on the blank cell 1 moved the highlight to cell '+(hotSel()+1)+'; since v13.42 he brings the gun up himself');
       if(String(window.__lastSay||'').indexOf('Press 5')<0) bad.push('a click on the blank cell 1 did not name key 5, the cell that holds his gun (said: '+String(window.__lastSay||'')+')');
       press(2); release();
       p.lastShot=-9999; press(2); release();
       if((g.tel.shots||0)!==sh0) bad.push('clicking the blank cell 1 fired the gun '+((g.tel.shots||0)-sh0)+' time(s)');
'@
SubRx @'
         press(1);
         var c2=hotbarSlots()[hotSel()];
         if(!(c2&&c2.kind==='gun')) bad.push('the empty-throwable yield left cell '+(hotSel()+1)+' ('+(c2&&c2.kind)+') selected instead of the gun in hand');
         press(2); release();
         if((g.tel.shots||0)!==sh1) bad.push('the empty-throwable yield fired the gun on the same hold');
         p.lastShot=-9999; press(2); release();
         if(!((g.tel.shots||0)>sh1)) bad.push('after the empty-throwable yield the next click did not fire the gun');
'@ @'
         window.__lastSay=null; press(1);
         if(hotSel()!==fi) bad.push('a click on the empty throwable cell moved the highlight to cell '+(hotSel()+1)+'; since v13.42 he brings the gun up himself');
         if(String(window.__lastSay||'').indexOf('Press 5')<0) bad.push('the empty throwable cell did not name key 5 for the gun (said: '+String(window.__lastSay||'')+')');
         press(2); release();
         p.lastShot=-9999; press(2); release();
         if((g.tel.shots||0)!==sh1) bad.push('clicking the empty throwable cell fired the gun '+((g.tel.shots||0)-sh1)+' time(s)');
'@
SubRx @'
         press(1); release();
         var c3=hotbarSlots()[hotSel()];
         if(g.bag.indexOf('bandage')>=0) bad.push('control: the click did not spend the last Bandage, so no fall-back was reached');
         else if(!(c3&&c3.kind==='gun')) bad.push('spending the last of a stack left cell '+(hotSel()+1)+' ('+(c3&&c3.kind)+') selected instead of the gun in hand');
         if((g.tel.shots||0)!==sh2) bad.push('control: using the last Bandage fired the gun');
'@ @'
         press(1); release();
         if(g.bag.indexOf('bandage')>=0) bad.push('control: the click did not spend the last Bandage');
         else if(hotSel()!==3) bad.push('spending the last Bandage moved the highlight to cell '+(hotSel()+1)+'; since v13.42 it stays on the Bandage cell');
         p.lastShot=-9999; press(2); release(); press(2); release();
         if((g.tel.shots||0)!==sh2) bad.push('clicking on after the last Bandage fired the gun '+((g.tel.shots||0)-sh2)+' time(s)');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
