param([string]$Src='C:\claudecode\dark raiders\dark_raiders.html',[string]$Out='C:\claudecode\dark raiders\tools\handoff\drafts\draft-uic8.json')
. 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\uiclib.ps1'
Add "    ctx.fillStyle='rgba(6,9,13,.94)'; ctx.fillRect(wnX,wnY,wnW,wnH);`n    ctx.strokeStyle='#3a4552'; ctx.lineWidth=1; ctx.strokeRect(wnX+.5,wnY+.5,wnW-1,wnH-1);" "    // v27.xx, UI CLEANUP uic8 (his 2026-10-14 note, from the 1080p shot of the card over the floor): THE CARD IS THE ONE HUD PLATE, AND SOLID. It was a flat 94 percent`n    // rectangle with its own blue-grey border, unlike every other plate, and the station signs of the floor (SHOP, CRAFT AND HIRE, SETTINGS) read through its words.`n    hudPanel(wnX,wnY,wnW,wnH,1);"
Add "  hudPanel(x,y,PW,hh,0.96);   // v18.13: the one HUD panel" "  hudPanel(x,y,PW,hh,(typeof hubBagG!=='undefined'&&G===hubBagG)?1:0.96);   // v18.13: the one HUD panel   // v27.xx (uic8): solid in the Undercroft, where the station signs read through it; in a raid the world still shows through"
$chk=@'
  {v:'VER',what:'his 2026-10-14 note (UI cleanup uic8): the What is New card and the Undercroft backpack are solid plates (the station signs of the floor read through both at 94 and 96 percent)',
   run:function(){
     if(!(window.__wnseen&&window.__hubEnter&&window.__hubFrame&&window.__showScreen&&window.__hubBagSet)||typeof hudPanel!=='function'||typeof drawHubBag!=='function') return 'SKIP: this fixture cannot draw the floor card and the backpack';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], P2=__P(), keepRuns=P2.runs, hp=hudPanel, seen=[], wide, said=false, proto=CanvasRenderingContext2D.prototype, oft=proto.fillText;
     try{
       __topClear(); __runPrep();
       P2.runs=Math.max(1,keepRuns||0);
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       hudPanel=function(x,y,w,h,a){ seen.push({w:w,h:h,a:(a===undefined?0.88:a)}); return hp.apply(this,arguments); };
       proto.fillText=function(t){ if(String(t).indexOf('NEW IN v')===0) said=true; return oft.apply(this,arguments); };
       __wnseen(0); __hubFrame(0.016);
       proto.fillText=oft;
       if(!said) return 'SKIP: the card was not drawn here';
       wide=seen.filter(function(s){ return s.w>=600&&s.h>=120; });
       if(!wide.length) bad.push('the What is New card is a flat rectangle, not the HUD plate');
       wide.forEach(function(s){ if(s.a<0.99) bad.push('the What is New card plate is '+Math.round(s.w)+'x'+Math.round(s.h)+' at '+Math.round(s.a*100)+' percent, not solid'); });
       seen.length=0; __wnseen(1);
       __hubBagSet(true); drawHubBag(); __hubBagSet(false);
       wide=seen.filter(function(s){ return s.w>=600&&s.h>=120; });
       if(!wide.length) return bad.length?bad.join('; '):'SKIP: the Undercroft backpack was not drawn as a plate here';
       wide.forEach(function(s){ if(s.a<0.99) bad.push('the Undercroft backpack plate is '+Math.round(s.w)+'x'+Math.round(s.h)+' at '+Math.round(s.a*100)+' percent, not solid'); });
       return bad.length?bad.join('; '):null;
     } finally { hudPanel=hp; proto.fillText=oft; try{ __hubBagSet(false); }catch(_b){} P2.runs=keepRuns; __wnseen(1); try{ saveProfile(); }catch(_s){} try{ __topClear(); __cleanProfile(); }catch(_c){} } }},
'@
Draft 'THE FLOOR CARD AND BACKPACK ARE SOLID' 'His note after playing: the UI is not as clean as it should be. In the pictures, the What is New card on the Undercroft floor was a flat plate at 94 percent with its own blue-grey border, unlike every other panel, and the Undercroft backpack was a plate at 96 percent; the big station signs (SHOP, CRAFT AND HIRE, THE STASH, SETTINGS) showed through the words of both. They are the one solid game plate now, with the amber tick. In a raid the backpack still lets the world show through.' 'The What is New card and the Undercroft backpack are solid plates.' $chk
