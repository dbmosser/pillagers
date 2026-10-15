param([string]$Src='C:\claudecode\dark raiders\dark_raiders.html',[string]$Out='C:\claudecode\dark raiders\tools\handoff\drafts\draft-exp1.json')
. 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\uiclib.ps1'
# the table, the DEF keys and the snapshot (right before PRESETS, after DEF, so CFG is made with the keys)
$aP="var PRESETS={`n  A:{coneDeg:112,viewFar:540,ambient:125,raidSec:700,nCrawler:13,nSentry:8,lootMult:1.2,noiseMult:1.15},"
$rP=@'
// v27.xx (exp1), HIS ORDER (2026-10-14 night): "create an experimental settings menu inside settings where I can turn new features on and off".
// One row per feature added since v26.54 (the gun feel builds excepted, his words). Every switch is ON by default, so a profile that never opens
// the section plays exactly as before; OFF plays that part of the game as v26.54 did. Each is a DEF key (1), so the host's OFF values ride in the
// raid word (netUpCfgDiff) and a linked window builds and plays the raid under them. WORLD switches ('w') are read from XF, a snapshot taken when
// the raid starts (startRaid), never from CFG during a raid: a change made mid raid starts with the next raid, and on a linked window XF holds the
// host values while its own CFG is put back by netUpStart. LOCAL switches ('l', the Undercroft and display only) are read live from CFG.
// A build that adds a row adds its line above XF_ROWS_END and its guard where the feature starts; a row is listed only when its guard is in.
var XF_ROWS=[
  // [key, label, hint, scope]
  ['xfGoals','RUN GOALS','Three small goals a raid. Each pays a score chip.','w'],
  // XF_ROWS_END
];
var XF_KEYS=[], XF_WORLD=[], XF={};
(function(){ var i; for(i=0;i<XF_ROWS.length;i++){ XF_KEYS.push(XF_ROWS[i][0]); DEF[XF_ROWS[i][0]]=1; if(XF_ROWS[i][3]==='w') XF_WORLD.push(XF_ROWS[i][0]); } })();
function xfSnap(){ var i, k; XF={}; for(i=0;i<XF_WORLD.length;i++){ k=XF_WORLD[i]; XF[k]=(CFG&&CFG[k]===0)?0:1; } return XF; }
function xf(k){ return XF[k]!==0; }                      // a WORLD switch, as this raid was started with it (all ON before any raid)
function xfL(k){ return !(CFG&&CFG[k]===0); }            // a LOCAL switch, this window, now
'@.Replace("`r",'').TrimEnd("`n")
Add $aP ($rP+"`n"+$aP)
# the snapshot, before the raid is built
Add "function startRaid(){`n  if(netGuestHeld()) return false;" "function startRaid(){`n  if(netGuestHeld()) return false;`n  xfSnap();   // v27.xx (exp1): the experimental switches this raid is built and played with (on a linked window: the host values, netUpStart has them in CFG)"
# the guard of the first row
Add "  if(flowPeer()) return;   // v27.27 (coop8): a linked player 2 window counts nothing and pays no chip, the goals are the host (goalsNetTake)" "  if(flowPeer()) return;   // v27.27 (coop8): a linked player 2 window counts nothing and pays no chip, the goals are the host (goalsNetTake)`n  if(!xf('xfGoals')) return;   // v27.xx (exp1): RUN GOALS is switched off in EXPERIMENTAL: no goals are made and no chip is paid"
# the rows, after the GAMEOPTS table
$aG="   ], def:2}`n];`n// v10.28: which option the LIVE dials match, or -1 when a slider has put them"
$rG=@'
// v27.xx (exp1): the EXPERIMENTAL rows, one per XF_ROWS line, ON first so a saved index means the same thing in every later build
(function(){
  var i, r, on, off;
  for(i=0;i<XF_ROWS.length;i++){
    r=XF_ROWS[i]; on={}; off={}; on[r[0]]=1; off[r[0]]=0;
    GAMEOPTS.push({k:r[0],label:r[1],sec:'EXPERIMENTAL',hint:r[2],xf:r[3],opts:[{n:'ON',cfg:on},{n:'OFF',cfg:off}],def:0});
  }
})();
function xfHeadRowHtml(){
  return '<div class="row"><div style="flex:1"><b>NEW SINCE V26.54</b><div class="hint">Off plays that part the old way. A change starts with the next raid. In a party the host decides.</div></div>'+
    '<button id="xf_allon" style="padding:6px 12px;min-width:92px">ALL ON</button></div>';
}
function xfRowNote(r){
  var raid=(typeof G!=='undefined'&&G&&!G.over&&!G.sim), join=(typeof NET==='object'&&NET&&NET.on&&NET.role==='join');
  if(!r||r.xf!=='w') return '';
  if(join) return raid?(' This raid: '+(xf(r.k)?'on':'off')+', as the host set it.'):' In a party the host decides.';
  return raid?' From the next raid.':'';
}
'@.Replace("`r",'').TrimEnd("`n")
Add $aG ("   ], def:2}`n];`n"+$rG+"`n// v10.28: which option the LIVE dials match, or -1 when a slider has put them")
# the section, its lead row, the note and ALL ON
Add "var SETSEC=['THE RAID','AUDIO','CONTROLS','CONTROLLER','DISPLAY','ACCESSIBILITY'];" "var SETSEC=['THE RAID','AUDIO','CONTROLS','CONTROLLER','DISPLAY','ACCESSIBILITY','EXPERIMENTAL'];   // v27.xx (exp1): the section of switches for the features added since v26.54"
Add "setSecsHtml(_SEC,{CONTROLS:keysRowHtml(),CONTROLLER:padRowHtml()})" "setSecsHtml(_SEC,{CONTROLS:keysRowHtml(),CONTROLLER:padRowHtml(),EXPERIMENTAL:xfHeadRowHtml()})"
Add "'<div class=`"hint`">'+_gr.hint+(_gs?'':' Set by hand in the tuning console; click to put a word back on it.')" "'<div class=`"hint`">'+_gr.hint+(_gs?'':' Set by hand in the tuning console; click to put a word back on it.')+((_gr.sec==='EXPERIMENTAL')?xfRowNote(_gr):'')"
Add "    })(GAMEOPTS[_gh].k);`n  }`n" "    })(GAMEOPTS[_gh].k);`n  }`n  var _xa=document.getElementById('xf_allon');   // v27.xx (exp1): ALL ON puts every experimental switch back on`n  if(_xa) _xa.onclick=function(){ var _i; P.gameOpts=P.gameOpts||{}; for(_i=0;_i<XF_KEYS.length;_i++) delete P.gameOpts[XF_KEYS[_i]]; applyGameOpts(); saveProfile(); renderSettings(); };`n"
$chk=@'
  {v:'VER',what:'his order (EXPERIMENTAL settings, exp1): Settings has an EXPERIMENTAL section with a NEW SINCE V26.54 lead row (ALL ON) and one ON/OFF row a switch; the first switch, RUN GOALS, off means no goals are made and none paid in a raid started with it off, on is as before, the choice is saved, and ALL ON puts it back',
   run:function(){
     if(typeof openSettings!=='function'||typeof arcadeDeploy!=='function'||typeof flowTick!=='function') return 'SKIP: no Settings or flow raid in this build';
     if(typeof XF_ROWS==='undefined') return 'there is no EXPERIMENTAL table in this build';
     var bad=[], g, P2=__P(), keep=JSON.stringify(P2.gameOpts||{}), m=document.getElementById('settingsmodal'), was=m&&m.classList.contains('on');
     function row(k){ return document.getElementById('go_'+k); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P2=__P(); P2.gameOpts={};
       openSettings();
       var host=document.getElementById('setlist'), head=document.getElementById('setsec_EXPERIMENTAL'), chip=host&&host.querySelector('.setjump button[data-sec="EXPERIMENTAL"]');
       if(!head||!chip) return 'Settings has no EXPERIMENTAL section and chip';
       if(!document.getElementById('xf_allon')) bad.push('the section has no ALL ON lead row');
       var r=row('xfGoals'); if(!r) return 'there is no RUN GOALS row in the EXPERIMENTAL section';
       if(r.textContent.trim()!=='ON'||DEF.xfGoals!==1||CFG.xfGoals!==1) bad.push('RUN GOALS does not start ON ('+r.textContent.trim()+')');
       // ON: a raid has its three goals
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no raid';
       g=__state(); flowTick(0.1);
       if(!g||!g.flow||!g.flow.goals||g.flow.goals.length!==3) bad.push('with RUN GOALS on the raid has '+(g&&g.flow&&g.flow.goals?g.flow.goals.length:'no')+' goals');
       __endRaid('abandon'); __topClear();
       // OFF through the row, as he does it
       openSettings(); r=row('xfGoals'); r.click();
       r=row('xfGoals');
       if(!r||r.textContent.trim()!=='OFF'||CFG.xfGoals!==0) bad.push('clicking the row did not turn RUN GOALS OFF ('+(r?r.textContent.trim():'no row')+', CFG '+CFG.xfGoals+')');
       if(((__P().gameOpts||{}).xfGoals)!==1) bad.push('the OFF choice is not saved in the profile');
       if(!arcadeDeploy({mapIx:0,seed:4242})) return bad.length?bad.join('; '):'SKIP: arcadeDeploy built no raid';
       g=__state(); flowTick(0.1); flowTick(0.1);
       if(typeof xf==='function'&&xf('xfGoals')) bad.push('the raid was started with RUN GOALS off but the snapshot says on');
       if(g&&g.flow&&g.flow.goals&&g.flow.goals.length) bad.push('with RUN GOALS off the raid still made '+g.flow.goals.length+' goals');
       // a change mid raid waits for the next raid
       CFG.xfGoals=1; if(typeof xf==='function'&&xf('xfGoals')) bad.push('a change in the middle of a raid reached the raid that was running');
       CFG.xfGoals=0;
       __endRaid('abandon'); __topClear();
       // ALL ON
       openSettings(); var a=document.getElementById('xf_allon'); if(a) a.click();
       if(CFG.xfGoals!==1||((__P().gameOpts||{}).xfGoals)!==undefined) bad.push('ALL ON did not put RUN GOALS back (CFG '+CFG.xfGoals+')');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       try{ __P().gameOpts=JSON.parse(keep); __resetCfg(); applyGameOpts(); xfSnap(); }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
       if(m&&!was) m.classList.remove('on');
     } }},
'@
Draft 'EXPERIMENTAL: A SECTION OF SWITCHES' 'His order after playing: an experimental menu inside Settings where he can turn the new features on and off. Settings has a new last section, EXPERIMENTAL, with its own chip and a lead row, NEW SINCE V26.54, with an ALL ON button. Every new feature gets one row, ON by default; OFF plays that part of the game the way v26.54 did. A switch is read when the raid starts and is held for the whole raid, so nothing flips under a live raid, and in a party the host switches rule for both windows. This first build brings the section and its first switch, RUN GOALS: off, a raid makes no goals and pays no chips.' 'Settings has an EXPERIMENTAL section of switches, starting with RUN GOALS.' $chk
