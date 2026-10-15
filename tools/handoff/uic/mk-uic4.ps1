param([string]$Src='C:\claudecode\dark raiders\dark_raiders.html',[string]$Out='C:\claudecode\dark raiders\tools\handoff\drafts\draft-uic4.json')
. 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\uiclib.ps1'
Css @'
  /* vNN.xx, UI CLEANUP uic4 (his 2026-10-14 note, "ui and player messaging just isn't as clean as it should be", from the 1080p shots of the
     map select screen and the Undercroft floor): THE ANSWER LINE STAYS OFF THE BUTTONS. The line sat 38 px up in the middle of the screen
     whatever was open, so it landed on ASCEND TO THIS SECTOR (the whole bottom of the map select screen is that one button) and, on the
     floor, on the middle cells of the tactical belt (TROPHY EARNED over gun key 4). On the map select screen it rides under the heading
     now; on the bare floor and in a raid it sits above the belt. Windows with a footer that has room keep their own place (v20.89). */
  body:has(#sectormodal.on) #hubtoast{ bottom:auto; top:50px; }
  body:not(:has(.modal.on)):not(:has(#hub.on)):not(:has(#title.on)):not(:has(.outcome.on)):not(:has(.pausebox.on)):not(:has(#attract.on)) #hubtoast{ bottom:150px; }
'@
$chk=@'
  {v:'VER',what:'his 2026-10-14 note (UI cleanup uic4): the answer line stays off the buttons: on the map select screen it does not cover ASCEND TO THIS SECTOR (it sat on it), and on the bare Undercroft floor it rides above the tactical belt (38 px up, on the belt cells)',
   run:function(){
     var t=document.getElementById('hubtoast'), sm=document.getElementById('sectormodal'), go=document.getElementById('sectordeploy');
     if(!t||!sm||!go) return 'SKIP: no answer line or map select screen in this build';
     if(typeof hubToast!=='function'||typeof renderSector!=='function'||typeof openModal!=='function'||!window.__showScreen||!window.__hubEnter) return 'SKIP: this fixture cannot open the map select screen';
     var bad=[], was=sm.classList.contains('on');
     function hit(a,b){ return a.left<b.right&&a.right>b.left&&a.top<b.bottom&&a.bottom>b.top; }
     try{
       __topClear(); __showScreen('hub'); __hubEnter();
       try{ renderSector(); openModal('sectormodal'); }catch(_o){ return 'SKIP: the map select screen did not open here ('+_o+')'; }
       if(!sm.classList.contains('on')||!go.getClientRects().length) return 'SKIP: the map select screen is not on screen here';
       hubToast('QZX TEST LINE');
       var tr=t.getBoundingClientRect(), gr=go.getBoundingClientRect();
       if(hit(tr,gr)) bad.push('the answer line ('+Math.round(tr.left)+','+Math.round(tr.top)+' to '+Math.round(tr.right)+','+Math.round(tr.bottom)+') sits on ASCEND TO THIS SECTOR ('+Math.round(gr.left)+','+Math.round(gr.top)+' to '+Math.round(gr.right)+','+Math.round(gr.bottom)+')');
       __topClear(); __showScreen('hub'); __hubEnter();
       hubToast('QZX TEST LINE');
       var bz=parseFloat(getComputedStyle(t).bottom)||0, z=parseFloat(t.style.zoom)||1;
       if(bz*z<120) bad.push('on the bare floor the answer line is '+Math.round(bz*z)+' px up, on the belt cells (the belt is about 100 px tall)');
       return bad.length?bad.join('; '):null;
     } finally { try{ __topClear(); }catch(_c){} if(!was) sm.classList.remove('on'); t.classList.remove('on'); } }},
'@
Draft 'THE ANSWER LINE STAYS OFF THE BUTTONS' 'His note after playing: the UI and the messages are not as clean as they should be. In the pictures, the one-line answer at the bottom of the screen (TROPHY EARNED, The welcome pack is in your stash.) sat on top of ASCEND TO THIS SECTOR on the map select screen, hiding the button words, and on the Undercroft floor it sat on the middle cells of the tactical belt. It rides under the heading on the map select screen now, and above the belt on the floor and in a raid.' 'The answer line no longer covers ASCEND TO THIS SECTOR or the tactical belt.' $chk
