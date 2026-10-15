param([string]$Src='C:\claudecode\dark raiders\dark_raiders.html',[string]$Out='C:\claudecode\dark raiders\tools\handoff\drafts\draft-uic6.json')
. 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\uiclib.ps1'
Css @'
  /* vNN.xx, UI CLEANUP uic6 (his 2026-10-14 note, "ui and player messaging just isn't as clean as it should be", from the 1080p shots of the
     title, the run cards, the pause box and the full-screen windows): THE CREDITS AND XP READOUT IS FOR THE SCREENS THAT SPEND THEM. It was in
     the top right corner of every screen, over the title, the run cards, the pause box, the DEMO pages, and on the frame line of the welcome
     pack, the map select screen and Settings, where the numbers mean nothing. It stays on the Undercroft floor, the stash and the shop,
     craft, hire, Wirt, bar, Mainframe and Fashion windows. (In a raid it is the HUD's business.) Hidden, not removed: it keeps its place, so
     nothing under it moves. */
  body:has(#title.on) #topright, body:has(.outcome.on) #topright, body:has(.pausebox.on) #topright, body:has(#attract.on) #topright,
  body:has(#welcomemodal.on) #topright, body:has(#sectormodal.on) #topright, body:has(#settingsmodal.on) #topright, body:has(#keysmodal.on) #topright,
  body:has(#partymodal.on) #topright, body:has(#termsmodal.on) #topright{ visibility:hidden; }
'@
$chk=@'
  {v:'VER',what:'his 2026-10-14 note (UI cleanup uic6): the credits and XP readout is hidden on the title, the run card, the pause box, the DEMO pages and the welcome pack, map select, Settings, key, party and terms windows, and still shows on the shop and the stash',
   run:function(){
     var tr=document.getElementById('topright');
     if(!tr) return 'SKIP: no credits readout in this build';
     var bad=[], held=[];
     function vis(){ return getComputedStyle(tr).visibility; }
     function probe(id,want){
       var el=document.getElementById(id); if(!el){ return; }
       var had=el.classList.contains('on'); if(!had) el.classList.add('on');
       try{ var v=vis(); if(want==='hidden'&&v!=='hidden') bad.push(id+' still shows the credits readout'); if(want==='shown'&&v==='hidden') bad.push(id+' hides the credits readout, which it spends'); }
       finally{ if(!had) el.classList.remove('on'); }
     }
     try{
       var on=[].slice.call(document.querySelectorAll('.modal.on,.outcome.on,.pausebox.on,#title.on,#attract.on,#hub.on'));
       on.forEach(function(e){ held.push(e); e.classList.remove('on'); });
       if(vis()==='hidden') return 'SKIP: the readout is hidden with nothing open here';
       ['title','outcome','pausebox','attract','welcomemodal','sectormodal','settingsmodal','keysmodal','partymodal','termsmodal'].forEach(function(id){ probe(id,'hidden'); });
       ['tradermodal','hub','opmodal','gamblemodal','barmodal','appearmodal'].forEach(function(id){ probe(id,'shown'); });
       return bad.length?bad.join('; '):null;
     } finally { held.forEach(function(e){ e.classList.add('on'); }); } }},
'@
Draft 'CREDITS AND XP ONLY WHERE THEY ARE SPENT' 'His note after playing: the UI is not as clean as it should be. In the pictures, the credits and XP readout in the top right corner sat on every screen, over the title, the run cards, the pause box and the party DEMO pages, and on the frame line of the welcome pack, the map select screen and Settings, where the numbers mean nothing. It is hidden on those now and stays on the Undercroft floor, the stash and the shop, craft, hire, Wirt, bar, Mainframe and Fashion windows. In a raid it is left to the HUD.' 'Credits and XP show only on the screens where you spend them.' $chk
