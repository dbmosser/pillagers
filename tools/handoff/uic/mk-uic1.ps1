param([string]$Src='C:\claudecode\dark raiders\dark_raiders.html',[string]$Out='C:\claudecode\dark raiders\tools\handoff\drafts\draft-uic1.json')
. 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\uiclib.ps1'
Css @'
  /* vNN.xx, UI CLEANUP uic1 (his 2026-10-14 note, "ui and player messaging just isn't as clean as it should be", from the 1080p shot of the
     abandon confirm): THE ABANDON CONFIRM IS A TWO BUTTON QUESTION. Arming it left five buttons in one row, YES, ABANDON THIS RUN, RESUME
     RUN, SETTINGS, FEEDBACK and NO, KEEP PLAYING, 1050 px of buttons in an 825 px box, hanging out of both frame edges, with RESUME RUN
     and NO, KEEP PLAYING doing one job. While it is armed the box shows only the YES he arms on the far side (v4.24) and the NO on the
     button he just pressed; ESC still closes the box. Nothing is reworded. */
  #root #pausebox.asking #resumebtn, #root #pausebox.asking #pausesetbtn, #root #pausebox.asking #fbbtn, #root #pausebox.asking #charselbtn{ display:none !important; }
'@
Add "    cb.style.display='inline-block';`n    this.textContent='NO, keep playing';" "    cb.style.display='inline-block';`n    this.textContent='NO, keep playing';`n    try{ var _pbx=document.getElementById('pausebox'); if(_pbx) _pbx.classList.add('asking'); }catch(_as){}   // v27.xx (uic1): only YES and NO while it is armed"
Add "  // second press on the same button is the NO: disarm and go back.`n  cb.style.display='none';" "  // second press on the same button is the NO: disarm and go back.`n  cb.style.display='none';`n  try{ var _pbx2=document.getElementById('pausebox'); if(_pbx2) _pbx2.classList.remove('asking'); }catch(_as2){}   // v27.xx (uic1)"
Add "  if(_ca) _ca.style.display='none';" "  if(_ca) _ca.style.display='none';`n  try{ var _pbx3=document.getElementById('pausebox'); if(_pbx3) _pbx3.classList.remove('asking'); }catch(_as3){}   // v27.xx (uic1): every disarm gives the box its buttons back"
$chk=@'
  {v:'VER',what:'his 2026-10-14 note (UI cleanup uic1): the abandon confirm is a two button question: armed, the pause box shows YES, ABANDON and NO, KEEP PLAYING and nothing else, and every button stays inside the box frame (it ran about 110 px out of the frame on both sides)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof togglePauseBox!=='function'||typeof disarmAbandon!=='function') return 'SKIP: no pause box in this build';
     var ab=document.getElementById('abandonbtn'), cb=document.getElementById('confirmabandon'), pb=document.getElementById('pausebox');
     if(!ab||!cb||!pb||typeof ab.onclick!=='function') return 'SKIP: no abandon button or confirm in this build';
     var bad=[], g=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       togglePauseBox(true);
       if(!pb.classList.contains('on')) return 'SKIP: the pause box did not open here';
       ab.onclick.call(ab);
       if(cb.style.display==='none') return 'SKIP: the press did not arm the confirm here';
       var fr=pb.getBoundingClientRect(), bs=pb.querySelectorAll('button'), i, r, shown=[];
       for(i=0;i<bs.length;i++){
         if(!bs[i].getClientRects().length) continue;
         r=bs[i].getBoundingClientRect(); if(r.width<2||r.height<2) continue;
         shown.push(bs[i].id||bs[i].textContent);
         if(r.left<fr.left-1||r.right>fr.right+1) bad.push((bs[i].id||bs[i].textContent)+' is '+Math.round(Math.max(fr.left-r.left,r.right-fr.right))+'px outside the box frame');
       }
       if(shown.length!==2||shown.indexOf('confirmabandon')<0||shown.indexOf('abandonbtn')<0) bad.push('armed, the box shows '+shown.join(', ')+' and not just YES and NO');
       disarmAbandon();
       var back=0; for(i=0;i<bs.length;i++) if(bs[i].id==='resumebtn'&&bs[i].getClientRects().length) back=1;
       if(!back) bad.push('disarming did not bring RESUME RUN back');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ disarmAbandon(); }catch(_d){}
       try{ if(pb.classList.contains('on')) togglePauseBox(false); }catch(_t){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     } }},
'@
Draft 'THE ABANDON CONFIRM IS TWO BUTTONS' 'His note after playing: the UI and the messages are not as clean as they should be. In the pictures, pressing Abandon run put five buttons in one row, YES ABANDON, RESUME RUN, SETTINGS, FEEDBACK and NO KEEP PLAYING, about 1050 pixels of buttons in an 825 pixel box, hanging out past both edges of the frame, with RESUME RUN and NO KEEP PLAYING doing the same job. While the question is up the box now shows only YES and NO. The YES stays on the far side as before, and ESC still closes the box.' 'Abandon run now asks with just two buttons, YES and NO, inside the box.' $chk
