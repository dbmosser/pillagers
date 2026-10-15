param([string]$Src='C:\claudecode\dark raiders\dark_raiders.html',[string]$Out='C:\claudecode\dark raiders\tools\handoff\drafts\draft-uic10.json')
. 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\uiclib.ps1'
Css @'
  /* vNN.xx, UI CLEANUP uic10 (his 2026-10-14 note, "ui and player messaging just isn't as clean as it should be", from the 1080p shots of CHANGE
     KEYS and CHANGE PAD BUTTONS): THE KEY LISTS USE THE WINDOW. The list was one column 1100 px wide in a 1920 px window with the right 40 percent
     empty, and 30 key rows meant scrolling. It is two columns across the window now, each section head across both, so the same rows fit
     in half the height. The rows, the keycaps, REBIND and the note above are unchanged; the pad walks them by place as before. */
  #root #keyslist{ max-width:1500px; display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); column-gap:36px; align-content:start; }
  #root #keyslist .keysec{ grid-column:1 / -1; }
  #root #keysnote{ max-width:1500px; }
'@
$chk=@'
  {v:'VER',what:'his 2026-10-14 note (UI cleanup uic10): CHANGE KEYS and CHANGE PAD BUTTONS list the actions in two columns across the window (one column used 1100 px of 1920 and the right 40 percent was empty)',
   run:function(){
     if(typeof keysOpen!=='function') return 'SKIP: no keys window in this build';
     var bad=[], m=null, was=false;
     try{
       __topClear();
       [false,true].forEach(function(pad){
         keysOpen(pad);
         m=document.getElementById('keysmodal'); var list=document.getElementById('keyslist');
         if(!m||!list||!m.classList.contains('on')){ bad.push('the '+(pad?'pad':'keys')+' window did not open'); return; }
         var cols=String(getComputedStyle(list).gridTemplateColumns||'none').split(' ').filter(function(x){ return x&&x!=='none'; }).length;
         var rows=list.querySelectorAll('.row'), lb=list.getBoundingClientRect(), a=rows[0], b=rows[1];
         if(cols!==2) bad.push('the '+(pad?'pad':'keys')+' list has '+cols+' column(s)');
         else if(a&&b){ var ra=a.getBoundingClientRect(), rb=b.getBoundingClientRect(); if(!(rb.left-ra.left>300)||Math.abs(rb.top-ra.top)>8) bad.push('the first two rows of the '+(pad?'pad':'keys')+' list are not side by side'); }
         if(!(lb.width>1.4*1100*(parseFloat(m.style.zoom)||1)*0.95-10)&&lb.width<1200*(parseFloat(m.style.zoom)||1)) bad.push('the '+(pad?'pad':'keys')+' list is only '+Math.round(lb.width)+' px wide');
       });
       return bad.length?bad.join('; '):null;
     } finally { try{ if(m) m.classList.remove('on'); KEYS.pad=false; }catch(_c){} try{ __topClear(); }catch(_t){} } }},
'@
Draft 'THE KEY LISTS USE THE WINDOW' 'His note after playing: the UI is not as clean as it should be. In the pictures, CHANGE KEYS and CHANGE PAD BUTTONS were one column 1100 pixels wide in a 1920 pixel window, the right 40 percent empty, with thirty rows to scroll through. They list the actions in two columns across the window now, each section heading across both, so the same rows take half the height. The rows, the keycaps and REBIND are unchanged.' 'CHANGE KEYS and CHANGE PAD BUTTONS list the actions in two columns.' $chk
