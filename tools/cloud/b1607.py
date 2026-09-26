from gen import patch, fixture
L0 = "  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',"
patch(1607, [
("var WHATSNEW_VER='15.92';", "var WHATSNEW_VER='16.07';"),
(L0, L0 + """
  'YOUR PARTY GOES UP TOGETHER AND SHARES ONE SURFACE. In a party only the host takes the lift, and everyone goes up with them. One of you searches a box at a time and the loot goes to whoever searched it. Hold E beside a downed teammate to pull them up. The clock, the weather, the lightning and the extraction points are the same for everyone, and a beacon any of you calls comes for the party. If the host leaves, the run ends as abandoned for everyone. Pause no longer stops the world in co-op, and a lightning flash shows you to them from farther off.',"""),
], "THE WHAT IS NEW CARD IS CURRENT AGAIN. WHATSNEW_VER stood at 15.92 against 16.06. A new card line after the alpha line says what co-op gained since: the party goes up together, loot per player, teammate revives, one clock, sky and set of extraction points, the host leaving ends the run, pause in co-op, and the lightning flash. Every older line is kept as it was. No number moved. Check 16.07 fails on v16.06",
"# THE WHAT IS NEW CARD IS CURRENT AGAIN (every ~10 builds; WHATSNEW_VER within 0.15 of VER).\n")
fixture(1607, r"""  {v:'16.07',what:'the what is new card is current again: its version is within fifteen builds of the build, it still opens with the alpha line, and the line after it says what co-op gained (going up together, loot to whoever searched, pulling a teammate up, the host leaving)',
   run:function(){
     if(!window.__words||typeof __words.whatsnew!=='function') return 'SKIP: this build cannot report its card';
     var wn=__words.whatsnew(), bad=[], L=wn.lines||[];
     var vNow=parseFloat(String(wn.build||'0').replace(/[^0-9.]/g,''))||0, vCard=parseFloat(String(wn.ver||'0').replace(/[^0-9.]/g,''))||0;
     if(!(vNow&&vCard)) return 'SKIP: no version on the card or the build';
     if(vNow-vCard>0.15) bad.push('the card is at v'+wn.ver+' against a build at v'+wn.build+', more than fifteen builds behind');
     if(!L[0]||String(L[0]).toUpperCase().indexOf('ALPHA')<0) bad.push('the card no longer opens with what an alpha is');
     var t=String(L[1]||'').toUpperCase();
     ['GOES UP TOGETHER','WHOEVER SEARCHED','PULL THEM UP','IF THE HOST LEAVES'].forEach(function(w){ if(t.indexOf(w)<0) bad.push('the second card line does not say '+w.toLowerCase()); });
     return bad.length?bad.join('; '):null; }},
""")
