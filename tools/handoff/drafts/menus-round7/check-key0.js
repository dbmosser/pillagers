  {v:'VER',what:'the stash item key row names the tenth hotbar key 0, as the hotbar does (v36.37 gave the hotbar a 9 key and the row printed 10 on its last button, so hovering a Bandage offered 9 one digit keys, not all 10)',
   run:function(){
     if(typeof renderHub!=='function'||typeof ITEMS==='undefined'||!ITEMS.bandage||typeof HOTBAR_N==='undefined'||typeof slotKeyName!=='function') return 'SKIP: no stash key row here';
     var bad=[], prof=null, keep=null, c, a, L, want=[], i;
     try{
       __topClear(); __cleanProfile(); prof=__P();
       keep={s:(prof.stash||[]).slice(),h:JSON.parse(JSON.stringify(prof.hotAssign||{})),t:prof.stashTab};
       prof.stash=['bandage']; prof.hotAssign={}; prof.stashTab='all';
       renderHub();
       c=[].slice.call(document.querySelectorAll('#stashgrid .cell')).filter(function(d){ return String(d.title||'').indexOf(ITEMS.bandage.name+'  x')===0; })[0];
       if(!c) return 'no Bandage cell in the stash';
       c.dispatchEvent(new MouseEvent('mouseenter'));
       a=document.getElementById('stashacts'); if(!a) return 'no key row on the hover';
       L=[].slice.call(a.querySelectorAll('button')).map(function(b){ return String(b.textContent||'').trim(); }).filter(function(t){ return /^\d+$/.test(t); });
       for(i=0;i<HOTBAR_N;i++) want.push(slotKeyName(i));
       if(L.join(',')!==want.join(',')) bad.push('the key row reads '+L.join(',')+', not '+want.join(','));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(prof&&keep){ var q=__P(); q.stash=keep.s; q.hotAssign=keep.h; q.stashTab=keep.t; } }catch(_a){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
