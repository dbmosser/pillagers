  {v:'VER',what:'HIS PICK 2026-10-28 (stash option a, "Ok I guess go with A"): the stash loadout column has two tabs, BACKPACK (the 12 slots and the hotbar) and KEYS (gun keys and the item wheel), and the item details strip is a floating card beside the stash item under the mouse or the pad highlight, so nothing resizes; at his 4K screen the 12 backpack slots had no room and the key hints sat on the gun keys',
   run:function(){
     if(typeof renderHub!=='function'||typeof P!=='object'||!P) return 'SKIP: no stash here';
     var bad=[], col=document.getElementById('kitcol'), tabs, bp, bk, ks, grid, d, cell, s0=P.stash, cs=function(e){ return e?getComputedStyle(e).display:'none'; };
     if(!col) return 'no loadout column';
     tabs=document.getElementById('lotabs');
     if(!tabs||!col.contains(tabs)) return 'the loadout column has no tab row';
     bp=tabs.querySelector('button[data-lt="pack"]'); bk=tabs.querySelector('button[data-lt="keys"]');
     if(!bp||!bk) return 'the tab row is not BACKPACK and KEYS';
     if(!/backpack/i.test(bp.textContent)||!/keys/i.test(bk.textContent)) bad.push('the tabs read '+bp.textContent+' and '+bk.textContent);
     grid=document.getElementById('kitgrid'); ks=document.getElementById('kitsetup');
     try{
       bk.click();
       if(!col.classList.contains('lt-keys')) bad.push('KEYS does not switch the column');
       if(cs(ks)==='none') bad.push('on KEYS the gun keys and wheel are hidden');
       if(cs(grid.closest('.losec'))!=='none') bad.push('on KEYS the backpack still shows');
       if(!bk.classList.contains('on')||bp.classList.contains('on')) bad.push('KEYS is not the lit tab after a click');
       bp.click();
       if(col.classList.contains('lt-keys')) bad.push('BACKPACK does not switch back');
       if(cs(ks)!=='none') bad.push('on BACKPACK the gun keys still show');
       if(cs(grid.closest('.losec'))==='none') bad.push('on BACKPACK the backpack is hidden');
       var gt=getComputedStyle(grid).gridTemplateColumns; if(!(/^repeat\(6,/.test(gt)||gt.trim().split(/\s+/).length===6)) bad.push('the backpack is not 6 slots wide ('+getComputedStyle(grid).gridTemplateColumns+')');
       d=document.getElementById('stashdetail');
       if(!d||getComputedStyle(d).position!=='absolute') bad.push('the item details are not a floating card ('+(d?getComputedStyle(d).position:'none')+')');
       P.stash=['medkit','gun_smg'];
       renderHub();
       cell=document.querySelector('#stashgrid .cell');
       if(!cell) bad.push('no stash cell to point at');
       else {
         if(typeof cell.onmouseenter==='function') cell.onmouseenter();
         stashCardAt(cell);
         if(!d.classList.contains('sdon')||!(d.textContent||'').trim()) bad.push('pointing at a stash item shows no card');
         stashCardAt(null);
         if(d.classList.contains('sdon')) bad.push('the card stays up with nothing under it');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ stashTabSet(false); }catch(_t){}
       P.stash=s0;
       try{ renderHub(); }catch(_r){}
       try{ if(d) d.classList.remove('sdon'); }catch(_d){}
     }
     return bad.length?bad.join('; '):null; }},
