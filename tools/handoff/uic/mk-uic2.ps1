param([string]$Src='C:\claudecode\dark raiders\dark_raiders.html',[string]$Out='C:\claudecode\dark raiders\tools\handoff\drafts\draft-uic2.json')
. 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\uiclib.ps1'
Css @'
  /* vNN.xx, UI CLEANUP uic2 (his 2026-10-14 note, "ui and player messaging just isn't as clean as it should be", from the 1080p shots of
     the extracted, killed and abandoned cards): THE RUN CARD ENDS ON THE RESULT. Twenty-nine feedback tags and a note box took more than
     half of every run card (the haul reveal card ran past the screen and cut the bottom tag row off behind the buttons). HOW DID THAT RUN
     FEEL is a bar that opens them now, shut on every new card, a button so the pad reaches it. Every tag and the note work as before. */
  #root .ocwin .fbhead{ appearance:none; display:inline-flex; align-items:center; gap:10px; margin-top:12px; padding:9px 16px; min-height:0 !important; min-width:0 !important;
    background:transparent; border:1px solid var(--ui-line); border-radius:0; color:var(--tx-2); font-family:var(--f-cond); font-weight:700; font-size:13px; letter-spacing:.14em;
    text-transform:uppercase; cursor:pointer; }
  #root .ocwin .fbhead:hover, #root .ocwin.fbopen .fbhead{ color:var(--tx-1); border-color:var(--tx-3, #8a96a1); }
  #root .ocwin .fbhead::after{ content:'+'; color:var(--acc); font-size:17px; line-height:1; }
  #root .ocwin.fbopen .fbhead::after{ content:'\2212'; }
  #root .ocwin:not(.fbopen) #tagwrap, #root .ocwin:not(.fbopen) #oc_note{ display:none; }
'@
Add '  <div style="font-size:13px;color:var(--ash);letter-spacing:.12em;margin-top:16px">HOW DID THAT RUN FEEL</div>' '  <button type="button" class="fbhead" id="fbhead">HOW DID THAT RUN FEEL</button>   <!-- v27.xx (uic2): opens the tags and the note; shut on every new card -->'
Add "function buildTags(){`n  var w=document.getElementById('tagwrap'); w.innerHTML='';" "// v27.xx, UI CLEANUP uic2: the bar over the feedback tags opens and shuts them (the card shuts them whenever it comes up)`n(function(){ var h=document.getElementById('fbhead'), w=h&&h.closest?h.closest('.ocwin'):null; if(h&&w) h.addEventListener('click',function(){ w.classList.toggle('fbopen'); }); })();`nfunction buildTags(){`n  var w=document.getElementById('tagwrap'); w.innerHTML='';"
Add "  selTags=[]; buildTags();`n  document.getElementById('oc_note').value='';" "  selTags=[]; buildTags();`n  try{ var _fbw=document.querySelector('#outcome .ocwin'); if(_fbw) _fbw.classList.remove('fbopen'); }catch(_fbo){}   // v27.xx (uic2): every card comes up with the tags shut`n  document.getElementById('oc_note').value='';"
$chk=@'
  {v:'VER',what:'his 2026-10-14 note (UI cleanup uic2): a run card comes up with the feedback tags shut behind the HOW DID THAT RUN FEEL bar (the 29 tags took more than half of the card), the bar opens them (all 29 still there, the note too), and the next card is shut again',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var oc=document.getElementById('outcome'), tw=document.getElementById('tagwrap'), card=oc&&oc.querySelector('.ocwin');
     if(!oc||!tw||!card) return 'SKIP: no run card in this build';
     var bad=[], g=null;
     function card1(how){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return false;
       __endRaid(how);
       return oc.classList.contains('on');
     }
     try{
       if(!card1('dead')) return 'SKIP: the run card did not come up here';
       var hd=document.getElementById('fbhead'), note=document.getElementById('oc_note');
       if(!hd) return 'the run card has no bar over the feedback tags, so all of them are always out';
       if(tw.getClientRects().length||note.getClientRects().length) bad.push('the tags or the note are showing on a fresh card');
       var h0=card.getBoundingClientRect().height;
       hd.click();
       if(!tw.getClientRects().length||!note.getClientRects().length) bad.push('the bar did not open the tags and the note');
       var nt=tw.querySelectorAll('.tag').length; if(nt<20) bad.push('only '+nt+' tags are in the card');
       var h1=card.getBoundingClientRect().height; if(!(h1>h0+60)) bad.push('opening the tags added '+Math.round(h1-h0)+' px to the card, it was shut at '+Math.round(h0));
       var t0=tw.querySelector('.tag'); if(t0){ t0.click(); if(!t0.classList.contains('sel')) bad.push('a tag does not take a click when it is open'); }
       if(!card1('dead')) return 'SKIP: the second run card did not come up here';
       if(tw.getClientRects().length) bad.push('the next card came up with the tags still open');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ oc.classList.remove('on'); }catch(_o){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     } }},
'@
Draft 'THE RUN CARD ENDS ON THE RESULT' 'His note after playing: the UI and the messages are not as clean as they should be. In the pictures, every run card carried twenty-nine feedback tags and a note box, more than half of the card; on the haul reveal card the tags ran past the screen and the bottom row was cut off behind the buttons. The heading HOW DID THAT RUN FEEL is a bar now that opens the tags and the note, and every new card comes up with them shut. All the tags are still there and a controller reaches the bar.' 'The run cards end on the result, with the feedback tags behind a bar that opens them.' $chk
