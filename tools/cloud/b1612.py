from gen import patch, fixture
o1 = open('/tmp/card_old1.txt').read(); o2 = open('/tmp/card_old2.txt').read()
new = """  'YOUR PARTY GOES UP TOGETHER AND SHARES ONE SURFACE. The mode menu opens a second window for your other screen with its own controller, and world sound plays from one of the two. In a party only the host takes the lift: the party ascends together and sees each other up top. The pillagers and machines are one set for everyone: they go for whoever is nearest, your hits and kills count in your own tally, and nobody in your party can hurt you. One of you searches a box at a time and the loot goes to whoever searched it. Hold E beside a downed teammate to pull them up. The clock, the weather, the lightning and the extraction points are the same for everyone, and a beacon any of you calls comes for the party. If the host leaves, the run ends as abandoned for everyone. Pause no longer stops the world in co-op. C crouches even with Shift held when you are out of breath, a controller leaves the end of raid card with B, holding ESC or P no longer flickers the pause box, a pillager grenade sounds where it lands, a lightning flash shows you to the enemy from farther off, and only a Medkit takes you past 85.',"""
patch(1612, [
(o1 + "\n" + o2, new),
("var WHATSNEW_VER='16.07';", "var WHATSNEW_VER='16.12';"),
], "THE WHAT IS NEW CARD FITS AGAIN AND SAYS WHAT IS TRUE. The v16.07 line pushed the welcome pack entry off the thirteen the card draws, so check 13.34 failed. The co-op line and the party line are one entry now. It no longer says the second window has its own sound (world sound plays from one window) and says the lightning flash shows you to the enemy. No number moved. Check 16.12 fails on v16.11",
"# THE WHAT IS NEW CARD FITS AGAIN (backcheck: check 13.34 failed since v16.07; two claims were wrong).\n")
fixture(1612, r"""  {v:'16.12',what:'the what is new card fits again and says what is true: the co-op entry says world sound plays from one window, not that the second has its own; the lightning line names the enemy',
   run:function(){
     if(!window.__words||typeof __words.whatsnew!=='function') return 'SKIP: this build cannot report its card';
     var wn=__words.whatsnew(), bad=[], L=wn.lines||[], all=L.join(' ').toUpperCase();
     if(all.indexOf('WITH ITS OWN CONTROLLER AND SOUND')>=0) bad.push('the card still says the second window has its own sound');
     if(all.indexOf('SOUND PLAYS FROM ONE OF THE TWO')<0) bad.push('the card does not say world sound plays from one window');
     if(all.indexOf('SHOWS YOU TO THE ENEMY')<0) bad.push('the lightning line does not name who the flash shows you to');
     return bad.length?bad.join('; '):null; }},
""")
