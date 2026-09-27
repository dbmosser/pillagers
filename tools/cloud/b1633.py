import os, gen
from gen import patch, fixture
o = open('/tmp/card_old.txt').read(); n = open('/tmp/card_new.txt').read()
patch(1633, [
(o, n),
("var WHATSNEW_VER='16.12';", "var WHATSNEW_VER='16.33';"),
], "THE WHAT IS NEW CARD CATCHES UP ON CO-OP. The co-op entry now says what v16.13 to v16.33 gave the party: sound split left and right, teammate health and armour on the HUD, their shots, damage numbers and sounds, your Bandages and plates on a teammate, pause only when every player has paused, the host watching until the party is out, and quieter clock alarms. It no longer says world sound plays from one window. No number moved. Check 16.33 fails on v16.32",
"# THE WHAT IS NEW CARD CATCHES UP ON CO-OP (card was at v16.12).\n")
fixture(1633, r"""  {v:'16.33',what:'the what is new card catches up on co-op: split speakers, teammate health on the HUD, your heals on a teammate, pause when every player has paused, the host watching until the party is out',
   run:function(){
     if(!window.__words||typeof __words.whatsnew!=='function') return 'SKIP: this build cannot report its card';
     var wn=__words.whatsnew(), bad=[], t=String((wn.lines||[])[1]||'').toUpperCase();
     ['LEFT SPEAKER','HEALTH AND ARMOUR','ON A TEAMMATE','EVERY PLAYER HAS PAUSED','THE HOST WATCHES'].forEach(function(w){ if(t.indexOf(w)<0) bad.push('the co-op line does not say '+w.toLowerCase()); });
     if(t.indexOf('ONE OF THE TWO')>=0) bad.push('the co-op line still says world sound plays from one window');
     return bad.length?bad.join('; '):null; }},
""")
_p = os.path.join(gen.H, 'f1633.ps1'); _t = open(_p, encoding='ascii').read()
a = "     if(all.indexOf('SOUND PLAYS FROM ONE OF THE TWO')<0) bad.push('the card does not say world sound plays from one window');"
b = "     if(all.indexOf('LEFT SPEAKER')<0) bad.push('the card does not say where each player sound plays');   // v16.33: split speakers are the default since v16.29"
_t = _t.replace("\n$src = [IO.File]", "\n" + gen.sub(a, b) + "$src = [IO.File]", 1)
open(_p, 'w', encoding='ascii', newline='\n').write(_t)
