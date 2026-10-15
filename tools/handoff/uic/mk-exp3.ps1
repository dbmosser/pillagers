param([string]$Src='C:\claudecode\dark raiders\dark_raiders.html',[string]$Out='C:\claudecode\dark raiders\tools\handoff\drafts\draft-exp3.json')
. 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\uiclib.ps1'
# EXPERIMENTAL, the things added to the world: strongholds, the golden enemy, its clue hunt, the red barrels, the mimic crates
Add "  // XF_ROWS_END" @'
  ['xfHold','STRONGHOLDS','Fenced compounds: breach the gate, beat two waves, take the purple cache.','w'],
  ['xfGold','GOLDEN ENEMY','One tough golden enemy a raid drops a golden hoard.','w'],
  ['xfClue','GOLDEN CLUE HUNT','Three clues shrink a circle on the golden enemy. It needs the golden enemy.','w'],
  ['xfBarrel','EXPLOSIVE BARRELS','Red barrels explode and set off the barrels beside them.','w'],
  ['xfMimic','MIMIC CRATES','About one crate in fifty hides a crawler.','w'],
  // XF_ROWS_END
'@.Replace("`r",'').TrimEnd("`n")
Add "  if(flowPeer()){ shPeerTick(dt); return; }   // v27.12 (coop4): a linked player 2 window lays out and fills no stronghold, it keeps the host ones (shNetTake)" "  if(!xf('xfHold')) return;   // v27.xx (exp3): STRONGHOLDS is switched off in EXPERIMENTAL: none is laid out`n  if(flowPeer()){ shPeerTick(dt); return; }   // v27.12 (coop4): a linked player 2 window lays out and fills no stronghold, it keeps the host ones (shNetTake)"
Add "  if(flowPeer()) return;   // v27.18 (coop5): a linked player 2 window gilds nothing, the golden enemy is the host one (goldNetTake)" "  if(!xf('xfGold')) return;   // v27.xx (exp3): GOLDEN ENEMY is switched off in EXPERIMENTAL: nothing is gilded`n  if(flowPeer()) return;   // v27.18 (coop5): a linked player 2 window gilds nothing, the golden enemy is the host one (goldNetTake)"
Add "  if(flowPeer()){ cluePeerTick(dt); return; }   // v27.18 (coop5): a linked player 2 window lays out no hunt, it keeps the host one (clueNetTake)" "  if(!xf('xfClue')) return;   // v27.xx (exp3): GOLDEN CLUE HUNT is switched off in EXPERIMENTAL: no clue is laid out`n  if(flowPeer()){ cluePeerTick(dt); return; }   // v27.18 (coop5): a linked player 2 window lays out no hunt, it keeps the host one (clueNetTake)"
Add "function brlPlace(g){`n  g.brl=[];" "function brlPlace(g){`n  g.brl=[];`n  if(!xf('xfBarrel')) return;   // v27.xx (exp3): EXPLOSIVE BARRELS is switched off in EXPERIMENTAL: none is placed"
Add "  if(!ct||typeof G==='undefined'||!G||CFG.mimic===0) return false;" "  if(!ct||typeof G==='undefined'||!G||CFG.mimic===0||!xf('xfMimic')) return false;   // v27.xx (exp3): MIMIC CRATES is switched off in EXPERIMENTAL"
$chk=@'
  {v:'VER',what:'his order (EXPERIMENTAL settings, exp3): strongholds, the golden enemy, the golden clue hunt, the explosive barrels and the mimic crates each have a row, and a raid started with one off has none of that feature (no site laid out, nothing gilded, no clue, no barrel, no mimic) while a raid with it on has it',
   run:function(){
     if(typeof arcadeDeploy!=='function'||typeof shTick!=='function'||typeof goldTick!=='function'||typeof clueTick!=='function'||typeof isMimic!=='function') return 'SKIP: this build lacks one of the five systems';
     if(typeof XF_ROWS==='undefined') return 'there is no EXPERIMENTAL table in this build';
     var KEYS=['xfHold','xfGold','xfClue','xfBarrel','xfMimic'], bad=[], on, off;
     function arm(offKey){
       KEYS.forEach(function(k){ CFG[k]=1; }); if(offKey) CFG[offKey]=0;
       if(!arcadeDeploy({mapIx:0,seed:4242})) return null;
       var g=__state(), i, nm=0, r;
       if(!g||!g.player) return null;
       g.t=6; goldTick(1); g.t=7; goldTick(1); shTick(0.1); clueTick(0.1); g.t=8; clueTick(0.1);
       for(i=0;i<(g.containers||[]).length;i++) if(isMimic(g.containers[i])) nm++;
       r={hold:((g.flow&&g.flow.sh&&g.flow.sh.sites)||[]).length, gold:!!(g.flow&&g.flow.gold&&g.flow.gold.ref), clue:!!(g.flow&&g.flow.clue&&g.flow.clue.props&&g.flow.clue.props.length), barrel:(g.brl||[]).length, mimic:nm};
       __endRaid('abandon'); __topClear();
       return r;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       openSettings(); KEYS.forEach(function(k){ if(!document.getElementById('go_'+k)) bad.push('no row for '+k); }); __topClear();
       on=arm(null); if(!on) return 'SKIP: arcadeDeploy built no raid';
       if(!on.gold) return 'SKIP: the raid gilded nothing in time here, so the golden systems cannot be compared';
       if(!on.hold) bad.push('control: with everything on the raid laid out no stronghold');
       if(!on.clue) bad.push('control: with everything on there is no clue hunt');
       if(!on.barrel) bad.push('control: with everything on there are no barrels');
       if(!on.mimic) bad.push('control: with everything on there is no mimic crate');
       if(bad.length) return bad.join('; ');
       off=arm('xfHold'); if(!off||off.hold) bad.push('STRONGHOLDS off still laid out '+(off&&off.hold)+' sites'); else if(!off.gold||!off.barrel) bad.push('STRONGHOLDS off took the gold or the barrels with it');
       off=arm('xfGold'); if(!off||off.gold) bad.push('GOLDEN ENEMY off still gilded one'); else if(off.clue) bad.push('GOLDEN ENEMY off still had a clue hunt');
       off=arm('xfClue'); if(!off||off.clue) bad.push('GOLDEN CLUE HUNT off still laid out clues'); else if(!off.gold) bad.push('GOLDEN CLUE HUNT off took the golden enemy with it');
       off=arm('xfBarrel'); if(!off||off.barrel) bad.push('EXPLOSIVE BARRELS off still placed '+(off&&off.barrel)+' barrels');
       off=arm('xfMimic'); if(!off||off.mimic) bad.push('MIMIC CRATES off still had '+(off&&off.mimic)+' mimics');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       try{ __resetCfg(); xfSnap(); }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     } }},
'@
Draft 'EXPERIMENTAL: STRONGHOLDS, GOLD, BARRELS, MIMICS' 'His order: an experimental menu where he can turn the new features on and off. The things added to the world each get a switch in the EXPERIMENTAL section: strongholds, the golden enemy, the golden clue hunt, the explosive barrels and the mimic crates. A raid started with one off has none of that feature and a raid with it on has it, and the others are untouched. On is the default.' 'Strongholds, the golden enemy, the clue hunt, barrels and mimics each have a switch in EXPERIMENTAL.' $chk
