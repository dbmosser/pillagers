from gen import patch, fixture
patch(1601, [
("""   line:'Storm. The lightning will show you to everything out there.'}""",
"""   line:'Storm. Lightning strikes, and every flash shows you the whole map for a moment.'}   // v16.01, weather audit finding: the old line promised the flash shows you to everything out there, and nothing on the map reads it"""),
("""    if(MW.lightning) wv.push('lightning shows you');""",
"""    if(MW.lightning) wv.push('lightning strikes, and a flash shows you the map');   // v16.01: the flash lifts the fog for you; nothing on the map reads it"""),
("""      // a hard flash that shows the whole street for a moment, which cuts both
      // ways: it reveals the map to you and you to anything looking""",
"""      // a hard flash that shows the whole street for a moment: it lifts the fog sheet
      // for you (above). Nothing on the map reads it; whether it should is his call (v16.01)"""),
], "THE STORM SAYS WHAT THE LIGHTNING DOES. Weather audit finding 9. The storm line said the lightning will show you to everything out there and the CONDITIONS row said lightning shows you, and no sight rule reads the flash: it lifts the fog for you and nothing more. The two lines now say what it does (every flash shows you the whole map for a moment). Neither is a TXSHIP key. Whether a flash should show you to the machines is parked as a question for him. No number moved. Check 16.01 fails on v16.00",
"# THE STORM SAYS WHAT THE LIGHTNING DOES. Weather audit finding 9 (audit-wwhovd0n0.json), its correctedFix: fix the words, not the machines.\n")
fixture(1601, r"""  {v:'16.01',what:'the storm says what the lightning does: the storm line and the CONDITIONS row no longer promise that the flash shows you to the machines, which no sight rule reads, and still say it strikes',
   run:function(){
     if(typeof WEATHER==='undefined'||typeof drawHUD!=='function') return 'SKIP: this build cannot report its weather words';
     var bad=[], st=null, i, hud=String(drawHUD);
     for(i=0;i<WEATHER.length;i++) if(WEATHER[i].id==='storm') st=WEATHER[i];
     if(!st) return 'SKIP: no storm in this build';
     if((/show you to everything/i).test(st.line)) bad.push('the storm line still says the lightning will show you to everything out there: '+st.line);
     if(!(/lightning/i).test(st.line)) bad.push('the storm line no longer names the lightning: '+st.line);
     if((/lightning shows you'/).test(hud)) bad.push('the CONDITIONS row still says lightning shows you');
     if(!(/lightning strikes/).test(hud)) bad.push('the CONDITIONS row no longer names the lightning');
     return bad.length?bad.join('; '):null; }},
""", anchor="  {v:'16.00',what:'rain and fog draw at night strength on")
