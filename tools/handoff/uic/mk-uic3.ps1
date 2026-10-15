param([string]$Src='C:\claudecode\dark raiders\dark_raiders.html',[string]$Out='C:\claudecode\dark raiders\tools\handoff\drafts\draft-uic3.json')
. 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\uiclib.ps1'
Add "  openModal('settingsmodal');`n}`ndocument.getElementById('exportbtn').onclick=function(){ openSettings('rec'); };" "  openModal('settingsmodal');`n  // v27.xx, UI CLEANUP uic3 (his 2026-10-14 note): the section chip in view is worked out now the window is on screen. It was worked out while the window`n  // was still hidden, where every section head measures zero, so Settings opened with ACCESSIBILITY lit over a list that starts at THE RAID.`n  try{ var _scl=document.getElementById('setlist'); if(_scl&&typeof setSecSpy==='function') setSecSpy(_scl); }catch(_sp){}`n}`ndocument.getElementById('exportbtn').onclick=function(){ openSettings('rec'); };"
$chk=@'
  {v:'VER',what:'his 2026-10-14 note (UI cleanup uic3): Settings opens with the chip of the section in view lit, THE RAID at the top (it opened with ACCESSIBILITY lit over a list that starts at THE RAID), and only one chip is lit',
   run:function(){
     if(typeof openSettings!=='function'||typeof setSecSpy!=='function') return 'SKIP: no sectioned Settings in this build';
     var m=document.getElementById('settingsmodal'), was=m&&m.classList.contains('on');
     if(!m) return 'SKIP: no Settings window';
     var bad=[];
     try{
       try{ __topClear(); }catch(_t){}
       openSettings();
       var host=document.getElementById('setlist'); if(!host) return 'SKIP: no settings list';
       host.scrollTop=0;
       var chips=host.querySelectorAll('.setjump button'); if(chips.length<3) return 'SKIP: the section chips are not drawn here';
       var lit=[], i; for(i=0;i<chips.length;i++) if(chips[i].classList.contains('on')) lit.push(chips[i].getAttribute('data-sec'));
       var first=chips[0].getAttribute('data-sec');
       if(lit.length!==1||lit[0]!==first) bad.push('opened at the top with '+(lit.length?lit.join(' + '):'no chip')+' lit, not '+first);
       setSecJump(host,chips[chips.length-1].getAttribute('data-sec')); setSecSpy(host);
       lit=[]; for(i=0;i<chips.length;i++) if(chips[i].classList.contains('on')) lit.push(chips[i].getAttribute('data-sec'));
       if(lit.length!==1||lit[0]!==chips[chips.length-1].getAttribute('data-sec')) bad.push('jumped to the last section with '+(lit.length?lit.join(' + '):'no chip')+' lit');
       return bad.length?bad.join('; '):null;
     } finally { try{ __topClear(); }catch(_c){} if(!was) m.classList.remove('on'); } }},
'@
Draft 'SETTINGS OPENS ON THE RIGHT CHIP' 'His note after playing: the UI is not as clean as it should be. In the pictures, Settings opened with the ACCESSIBILITY chip lit over a list that starts at THE RAID, so the bar pointed at the wrong section until the first scroll. The chip in view is worked out once the window is on screen now.' 'Settings opens with the THE RAID chip lit, not ACCESSIBILITY.' $chk
