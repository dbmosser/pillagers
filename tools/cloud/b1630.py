from gen import patch, fixture
patch(1630, [
("""      cwo.type='square';
      cwo.frequency.setValueAtTime(520,cwt); cwo.frequency.exponentialRampToValueAtTime(1040,cwt+.24);""",
"""      cwo.type='triangle';   // v16.30, his note: the clock alarms were far too loud; a softer tone at a third of the level
      cwo.frequency.setValueAtTime(520,cwt); cwo.frequency.exponentialRampToValueAtTime(1040,cwt+.24);"""),
("""      cwg.gain.setValueAtTime(.12*vol,cwt); cwg.gain.setValueAtTime(.12*vol,cwt+.2);""",
"""      cwg.gain.setValueAtTime(.04*vol,cwt); cwg.gain.setValueAtTime(.04*vol,cwt+.2);"""),
("""    ckg.gain.setValueAtTime(.09*vol,t); ckg.gain.exponentialRampToValueAtTime(.001,t+.09);""",
"""    ckg.gain.setValueAtTime(.03*vol,t); ckg.gain.exponentialRampToValueAtTime(.001,t+.09);   // v16.30: a third of the level"""),
("""    ctx.fillText(holding?extractNowLine(_exL,G.shipHold):('EXTRACT '+_exL+' INCOMING  '+Math.ceil(G.beaconT)+'s'),W/2,_exBan);""",
"""    ctx.fillText(holding?extractNowLine(_exL,G.shipHold):('EXTRACT '+_exL+' INBOUND  '+Math.ceil(G.beaconT)+'s'),W/2,_exBan);   // v16.30, his word: inbound"""),
], "QUIETER CLOCK ALARMS, AND INBOUND. His notes. The raid clock warnings (5 minutes left and the rest) play a softer tone at a third of the old level, and the last ten seconds tick at a third too. The extraction banner says INBOUND, not INCOMING. No game number moved. Check 16.30 fails on v16.29",
"# QUIETER CLOCK ALARMS, AND INBOUND. His notes of 2026-09-27.\n")
fixture(1630, r"""  {v:'16.30',what:'quieter clock alarms and inbound: the clock warning plays a triangle tone at .04, the tick at .03, and the extraction banner says INBOUND',
   run:function(){
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.length<100000) return 'SKIP: the build cannot read its own script';
     var bad=[];
     if(src.indexOf("cwg.gain.setValueAtTime(.04*vol,cwt)")<0) bad.push('the clock warning is not at .04');
     if(src.indexOf("ckg.gain.setValueAtTime(.03*vol,t)")<0) bad.push('the clock tick is not at .03');
     if(src.indexOf("' INBOUND  '")<0||src.indexOf("' INCOMING  '")>=0) bad.push('the extraction banner does not say INBOUND');
     return bad.length?bad.join('; '):null; }},
""")
