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

# v12.30 CHECK, inserted before the v12.29 entry. The gun in hand is bound to
# key 5, which blanks the derived cell 1 (staging, asserted). ARM A, the raid
# start: the highlight on the blank cell 1, a click must select the cell that
# holds the gun, fire nothing on that hold, and fire on the next click. ARM B,
# the v12.08 yield: an empty throwable cell selected, the click must land the
# highlight on the gun cell, not on the blank, and the next click must fire.
# The press is driven the way check 12.08 drives it: mouse.down and
# updatePlayer, with lastShot reset so the shot depends on the trigger alone.
SubRx @'
  {v:'12.29',what:'a crawler that sees you bites when it reaches you: parked on patrol with 6.5 s of wander clock 120 units from a still, visible player it bites inside 2 s, the same with the clock at zero, and a crawler called in by packCall with 6.5 s of clock bites inside 3 s (2026-09-07 audit P1, his crawler note)',
'@ @'
  {v:'12.30',what:'the trigger never dies on a blanked belt cell 1: with the gun in hand bound to key 5 a click on the blank cell selects the gun cell and yields, the next click fires, and the empty-throwable yield lands on the gun cell rather than the blank (2026-09-07 audit P1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__mouse)) return 'SKIP: this fixture cannot deploy';
     if(typeof setHot!=='function'||typeof hotbarSlots!=='function'||typeof updatePlayer!=='function'||typeof hotSel!=='function') return 'SKIP: this build has no belt to drive';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, i;
       g.ents.length=0; p.downed=false; p.iv=99;
       if(!p.wep||!p.wep.id||p.wep.id==='fists') return 'SKIP: no gun in hand at the drop';
       var gk='gun_'+p.wep.id; if(!ITEMS[gk]) return 'SKIP: no item for the gun in hand ('+gk+')';
       // THE ROOM: the gun in his hands bound to key 5, which blanks the derived cell 1.
       g.hotAssign={4:gk}; g.hotAuto={}; g.pouch.frag=0; g.pouch.smoke=0; g.pouch.decoy=0;
       p.ammo=Math.max(p.ammo||0,5); p.reloading=0; p.jam=0; p.cooking=0; p.fired=false; p.trigYield=0;
       p.wep.jam=0;   // the jam roll on the trigger pull would eat the shot this check counts; the raid ends before the gun is seen again
       var sl=hotbarSlots();
       if(!(sl[0]&&sl[0].kind==='empty')) return 'SKIP: binding the held gun to key 5 did not blank cell 1 (cell 1 is '+(sl[0]&&sl[0].kind)+')';
       if(!(sl[4]&&sl[4].kind==='gun')) return 'SKIP: key 5 did not take the held gun (cell 5 is '+(sl[4]&&sl[4].kind)+')';
       function press(frames){ mouse.down=true; for(var f=0;f<frames;f++) updatePlayer(0.016); }
       function release(){ mouse.down=false; updatePlayer(0.016); }
       // ARM A, THE RAID START: the highlight sits on the blank cell 1, as every raid begins.
       G.hot=0; p.fired=false; p.trigYield=0; p.lastShot=-9999; var sh0=g.tel.shots||0;
       press(1);
       var c1=hotbarSlots()[hotSel()];
       if(!(c1&&c1.kind==='gun')) bad.push('a click on the blank cell 1 left cell '+(hotSel()+1)+' ('+(c1&&c1.kind)+') selected instead of the gun in hand');
       press(2); release();
       if((g.tel.shots||0)!==sh0) bad.push('the click that raised the gun fired it on the same hold');
       p.lastShot=-9999; press(2); release();
       if(!((g.tel.shots||0)>sh0)) bad.push('the next click after the blank cell did not fire the gun (shots '+sh0+' to '+(g.tel.shots||0)+', cell '+(hotSel()+1)+' '+((hotbarSlots()[hotSel()]||{}).kind)+')');
       // ARM B, THE v12.08 YIELD: an empty throwable cell selected; the yield must land on the gun cell, not the blank.
       var fi=-1; sl=hotbarSlots(); for(i=0;i<sl.length;i++) if(sl[i]&&sl[i].kind==='throw'&&!((sl[i].count|0)>0)){ fi=i; break; }
       if(fi<0) bad.push('staging: no empty throwable cell on the belt');
       else {
         G.hot=fi; p.fired=false; p.trigYield=0; p.cooking=0; var sh1=g.tel.shots||0;
         press(1);
         var c2=hotbarSlots()[hotSel()];
         if(!(c2&&c2.kind==='gun')) bad.push('the empty-throwable yield left cell '+(hotSel()+1)+' ('+(c2&&c2.kind)+') selected instead of the gun in hand');
         press(2); release(); p.lastShot=-9999; press(2); release();
         if(!((g.tel.shots||0)>sh1)) bad.push('after the empty-throwable yield the next click did not fire the gun');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ try{ mouse.down=false; }catch(_m){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.29',what:'a crawler that sees you bites when it reaches you: parked on patrol with 6.5 s of wander clock 120 units from a still, visible player it bites inside 2 s, the same with the clock at zero, and a crawler called in by packCall with 6.5 s of clock bites inside 3 s (2026-09-07 audit P1, his crawler note)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
