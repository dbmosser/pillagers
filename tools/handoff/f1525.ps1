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
  {v:'15.24',what:
'@ @'
  {v:'15.25',what:'belt key 1 never goes black while he holds a gun: the SMG taken from the backpack on key 3 over a pistol leaves cell 1 showing the SMG, the same key with one gun carried leaves cell 2 showing it, and a stowed carbine on key 5 shows on cell 2 while key 5 and key 2 each bring it up and keep the highlight on the key pressed (his note)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof hotbarSlots!=='function'||typeof equipFromBag!=='function'||typeof setHot!=='function'||typeof hotSel!=='function') return 'SKIP: no tactical belt or equip from the backpack in this build';
     if(!ITEMS.gun_smg||!ITEMS.gun_carbine||!WEAPONS.pistol||!WEAPONS.smg||!WEAPONS.carbine||!WEAPONS.fists) return 'SKIP: no pistol, SMG or carbine in this build';
     var bad=[], g=null, p=null, sl;
     function copyW(id){ var w={},k; for(k in WEAPONS[id]) w[k]=WEAPONS[id][k]; return w; }
     // The pistol in his hands; the carbine stowed, or bare hands in the second slot.
     function hands(two){
       p.downed=false; p.dying=false; p.roll=0; g.paused=false;
       p.wep=copyW('pistol'); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=false; p.reloading=0;
       if(two){ p.sec=copyW('carbine'); p.secAmmo=p.sec.mag; p.secIssued=false; p.secFromArmory=false; }
       else { p.sec=WEAPONS.fists; p.secAmmo=0; p.secIssued=true; p.secFromArmory=false; }
       p.swapped=false; g.hotAuto={}; G.hot=0;
     }
     function cell(i){ return sl[i]?(sl[i].kind+' '+sl[i].icon):'none'; }
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       p=g.player;
       // ONE, HIS NOTE: two guns carried, the SMG in the backpack on key 3, taken the way the key takes it.
       hands(true); g.bag=['gun_smg']; g.hotAssign={2:'gun_smg'};
       sl=hotbarSlots();
       // CONTROL: cell 1 is the pistol in his hands and key 3 is the SMG in the backpack.
       if(!(sl[0]&&sl[0].kind==='gun'&&sl[0].icon==='pistol')) return skip('cell 1 is not the pistol in his hands here ('+cell(0)+')');
       if(!(sl[2]&&sl[2].assigned&&sl[2].itemKey==='gun_smg'&&!sl[2].equipped)) return skip('key 3 is not the SMG in the backpack here ('+cell(2)+')');
       equipFromBag(g.bag.indexOf('gun_smg'),0);
       // CONTROL: the SMG is in his hands in place of the pistol, and key 3 shows it there.
       if(!(p.wep&&p.wep.id==='smg')) return skip('the SMG did not come up in his hands here (holding '+(p.wep&&p.wep.id)+')');
       sl=hotbarSlots();
       if(!(sl[2]&&sl[2].equipped&&sl[2].icon==='smg')) return skip('key 3 does not show the SMG in his hands here ('+cell(2)+')');
       if(!(sl[0]&&sl[0].kind==='gun'&&sl[0].icon==='smg')) bad.push('with the SMG taken from the backpack by key 3, cell 1 is '+cell(0)+' while he holds the SMG');
       // TWO: one gun carried, and key 3 pressed. The SMG goes to the empty second slot and comes up.
       hands(false); g.bag=['gun_smg']; g.hotAssign={2:'gun_smg'};
       setHot(2);
       // CONTROL: the SMG is in his hands and the pistol is stowed.
       if(!(p.wep&&p.wep.id==='smg'&&p.sec&&p.sec.id==='pistol')) return skip('key 3 did not bring the SMG up over a stowed pistol here (holding '+(p.wep&&p.wep.id)+')');
       sl=hotbarSlots();
       if(!(sl[1]&&sl[1].kind==='gun'&&sl[1].icon==='smg')) bad.push('with one gun carried and the SMG brought up by key 3, cell 2 is '+cell(1)+' while he holds the SMG');
       if(hotSel()!==2) bad.push('key 3 brought the SMG up and the highlight went to cell '+(hotSel()+1)+' instead of staying on key 3');
       // THREE: the carbine stowed and on key 5. Key 5 brings it up, and the highlight stays on key 5.
       hands(true); g.bag=[]; g.hotAssign={4:'gun_carbine'};
       sl=hotbarSlots();
       // CONTROL: key 5 shows the stowed carbine.
       if(!(sl[4]&&sl[4].equipped&&sl[4].icon==='carbine'&&!sl[4].inHand)) return skip('key 5 does not show the stowed carbine here ('+cell(4)+')');
       if(!(sl[1]&&sl[1].kind==='gun'&&sl[1].icon==='carbine')) bad.push('with the stowed carbine on key 5, cell 2 is '+cell(1)+' while he carries the carbine');
       setHot(4);
       // CONTROL: the carbine came up.
       if(!(p.wep&&p.wep.id==='carbine')) return skip('key 5 did not bring the carbine up here (holding '+(p.wep&&p.wep.id)+')');
       if(hotSel()!==4) bad.push('key 5 brought the carbine up and the highlight went to cell '+(hotSel()+1)+' instead of staying on key 5');
       // FOUR: the same room, and key 2, which shows the carbine too, brings it up; the highlight stays on key 2.
       hands(true); g.bag=[]; g.hotAssign={4:'gun_carbine'};
       sl=hotbarSlots();
       if(sl[1]&&sl[1].kind==='gun'&&sl[1].icon==='carbine'){
         setHot(1);
         if(!(p.wep&&p.wep.id==='carbine')) return skip('key 2 did not bring the carbine up here (holding '+(p.wep&&p.wep.id)+')');
         if(hotSel()!==1) bad.push('key 2 brought the carbine up and the highlight went to cell '+(hotSel()+1)+' instead of staying on key 2');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.24',what:
'@
SubRx @'
       // ARM E, THE RAID START: the held gun bound to key 5 blanks cell 1; the raid must start on key 5.
'@ @'
       // ARM E, THE RAID START: the held gun bound to key 5; the raid must start on key 5, the key he bound (since v15.25 cell 1 shows that gun too).
'@
SubRx @'
           if(!(s5[0]&&s5[0].kind==='empty'&&s5[4]&&s5[4].kind==='gun')) bad.push('staging: binding the held gun to key 5 did not blank cell 1 at the raid start (cell 1 '+(s5[0]&&s5[0].kind)+', cell 5 '+(s5[4]&&s5[4].kind)+')');
'@ @'
           if(!(s5[4]&&s5[4].kind==='gun'&&s5[4].inHand)) bad.push('staging: binding the held gun to key 5 did not put it on key 5 at the raid start (cell 5 '+(s5[4]&&s5[4].kind)+')');
'@
SubRx @'
  {v:'12.31',what:'with the gun in hand bound to key 5, which blanks cell 1: a click on the blank cell, on an empty throwable and after the last Bandage keeps its cell, fires nothing, and names key 5 rather than cell 1 (2026-09-07 audit P1; repaired to his ruling of 2026-09-13 at v13.42)',
'@ @'
  {v:'12.31',what:'with the gun in hand bound to key 5, which cell 1 shows too: a click on cell 1 fires the gun, and a click on an empty throwable and after the last Bandage keeps its cell, fires nothing, and names key 5, the key he bound (2026-09-07 audit P1; repaired to his ruling of 2026-09-13 at v13.42, and at v15.25 when cell 1 stopped going black)',
'@
SubRx @'
       // THE ROOM: the gun in his hands bound to key 5, which blanks the derived cell 1.
'@ @'
       // THE ROOM: the gun in his hands bound to key 5. Since v15.25 the derived cell 1 shows that gun too.
'@
SubRx @'
       // These two ARE the finding, so they fail rather than skip: a skip here
       // would quietly stop this check running the day the dedupe changed.
       if(!(sl[0]&&sl[0].kind==='empty')) bad.push('the premise is gone: binding the held gun to key 5 no longer blanks cell 1 (cell 1 is '+(sl[0]&&sl[0].kind)+')');
       if(!(sl[4]&&sl[4].kind==='gun')) bad.push('the premise is gone: key 5 did not take the held gun (cell 5 is '+(sl[4]&&sl[4].kind)+')');
'@ @'
       // These two ARE the room, so they fail rather than skip: a skip here
       // would quietly stop this check running the day the dedupe changed.
       if(!(sl[0]&&sl[0].kind==='gun'&&sl[0].inHand)) bad.push('cell 1 does not show the gun in his hands while key 5 holds it (cell 1 is '+(sl[0]&&sl[0].kind)+')');
       if(!(sl[4]&&sl[4].kind==='gun'&&sl[4].inHand)) bad.push('the premise is gone: key 5 did not take the held gun (cell 5 is '+(sl[4]&&sl[4].kind)+')');
'@
SubRx @'
       // ARM A, THE RAID START: the highlight sits on the blank cell 1, as every raid begins.
       G.hot=0; p.fired=false; p.trigYield=0; p.lastShot=-9999; var sh0=g.tel.shots||0;
       window.__lastSay=null; press(1);
       if(hotSel()!==0) bad.push('a click on the blank cell 1 moved the highlight to cell '+(hotSel()+1)+'; since v13.42 he brings the gun up himself');
       if(String(window.__lastSay||'').indexOf('Press 5')<0) bad.push('a click on the blank cell 1 did not name key 5, the cell that holds his gun (said: '+String(window.__lastSay||'')+')');
       press(2); release();
       p.lastShot=-9999; press(2); release();
       if((g.tel.shots||0)!==sh0) bad.push('clicking the blank cell 1 fired the gun '+((g.tel.shots||0)-sh0)+' time(s)');
'@ @'
       // ARM A, CELL 1: since v15.25 it shows the gun in his hands and is never blank, so a click on it fires and keeps cell 1.
       G.hot=0; p.fired=false; p.trigYield=0; p.reloading=0; p.jam=0; p.wep.jam=0; p.lastShot=-9999; p.cooking=0; var sh0=g.tel.shots||0;
       press(2); release();
       if(hotSel()!==0) bad.push('a click on cell 1 moved the highlight to cell '+(hotSel()+1));
       if(!((g.tel.shots||0)>sh0)) bad.push('a click on cell 1, which shows the gun in his hands, fired nothing');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
