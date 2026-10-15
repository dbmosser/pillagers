param([string]$Src='C:\claudecode\dark raiders\dark_raiders.html',[string]$Out='C:\claudecode\dark raiders\tools\handoff\drafts\draft-exp2.json')
. 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\uiclib.ps1'
# EXPERIMENTAL, the raid events: five rows, one guard (the pool an event is drawn from)
Add "  // XF_ROWS_END" @'
  ['xfEvDebris','EVENT \u00b7 ORBITAL DEBRIS','Debris falls in a ring and leaves burning wrecks with loot.','w'],
  ['xfEvConvoy','EVENT \u00b7 MACHINE CONVOY','An armoured train crosses the map. Kill the carrier for its crate.','w'],
  ['xfEvBounty','EVENT \u00b7 BOUNTY PILLAGER','A marked boss hunts you. Down him for $1,500.','w'],
  ['xfEvCool','EVENT \u00b7 COOLANT RUPTURE','A district fogs over: shorter view, double cryo, richer crates.','w'],
  ['xfEvRamp','EVENT \u00b7 OVERSEER RAMPAGE','The Overseer leaves its lair and sweeps the map.','w'],
  // XF_ROWS_END
'@.Replace("`r",'').TrimEnd("`n")
Add "// a LOCAL switch, this window, now" "// a LOCAL switch, this window, now`nvar XF_EV={debris:'xfEvDebris',convoy:'xfEvConvoy',bounty:'xfEvBounty',cool:'xfEvCool',rampage:'xfEvRamp'};   // v27.xx (exp2): the raid event ids that have a switch (an event with no entry here, the lockdown, is always eligible)"
Add "  for(i=0;i<EV_IDS.length;i++){ d=EVENTS[EV_IDS[i]]; if(d&&(!d.ok||d.ok())) out.push(EV_IDS[i]); }" "  for(i=0;i<EV_IDS.length;i++){ d=EVENTS[EV_IDS[i]]; if(d&&(!d.ok||d.ok())&&(!XF_EV[EV_IDS[i]]||xf(XF_EV[EV_IDS[i]]))) out.push(EV_IDS[i]); }   // v27.xx (exp2): an event switched off in EXPERIMENTAL is never drawn for this raid"
$chk=@'
  {v:'VER',what:'his order (EXPERIMENTAL settings, exp2): the five raid events (orbital debris, machine convoy, bounty pillager, coolant rupture, Overseer rampage) each have a row, and one switched off is never drawn for a raid started with it off while the others still are',
   run:function(){
     if(typeof evEligible!=='function'||typeof evPlan!=='function'||typeof arcadeDeploy!=='function') return 'SKIP: no raid events in this build';
     if(typeof XF_EV==='undefined') return 'the raid events have no switches in this build';
     var PAIRS=[['debris','xfEvDebris'],['convoy','xfEvConvoy'],['bounty','xfEvBounty'],['cool','xfEvCool'],['rampage','xfEvRamp']], bad=[], i, j, ids, all, plan, g;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       xfSnap(); all=evEligible();
       openSettings();
       PAIRS.forEach(function(p){ if(!document.getElementById('go_'+p[1])) bad.push('no row for '+p[1]); });
       __topClear();
       for(i=0;i<PAIRS.length;i++){
         if(all.indexOf(PAIRS[i][0])<0) continue;
         CFG[PAIRS[i][1]]=0; xfSnap(); ids=evEligible();
         if(ids.indexOf(PAIRS[i][0])>=0) bad.push(PAIRS[i][0]+' is still drawn with its switch off');
         for(j=0;j<all.length;j++) if(all[j]!==PAIRS[i][0]&&ids.indexOf(all[j])<0) bad.push(all[j]+' went with '+PAIRS[i][0]);
         CFG[PAIRS[i][1]]=1; xfSnap();
       }
       // all five off, a raid started that way plans none of them
       PAIRS.forEach(function(p){ CFG[p[1]]=0; });
       if(!arcadeDeploy({mapIx:0,seed:4242})) return bad.length?bad.join('; '):'SKIP: arcadeDeploy built no raid';
       g=__state(); plan=evPlan({});
       for(i=0;i<plan.length;i++) if(PAIRS.some(function(p){ return p[0]===plan[i].id; })) bad.push('a raid started with the events off planned '+plan[i].id);
       __endRaid('abandon');
       PAIRS.forEach(function(p){ CFG[p[1]]=1; }); xfSnap();
       if(evEligible().length!==all.length) bad.push('switching them back on left '+evEligible().length+' eligible, not '+all.length);
       return bad.length?bad.join('; '):null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       try{ __resetCfg(); xfSnap(); }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     } }},
'@
Draft 'EXPERIMENTAL: THE RAID EVENTS' 'His order: an experimental menu where he can turn the new features on and off. The five raid events each get a switch in the EXPERIMENTAL section: orbital debris, machine convoy, bounty pillager, coolant rupture and Overseer rampage. One switched off is never drawn for a raid started with it off, and the other events are drawn as before. On is the default.' 'The five raid events each have a switch in EXPERIMENTAL.' $chk
