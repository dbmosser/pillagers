  {v:'VER',what:'menus master polish 2026-10-28: a Mainframe contract pays in dollars ($4,321, never 4,321 c: his rule $ for money), and the achievements list marks a locked one with a lock icon instead of the word LOCKED glued to its name, an earned one in its own colour',
   run:function(){
     if(typeof renderConDetail!=='function'||typeof renderStatCards!=='function'||typeof ACHS==='undefined') return 'SKIP: no Mainframe panes here';
     var d=document.getElementById('condetail'); if(!d||!document.getElementById('statgrid')) return 'SKIP: no Mainframe panes in this page';
     var bad=[], c0=P.contracts, s0=P._conSel, a0=P.ach, m, el, rows, i, lk, on;
     try{
       // ONE: the contract reward reads dollars
       P.contracts=[{type:'kill',tgt:'sentry',n:3,prog:0,reward:4321,desc:'Destroy 3 Sentries',tier:'hard',gear:null}]; P._conSel=0;
       renderConDetail(); m=d.querySelector('.crewc');
       if(!m) bad.push('the contract card has no reward figure');
       else if((m.textContent||'').trim()!=='$4,321') bad.push('the contract reward reads "'+(m.textContent||'').trim()+'", not $4,321');
       // TWO: the achievements list
       P.ach={}; P.ach[ACHS[0].id]=1;
       renderStatCards();
       el=document.getElementById('achlist');
       if(!el) bad.push('no achievements list');
       else {
         if(/\bLOCKED\b/.test(el.textContent||'')) bad.push('a locked achievement still has the word LOCKED glued to its name');
         rows=el.querySelectorAll('.achrow');
         if(rows.length!==ACHS.length) bad.push('the list has '+rows.length+' achievement rows, not '+ACHS.length);
         for(lk=0,on=0,i=0;i<rows.length;i++){ if(rows[i].classList.contains('achon')) on++; else if(rows[i].querySelector('svg.achlk')) lk++; }
         if(on!==1) bad.push(on+' rows are marked earned, not 1');
         if(lk!==ACHS.length-1) bad.push(lk+' locked rows carry the lock icon, not '+(ACHS.length-1));
         if(rows.length>1&&getComputedStyle(rows[0].querySelector('span')).color===getComputedStyle(rows[1].querySelector('span')).color) bad.push('the earned name has the same colour as a locked one');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       P.contracts=c0; P._conSel=s0; P.ach=a0;
       try{ renderConDetail(); }catch(_r){} try{ renderStatCards(); }catch(_r2){} }
     return bad.length?bad.join('; '):null; }},
