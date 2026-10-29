  {v:'VER',what:'HIS ORDER 2026-10-28 (menus master chat): "I am confused by keyboard keys vs in game keys, can we call the in game keys something else?" Every item that opens a sealed room is a KEYCARD (Turbine Room Keycard), the stash filter tab reads KEYCARDS, a keycard on the ground is a keycard to a sealed room, and the Data Core lines say keycard; keys now only means keys you press',
   run:function(){
     if(typeof ITEMS!=='object'||typeof renderHub!=='function'||typeof gearLabel!=='function') return 'SKIP: no items here';
     var bad=[], k, n=0, tb, t, g;
     for(k in ITEMS){ if(ITEMS[k]&&ITEMS[k].use==='key'){ n++; if(!/ Keycard$/.test(ITEMS[k].name)) bad.push(k+' is named '+ITEMS[k].name+', not a keycard'); } }
     if(n<10) bad.push('only '+n+' sealed room items');
     for(k in ITEMS){ if(ITEMS[k]&&/\bKeys?\b/.test(ITEMS[k].name||'')) bad.push('item '+k+' still says key: '+ITEMS[k].name); }
     t=gearLabel({kind:'key'})||''; if(!/keycard/i.test(t)||/\bkey\b/i.test(t)) bad.push('a keycard on the ground reads: '+t);
     try{ renderHub(); }catch(e){}
     tb=document.getElementById('stashtabs');
     if(tb){ t=(tb.textContent||'').toLowerCase(); if(t.indexOf('keycards')<0) bad.push('the stash tabs have no keycards tab ('+t.slice(0,160)+')'); if(/\bkeys\b/.test(t)) bad.push('a stash tab still reads keys'); }
     else bad.push('no stash tab row');
     g=(typeof TXSHIP==='object')?TXSHIP['Spend a Data Core ($520 on the shelf) and your next raid deploys knowing things: every locked-room key location and every elite, live on the M map. None in the stash right now.']:null;
     if(!g||!/keycard/.test(g)||/\bkey\b/.test(g)) bad.push('his Data Core line reads: '+g);
     return bad.length?bad.join('; '):null; }},
