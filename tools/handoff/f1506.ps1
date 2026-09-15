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
  {v:'15.05',what:
'@ @'
  {v:'15.06',what:'Q never picks a grenade that has no key on the tactical belt: with a Medkit on the Smoke key, Q from the Frag stays on the Frag and the press cooks a Frag and spends no Smoke, and with the hand left on the Smoke the trigger and G still use the Frag the belt highlights (throwables audit finding 4)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof updatePlayer!=='function'||typeof cycleThrow!=='function'||typeof setHot!=='function'||typeof useHot!=='function'||typeof hotbarSlots!=='function'||typeof hotSel!=='function'||typeof mouse==='undefined') return 'SKIP: no belt, cook or cycle in this build';
     if(!(THROWKEYS&&THROWKEYS.indexOf('smoke')>=0&&THROWKEYS.indexOf('frag')>=0&&ITEMS.smoke&&ITEMS.frag&&ITEMS.medkit)) return 'SKIP: no Smoke, Frag or Medkit in this build';
     var bad=[], g0=null, _say=say, said='';
     var SX=THROWKEYS.indexOf('smoke'), FX=THROWKEYS.indexOf('frag');
     function cellOf(want){ var sl=hotbarSlots(), i; for(i=0;i<sl.length;i++) if(sl[i]&&(sl[i].k==='throw:'+want||sl[i].itemKey===want)) return i; return -1; }
     function clearHand(q){ mouse.down=false; q.cooking=0; q.cookT=0; q.cookKind=null; q.fired=false; q.trigYield=0; }
     function full(q){ q.pouch={smoke:2,decoy:0,frag:2}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       g0=g;
       var p=g.player;
       g.ents.length=0; p.downed=false; p.roll=0; p.iv=99; clearHand(p);
       g.hotAuto={}; g.hotAssign={}; full(g);
       var sc=cellOf('smoke'), fc=cellOf('frag');
       if(sc<0||fc<0) return 'SKIP: no Smoke and Frag cells on the tactical belt';
       // CONTROL: with both grenades on keys, Q from the Frag moves the hand and the highlight to the Smoke, and the press cooks a Smoke.
       g.hot=-1; setHot(fc);
       if(g.tsel!==FX) return 'SKIP: pointing the belt at the Frag cell did not put the Frag in hand';
       cycleThrow();
       if(g.tsel!==SX||g.hot!==sc) return 'SKIP: with both grenades on keys Q from the Frag did not move to the Smoke cell here';
       mouse.down=true; updatePlayer(0.016);
       if(!p.cooking||p.cookKind!=='smoke') return 'SKIP: the press on the Smoke cell did not cook a Smoke here (cooking '+p.cooking+', kind '+p.cookKind+')';
       clearHand(p);
       // THE FINDING: a Medkit of his own on the Smoke key leaves the Smoke with no cell anywhere on the belt.
       g.bag.push('medkit'); g.hotAssign={}; g.hotAssign[sc]='medkit'; g.hotAuto={}; full(g);
       var sl=hotbarSlots();
       if(!sl[sc]||sl[sc].itemKey!=='medkit') return 'SKIP: the Medkit did not take key '+(sc+1)+' here';
       if(cellOf('smoke')>=0) return 'SKIP: the Smoke still has a cell with the Medkit on key '+(sc+1);
       if(cellOf('frag')!==fc) return 'SKIP: the Frag cell moved when the Medkit took key '+(sc+1);
       g.hot=-1; setHot(fc);
       if(g.tsel!==FX||hotSel()!==fc) return 'SKIP: pointing the belt at the Frag cell did not put the Frag in hand';
       say=function(m){ said=String(m); };
       cycleThrow();
       say=_say;
       if(g.tsel!==FX) bad.push('Q from the Frag chose the '+ITEMS[THROWKEYS[g.tsel]].name+', which is on no key, with the highlight left on cell '+(hotSel()+1)+' (said: '+said.slice(0,60)+')');
       if(hotSel()!==fc) bad.push('Q moved the highlight off the Frag cell to cell '+(hotSel()+1));
       mouse.down=true; updatePlayer(0.016);
       var hk=String((hotbarSlots()[hotSel()]||{}).k||'');
       if(!p.cooking) bad.push('after Q the press on the highlighted '+hk+' cell cooked nothing');
       else if('throw:'+p.cookKind!==hk) bad.push('after Q the press cooked a '+p.cookKind+' under the highlighted '+hk+' cell');
       if(g.pouch.smoke!==2) bad.push('after Q the press spent a Smoke that is on no key (smoke now '+g.pouch.smoke+')');
       // AND A HAND LEFT ON THE SMOKE, as a drag leaves it: the trigger and G use the Frag the belt highlights.
       clearHand(p); full(g); g.hot=fc; g.tsel=SX;
       mouse.down=true; updatePlayer(0.016);
       if(!p.cooking) bad.push('with the hand left on the Smoke, the press on the Frag cell cooked nothing');
       else if(p.cookKind!=='frag') bad.push('with the hand left on the Smoke, the press on the Frag cell cooked a '+p.cookKind);
       clearHand(p); full(g); g.hot=fc; g.tsel=SX;
       useHot();
       if(g.pouch.smoke!==2) bad.push('with the hand left on the Smoke, G on the Frag cell threw a Smoke (smoke now '+g.pouch.smoke+', frag '+g.pouch.frag+')');
       else if(g.pouch.frag!==1) bad.push('with the hand left on the Smoke, G on the Frag cell threw nothing (frag still '+g.pouch.frag+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=_say;
       try{ if(g0){ if(g0.player){ clearHand(g0.player); g0.player.iv=0; g0.player.downed=false; } if(g0.throws) g0.throws.length=0; if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ mouse.down=false; __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
