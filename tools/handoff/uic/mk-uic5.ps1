param([string]$Src='C:\claudecode\dark raiders\dark_raiders.html',[string]$Out='C:\claudecode\dark raiders\tools\handoff\drafts\draft-uic5.json')
. 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\uiclib.ps1'
Add "  var k=function(t){ return '<b style=`"color:var(--bone)`">'+t+'</b>'; };`n  return k('MOUSE')+' aim &nbsp; '" "  var k=function(t){ return '<b style=`"color:var(--bone)`">'+t+'</b>'; };`n  // v27.xx, UI CLEANUP uic5 (his 2026-10-14 note, from the 1080p shots of the Undercroft and DEMO pause boxes): THE PAUSE BOX LISTS THE KEYS OF WHERE YOU ARE.`n  // The Undercroft box listed the raid (raid status, extraction, drop an item for a teammate) and the DEMO box listed the backpack, ENTER equip, Z drop and ping,`n  // keys a walk-up guest has no use for, in 25 keycaps. The floor lists what the floor legend (H) lists; the DEMO lists the rows of its own controls card.`n  if(typeof state!=='undefined'&&state==='hub') return s('KeyW')+s('KeyA')+s('KeyS')+s('KeyD')+' walk &nbsp; '+s('ShiftLeft')+' jog &nbsp; '+s('Space')+' roll &nbsp; '+s('KeyE')+' use a station &nbsp; '+s('KeyB')+' / '+s('KeyI')+' backpack &nbsp; '+k('TAB')+' pause, or back out';`n  if(typeof G!=='undefined'&&G&&G.arcade&&typeof arcadeCardRows==='function'){ try{ return arcadeCardRows().map(function(r){ return k(r[1])+' '+String(r[0]).toLowerCase(); }).join(' &nbsp; ')+' &nbsp; '+k('TAB')+' pause'; }catch(_ac){} }`n  return k('MOUSE')+' aim &nbsp; '"
$chk=@'
  {v:'VER',what:'his 2026-10-14 note (UI cleanup uic5): the pause box lists the keys of where you are: the Undercroft box has no raid keys (raid status, extraction, drop an item for a teammate), the DEMO box has no backpack, ENTER equip, Z drop or ping, and the raid box is unchanged',
   run:function(){
     if(typeof keysLegendHtml!=='function'||typeof arcadeCardRows!=='function') return 'SKIP: no pause legend or DEMO controls card in this build';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__showScreen&&window.__hubEnter)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g=null, was=null, strip=function(h){ return String(h).replace(/<[^>]*>/g,' ').replace(/&nbsp;/g,' ').replace(/\s+/g,' ').toLowerCase(); };
     var RAIDWORD='raid sta'+'tus', DROPW='drop an item for a '+'teammate';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __showScreen('hub'); __hubEnter();
       var hub=strip(keysLegendHtml());
       if(hub.indexOf(RAIDWORD)>=0||hub.indexOf('extraction')>=0||hub.indexOf(DROPW)>=0) bad.push('the Undercroft pause box lists raid keys: '+hub.slice(0,160));
       if(hub.indexOf('walk')<0||hub.indexOf('backpack')<0) bad.push('the Undercroft pause box does not list walking and the backpack: '+hub.slice(0,160));
       __topClear();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       var raid=strip(keysLegendHtml());
       if(raid.indexOf(RAIDWORD)<0||raid.indexOf(DROPW)<0) bad.push('the raid pause box lost its raid keys: '+raid.slice(0,160));
       was=g.arcade; g.arcade=true;
       var arc=strip(keysLegendHtml());
       g.arcade=was;
       if(arc.indexOf('backpack')>=0||arc.indexOf(DROPW)>=0||arc.indexOf('equip from')>=0||arc.indexOf(RAIDWORD)>=0) bad.push('the DEMO pause box lists keys the DEMO does not have: '+arc.slice(0,160));
       if(arc.indexOf('reload')<0||arc.indexOf('switch gun')<0) bad.push('the DEMO pause box does not list its own controls: '+arc.slice(0,160));
       return bad.length?bad.join('; '):null;
     } finally {
       try{ if(g&&was!==null) g.arcade=was; }catch(_a){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     } }},
'@
Draft 'THE PAUSE BOX LISTS WHERE YOU ARE' 'His note after playing: the UI and the messages are not as clean as they should be. In the pictures, the pause box in the Undercroft listed the raid keys (raid status, extraction, drop an item for a teammate), and the pause box in the party DEMO listed the backpack, ENTER to equip from the backpack, Z to drop for a teammate and ping, which a guest at the machine has no use for. The Undercroft box lists what the floor legend lists now, and the DEMO box lists the rows of its own controls card. The raid box is unchanged.' 'The pause box lists the keys of the place you are in.' $chk
