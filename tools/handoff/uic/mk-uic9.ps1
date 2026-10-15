param([string]$Src='C:\claudecode\dark raiders\dark_raiders.html',[string]$Out='C:\claudecode\dark raiders\tools\handoff\drafts\draft-uic9.json')
. 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\uiclib.ps1'
# both anchors are ASCII on purpose (the line between them carries a middle dot, and a draft is read back as ANSI by the shipper)
Add "  if(!hubWinOn()) ctx.fillText('`$'+P.credits.toLocaleString()+'  \u00b7  XP '+(P.xp||0).toLocaleString()+" "  // v27.xx, UI CLEANUP uic9 (his 2026-10-14 note, from the 1080p shot of the Undercroft): THE FLOOR SAYS ITS MONEY ONCE. The line under the heading printed credits and XP in 9 px`n  // type, the same two numbers the corner readout shows at 32 px; it keeps the stash and the runs, and the readout keeps the money.`n  if(!hubWinOn()) ctx.fillText(("
Add "+P.runs+' run'+(P.runs===1?'':'s'),16,44);   // v8.56: said `"1 runs`" beside a correctly pluralised stash count" "+P.runs+' run'+(P.runs===1?'':'s')).replace(/^\s+\S\s+/,''),16,44);   // v8.56: said `"1 runs`" beside a correctly pluralised stash count"
$chk=@'
  {v:'VER',what:'his 2026-10-14 note (UI cleanup uic9): the line under THE UNDERCROFT says the stash and the runs and no longer prints credits and XP a second time (the corner readout shows them)',
   run:function(){
     if(typeof drawHubHUD!=='function'||typeof __hubEnter!=='function'||typeof __loop!=='function') return 'SKIP: no Undercroft floor here';
     var oFT=ctx.fillText, rec=[], i, st=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       var t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __loop(performance.now()); __loop(performance.now()+17);
       ctx.fillText=function(s){ rec.push(String(s)); return oFT.apply(this,arguments); };
       try{ __loop(performance.now()+34); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
       for(i=0;i<rec.length;i++) if(rec[i].indexOf(' in stash')>=0) st=rec[i];
       if(!st) return 'SKIP: the floor line was not drawn';
       if(!/^\d+ items? in stash\s+\S\s+\d+ runs?$/.test(st)) return 'the line under the heading reads "'+st+'", not the stash and the runs alone';
       return null;
     } finally { try{ __topClear(); __cleanProfile(); }catch(_c){} } }},
'@
Draft 'THE FLOOR SAYS ITS MONEY ONCE' 'His note after playing: the UI is not as clean as it should be. In the pictures, the small line under THE UNDERCROFT in the corner of the floor printed your credits and XP, the same two numbers the big readout in the top right corner already shows, and in 9 pixel type. It says the stash and the runs now and leaves the money to the readout.' 'The line under THE UNDERCROFT no longer repeats credits and XP.' $chk
