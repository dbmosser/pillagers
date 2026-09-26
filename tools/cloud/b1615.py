import os, gen
from gen import patch, fixture
SRC = open(os.path.join(gen.H, '..', '..', 'dark_raiders.html'), encoding='utf-8').read().split('\n')
def lines(pairs, only=None):
    out = []
    for i, ln in enumerate(SRC):
        nl = ln
        for a, b in pairs:
            if a in nl: nl = nl.replace(a, b)
        if nl != ln:
            if only and not any(o in ln for o in only): continue
            out.append((ln, nl))
    return out
P = [
 ("Your host is out. The raid runs on until you are out.", "Host has left the raid. Extract to finish your run."),
 ("Your party is still up top. The raid runs on until they are out.", "Your party is still in the raid. Waiting for them to finish."),
 ("Your party is still up top. The lift waits until they are out.", "Cannot ascend while your party is still in the raid."),
 ("Your party is back down. The raid is over.", "Your party is back. Raid over."),
 ("Your host takes the party up. Stay here and you go up together.", "Only the host can start the raid. You ascend with them."),
 ("'Picking up '+nm+'. Keep holding '+keyLabel('KeyE','E')+'.'", "'Reviving '+nm+'. Hold '+keyLabel('KeyE','E')+'.'"),
 ("say('You pull '+nm+' up.');", "say(nm+' revived.');"),
 ("say((netSeatName(by)||'Your teammate')+' pulls you up.');", "say('Revived by '+(netSeatName(by)||'a teammate')+'.');"),
 ("YOUR HOST LEFT THE SURFACE. THE RUN ENDS AS ABANDONED FOR THE WHOLE PARTY.", "HOST LEFT THE RAID. RUN ABANDONED."),
 ("THE LINK TO YOUR HOST WAS LOST. THE RUN ENDS AS ABANDONED FOR THE WHOLE PARTY.", "CONNECTION TO HOST LOST. RUN ABANDONED."),
 ("Your host left the surface. The run counts as abandoned for the whole party.", "Host left the raid. Run abandoned."),
 ("The link to your host was lost. The run counts as abandoned for the whole party.", "Connection to host lost. Run abandoned."),
 ("' called the extraction. Inbound '+Math.ceil(Z.beaconT)+'s.'", "' called extraction. Inbound in '+Math.ceil(Z.beaconT)+'s.'"),
 ("Storm. Lightning strikes, and every flash shows you the map and shows you to them from farther off.", "Storm. Lightning lights up the map, and every flash makes you visible from farther away."),
 ("'lightning strikes, and a flash shows you to them from farther'", "'lightning strikes: flashes reveal you from farther away'"),
 ("'Everyone linked hears you. Wear a headset.'", "'Open mic: your party can hear you. Headset recommended.'"),
 ("'Hold Y to talk. Wear a headset.'", "'Hold Y to talk. Headset recommended.'"),
 ("'Press MIC to talk to your party. The browser asks first.'", "'Turn on MIC to use voice chat.'"),
 ("'Mic on. Everyone linked hears you.'", "'Mic on. Open mic.'"),
 ("'The microphone was not allowed ('+netErrText(e)+'). Emotes still work.'", "'Microphone access was blocked ('+netErrText(e)+').'"),
 ("'This browser cannot use a microphone here.'", "'Voice chat is not available in this browser.'"),
 ("'The browser gave no microphone.'", "'No microphone found.'"),
 ("'Asking the browser for the microphone.'", "'Requesting microphone access.'"),
 ("Hold E beside a downed teammate to pull them up.", "Hold E next to a downed teammate to revive them."),
 ("if the host extracts or dies, the raid runs on until the rest of you are out.", "if the host extracts or dies, the rest of the party keeps playing."),
]
E = lines(P)
E.append(("  label(p.x,p.y-22,'PICKED UP','#4de3d0',0,true);\n  return 'up';", "  label(p.x,p.y-22,'REVIVED','#4de3d0',0,true);\n  return 'up';"))
missing = [a for a, b in P if not any(a in o for o, n in E)]
assert not missing, missing
patch(1615, E, "PLAIN GAME LANGUAGE FOR CO-OP. His note: the co-op lines read like a rulebook. Every line added for co-op, the storm and voice now reads the way a game says it: Reviving NAME, Revived by NAME, Host has left the raid, Your party is still in the raid, Only the host can start the raid, Connection to host lost, and the storm, CONDITIONS row and voice lines in the same plain style. Text only. Check 16.15 fails on v16.14",
"# PLAIN GAME LANGUAGE FOR CO-OP. His note of 2026-09-26 on how the new lines read. Text only.\n")
fixture(1615, r"""  {v:'16.15',what:'plain game language for co-op: the lines added for co-op, the storm and voice read the way a game says them, and none of the old rulebook sentences is left in the build',
   run:function(){
     var src='', bad=[], i, OLD, NEW;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     if(src.length<100000) return 'SKIP: the build cannot read its own script';
     // the game's own code only: the fixture hooks start at window.__frame, and comment lines are history, not text on screen
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     src=src.split('\n').filter(function(l){ return !(/^\s*\/\//).test(l); }).map(function(l){ var k=l.indexOf('   // '); return k>=0?l.slice(0,k):l; }).join('\n');
     OLD=['The raid runs on until','still up top. The','back down. The raid','takes the party up. Stay','Keep holding','pulls you up.'+String.fromCharCode(39)+');','LEFT THE SURFACE. THE RUN','THE WHOLE PARTY.'+String.fromCharCode(39),'every flash shows you the map and','Wear a headset','The browser asks first','Emotes still work'];
     NEW=['Host has left the raid','Waiting for them to finish','Only the host can start the raid','Reviving ','Revived by ','CONNECTION TO HOST LOST','every flash makes you visible','Headset recommended'];
     for(i=0;i<OLD.length;i++) if(src.indexOf(OLD[i])>=0) bad.push('the rulebook line with "'+OLD[i]+'" is still in the build');
     for(i=0;i<NEW.length;i++) if(src.indexOf(NEW[i])<0) bad.push('the line "'+NEW[i]+'" is missing');
     return bad.length?bad.join('; '):null; }},
""")
_p = os.path.join(gen.H, 'f1615.ps1'); _t = open(_p, encoding='ascii').read()
MK = open(os.path.join(gen.H, '..', 'mkfixture.ps1'), encoding='utf-8').read().split('\n')
extra = ''
for a, b in [("(/Your host takes the party up/)", "(/Only the host can start the raid/)"), ("'PULL THEM UP'", "'REVIVE THEM'")]:
    ln = [x for x in MK if a in x]; assert len(ln) == 1, a
    extra += gen.sub(ln[0], ln[0].replace(a, b))
_t = _t.replace("\n$src = [IO.File]", "\n" + extra + "$src = [IO.File]", 1)
open(_p, 'w', encoding='ascii', newline='\n').write(_t)
