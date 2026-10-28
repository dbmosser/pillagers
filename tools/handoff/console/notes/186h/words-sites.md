# 186h words build (cw-pillagersword): every player-facing "pillager bot" and bare "machine" (sweep 10-28, line numbers of v35.66)

## helper: Kind to player name: KINDWORD map at line 6461 (continues on 6462), with kindWord(k) at line 6463. It is upper case and covers sentry, crawler, raider, snitch (CRIER), listener, choir (PILLBOX), warden, bulwark, howler, stray (SURVIVOR) and peddler (THE PEDDLER). There is no overseer entry, so the fallback String(k).toUpperCase() gives 'OVERSEER'. The usual pattern is e.name||kindWord(e.kind) (used at 23329, 31766, 63594), plus netPingName at 62617. UNITNAME at line 6456 is the lower-case singular and UNITPLURAL at line 6448 is the plural; both cover only sentry, crawler, raider, snitch and listener. killWord(e) at line 6464 gives DESTROYED for a machine and ELIMINATED for raider, stray or p
- 8208 [machine] say('MACHINE ALERT','info')  inside alarmOk(wx,wy). This is the left-feed 'machine alert' his order names.
  scope: No entity: alarmOk(wx,wy) gets only a position. It is called from sfx(type,wx,wy,wid) at 8230 for every 'alarm' sound, and sfxHere at 8192 goes through sfx too. Callers that hold a machine e: 15536 (listener wake); 32062 and 32072 (listener hit; the colleague missed 32072); 26169 and 26180 (overseer phase and sweep); 32111 and 32669 (howler); 32264 (warden); 32354 and 32399 (crier, kind snitch); 32582 (sentry, crawler or crier spot shout; it already uses the 4th arg wid as the string 'crawler', so wid cannot carry the entity). Callers that are not machines but still print MACHINE ALERT today: 11627 and 11630 (lightning, sfxHere); 23771 (notoriety); 28868 (extraction ship z); 29729 (seal); 30147 and 64298 (strongbox); 54973 (site burn). Co-op: sfx sends the sound to the party at 8231 via netFxNoise(type,wx,wy,wid) at 61780, after alarmOk passes. The guest window replays it through its own alarmOk, so it also needs the kind sent with it or it will print a bare alert.
  do: Add a 5th argument for the source entity: sfx('alarm',e.x,e.y,wid,e) and alarmOk(wx,wy,src). The feed line becomes (src.name||kindWord(src.kind))+' ALERT', drawn lower case: 'crier alert', 'sentry alert', 'listener alert', 'howler alert', 'warden alert', 'overseer alert'. Send the kind word through netFxNoise or the fx message so the guest prints the same name. When the source is not a machine (lightning, notoriety, extraction ship, seal, strongbox, burn), print no line or name the cause ('strongbox alarm'). Never print a bare 'machine alert'.
- 8479 [machine] say('LOCKED ON','warn',{key:'msiren',sub:'MACHINE HAS YOU IN SIGHT'})  in tickMachSiren
  scope: near, the nearest entity that passes machSirenCounts, picked in the loop at 8473. n is the count of locked machines (MSIREN.n). Name helper: near.name||kindWord(near.kind).
  do: sub:(near.name||kindWord(near.kind))+' HAS YOU IN SIGHT' (for example 'sentry has you in sight'). When n>1: if all are one kind, use the plural ('2 sentries have you in sight'; this needs UNITPLURAL entries for warden, bulwark, howler and choir). Otherwise use the nearest kind plus ' +'+(n-1).
- 6690 [machine] desc:'Hit '+up(2)+' machine weak points, then extract'  (conduct contract card)
  scope: No entity: this is contract generation. The kinds with weak points (WEAKPTS, 14365) are sentry (vent, optic), warden (core seam, optic), bulwark (exposed spine) and choir/pillbox (slit, spine).
  do: 'Hit '+up(2)+' weak points on sentries, wardens, bulwarks or pillboxes, then extract'. Shorter: 'Hit '+up(2)+' sentry or warden weak points, then extract'.
- 4208 [machine] ['xfFeud','machines vs pillagers','they fight on sight','w']  (Settings, experimental page row)
  scope: No entity. Per the guard at 15240, sentries and crawlers always pick pillagers as foes, plus bulwark and plain warden under xfFeud.
  do: 'sentries and crawlers vs pillagers' (or 'sentries, crawlers, wardens vs pillagers'). Line 4259 has to change with it.
- 4259 [pillager bot] .replace(/^pillager roles$/i,'pillager bot roles').replace(/^machines vs pillagers$/i,'machines vs pillager bots')  (rewrites the experimental labels on screen)
  scope: Settings label DOM node (label.textContent). No entity.
  do: Delete both replaces and keep only the 'event: ' strip. The rows then show 'pillager roles' and the new xfFeud label. Today this line puts both 'pillager bot' and a bare 'machines' on screen.
- 4216 [pillager bot] ['xfEvBounty','event: bounty pillager bot','a marked boss hunts you','w']  (shows as 'bounty pillager bot')
  scope: No entity (settings row). The same words are in the in-raid event name EVENTS.bounty at 66293 ('BOUNTY PILLAGER BOT'), which is outside this range.
  do: 'event: bounty pillager' (shows 'bounty pillager'). Change EVENTS.bounty.name at 66293 to 'BOUNTY PILLAGER' to match.
- 4215 [machine] ['xfEvConvoy','event: machine convoy','an armoured train crosses','w']  (shows as 'machine convoy')
  scope: No entity. EVENTS.convoy at 66223 has name 'MACHINE CONVOY' and sub 'ARMOURED TRAIN'; line 66198 calls it an armoured crawler train. It also appears in the MSGCUTA regex at 23483.
  do: 'event: crawler convoy'. Rename EVENTS.convoy.name to 'CRAWLER CONVOY' and update MSGCUTA at 23483 to match (both outside this range).
- 4222 [machine] ['xfTell','aim lanes','a machine paints its aim','w']  (Settings, experimental hint)
  scope: No entity. Per 38722, only sentry and warden paint their aim; 40760 adds the howler shell landing circle.
  do: Hint: 'sentries and wardens paint their aim'.
- 4525 [machine] acid:{...,w2:'SHRED · ANTI-MACHINE'}  (forge element tag, drawn at 14996, 22889, 46377)
  scope: No entity. Acid does 1.25x damage to every ELEM_MACH kind (31309) at 21853 and 33688.
  do: 'SHRED · ANTI-ARMOUR' (every machine kind is affected, so a kind list would be long). Keep the ' · ' separator because 14996 splits on it.
- 6448 [pillager bot] var UNITPLURAL={...,raider:'pillager bots',...}
  scope: Used by the kill contract desc at 6624 ('Destroy '+n+' '+UNITPLURAL[tgt]) and at 49282. tgt is the contract kind (sentry, crawler, raider or snitch).
  do: raider:'pillagers'. Make 6624 say 'Eliminate' for raider, matching killWord. Add warden:'wardens', bulwark:'bulwarks', howler:'howlers', choir:'pillboxes', overseer:'overseers' so counts can name kinds.
- 6456 [pillager bot] var UNITNAME={...,raider:'pillager bot',...}
  scope: Singular for contract text (6624, 49282) and the HUD at 58163.
  do: raider:'pillager'. Also add the missing machine kinds (warden, bulwark, howler, choir:'pillbox', overseer).
- 6461 [pillager bot] var KINDWORD={...,raider:'PILLAGER BOT',...}  (kindWord: kill labels, pings, name fallback)
  scope: Used by e.name||kindWord(e.kind) at 23329, 31766 and 63594, and by netPingName at 62617.
  do: raider:'PILLAGER'. Add overseer:'OVERSEER' explicitly so every machine kind has an entry.
- 4798 [machine] 'Machines too tough' and, on 4799, 'Machines pushovers'  (TAGS at 4787, the feedback chips drawn at 35664)
  scope: No entity (feedback tag chips). Each tag string is also the stored data key. TAGFWD at 4784 already maps an old tag to its shown new name (tagText at 4785).
  do: Rename the chips in TAGS to 'Sentries too tough' and 'Crawlers pushovers' (the two most common machines), or to 'Robots too tough' and 'Robots pushovers', the word his own edits use. Add TAGFWD entries from the old strings to the new ones so old saved tags show the new words.
- 11992 [machine] Story note THE MANIFEST: '... The machines keep the cold chain unbroken. Nobody has told them to stop.'  (lore note read in the raid)
  scope: No entity. Map story note; lore about the enemy faction as a whole.
  do: Low priority (lore). If it must comply: 'The sentries keep the cold chain unbroken.'
## helper: KINDWORD map + kindWord(k) at dark_raiders.html lines 6461-6463 (sentry SENTRY, crawler CRAWLER, raider 'PILLAGER BOT' which must become 'PILLAGER', snitch CRIER, listener LISTENER, choir PILLBOX, warden WARDEN, bulwark BULWARK, howler HOWLER, stray SURVIVOR, peddler THE PEDDLER). kindWord does not cover the Overseer, which is a warden with e.boss (e.name===BOSS_NAME, 'THE OVERSEER', line 15583). netPingName at line 62617 is the closest existing helper that checks boss, but it returns the boss's full name and a pillager's personal name, so the machine alert needs a small machWord(e): e.boss -> 'OVERSEER', otherwise kindWord(e.kind), and nothing for raider, stray or peddler. UNITNAME at line 
- 20679 [pillager bot] ['WORLD',[[n(2),'search / open / call for extraction'],[n(3),'search in a ring; hold to finish a pillager bot'],...
  scope: none (static legend row)
  do: 'search in a ring; hold to finish a pillager'. Player-facing: padLegendBuild feeds LEGEND_PAD (line 20693), shown in the controls panel (line 20518) and the pause controls list (line 45985) when a pad is on.
- 22211 [pillager bot] var _fName=_fMine?(f.nm||'YOUR OWN CHARGE'):((f.by.name||'A PILLAGER BOT')+"'S CHARGE");
  scope: f.by = the thrower ent. Only pillagers throw frags (by:e at line 28537, in the raider grenade code), so it is always kind raider; name from f.by.name. If kind is ever needed, use kindWord(f.by.kind) after KINDWORD.raider becomes 'PILLAGER'.
  do: fallback 'A PILLAGER' (the death screen reads A PILLAGER'S CHARGE). f.by.name normally wins, so the fallback shows only when the thrower has no name.
- 23488 [pillager bot] ['b',/^(EXTRACTION \S+ IS CLOSED|PILLAGER BOT CALLED EXTRACTION)$/],
  scope: none at the regex; at 33275 e is the pillager ent (sub uses e.name) and z is the extraction zone
  do: Not drawn itself: MSGKEEP left-feed routing regex. Change it to PILLAGER CALLED EXTRACTION in the same ship as the say at line 33275 (outside this range). If only one side changes, the line loses its 'b' routing (near or in sight only).
- 28631 [pillager bot] if(!G.sim) say('PILLAGER BOT REINFORCEMENTS','warn');
  scope: NR (the new pillager ent from mkRaider at line 28620)
  do: say('PILLAGER REINFORCEMENTS','warn'). Lowered at draw: 'pillager reinforcements'.
- 23487 [machine] ['a',/^(MACHINE ALERT|OVERSEER RETURNS)$/],
  scope: none at the regex; each caller must hand alarmOk its entity
  do: This is the routing regex for the 'machine alert' lines he named. The line itself is said at line 8208 (outside this range) in alarmOk(wx,wy). alarmOk only gets a position, through sfx('alarm',x,y,wid) at line 8230; sfx's 4th argument is already taken by the crawler variant (line 32582). Fix: pass the source ent as a new 5th sfx argument down to alarmOk(wx,wy,src). Then say machWord(src)+' ALERT' (SENTRY ALERT, CRAWLER ALERT, LISTENER ALERT, CRIER ALERT, PILLBOX ALERT, WARDEN ALERT, BULWARK ALERT, HOWLER ALERT, OVERSEER ALERT), and say nothing when src is missing or is not a machine. Widen this regex to /^(.+ ALERT|OVERSEER RETURNS)$/ (or list the kinds) so the 'a' routing still matches. In this range the callers that raise the line are 15536, 23771, 26169, 26180, 28868 and 29729 (below).
- 15536 [machine] sfx('alarm',e.x,e.y);
  scope: e (kind listener; the Listener hearing sweep). kindWord(e.kind) gives 'LISTENER'
  do: This caller raises MACHINE ALERT (through alarmOk) when a Listener wakes. Pass e so the line reads LISTENER ALERT. The next line, 'SOMETHING WOKE UP' (15538), also names no kind; optional fix: 'LISTENER WOKE UP'.
- 23771 [machine] try{ sfx('alarm',G.player.x,G.player.y); }catch(_ns){}
  scope: none (notoStamp; no enemy, only G.player)
  do: The notoriety stamp plays the alarm cue at the player's own spot, so a MACHINE ALERT line comes up when no machine is involved. Pass no source and have alarmOk say no line. The NOTORIETY alert just above already explains it.
- 26169 [machine] G.shake=Math.max(G.shake||0,6); sfx('alarm',e.x,e.y); ping(e.x,e.y,900,false,false,'robot','fire',e);
  scope: e (warden with e.boss, the Overseer; overseerTick). kindWord gives 'WARDEN', which is wrong for him: check e.boss or e.name===BOSS_NAME first and use 'OVERSEER'
  do: The Overseer changes phase and the line reads MACHINE ALERT. Pass e: OVERSEER ALERT. ovPhaseLine (line 26136) already says OVERSEER CALLS CRAWLERS or OVERSEER SWEEP LASER right after, so it would also be fine to show no alert line here.
- 26180 [machine] if(e.chgT<=0){ e.chgT=0; e.windup=null; e.swpT=OV_SWEEP; e.swpTk=0; e.face=e.swpA; if(!G.sim) sfx('alarm',e.x,e.y); }
  scope: e (the Overseer, e.boss). Name: OVERSEER (boss check before kindWord)
  do: The Overseer fires its sweep laser and the line reads MACHINE ALERT. Pass e: OVERSEER ALERT.
- 28868 [machine] if(dist(p,z)<1400){ sfxHere('touchdown',z.x,z.y); sfxHere('alarm',z.x,z.y);
  scope: z (the extraction zone, not an enemy)
  do: The extraction ship's touchdown plays the alarm cue (sfxHere goes through sfx and then alarmOk), so MACHINE ALERT comes up when no machine is involved. Pass no source and show no line; EXTRACT IN PROGRESS! follows on the next line.
- 29729 [machine] if(!G.sim) sfx('alarm',G.seal.x,G.seal.y);
  scope: G.seal (an objective, not an enemy)
  do: The seal plays the alarm cue every half second while it is worked, so it can raise MACHINE ALERT when no machine is involved. Pass no source and show no line.
- 23483 [machine] var MSGCUTA=/^(NOTORIETY |CONVOY MOVING$|MACHINE CONVOY$|COOLANT RUPTURE$|GATE BREACHED$|YOUR RIVAL IS UP TOP$)/;
  scope: none (a world event; its bodies are crawlers)
  do: Not drawn itself: a feed cut regex that matches the raid event name EVENTS.convoy.name 'MACHINE CONVOY' (line 66223; design line 66198 says it is 'an armoured crawler train'). The event callout is player-facing and names no kind. Rename it 'CRAWLER CONVOY' (sub 'ARMOURED TRAIN' stays) and change this regex in step, or the line stops being cut. The SPK_INFO labels at lines 9048 and 9064 say MACHINE CONVOY too (sound list, outside this range).
## helper: kindWord(k) is at line 6463. It reads the KINDWORD table at line 6461: sentry SENTRY, crawler CRAWLER, raider PILLAGER BOT, snitch CRIER, listener LISTENER, choir PILLBOX, warden WARDEN, bulwark BULWARK, howler HOWLER, stray SURVIVOR, peddler THE PEDDLER. Any other kind falls back to the uppercased internal id. killWord(e) at line 6464 picks ELIMINATED or DESTROYED. UNITNAME at line 6456 is the lower-case table (raider 'pillager bot'). Both raider entries are outside 30001-45000 but feed line 31766, and changing them there fixes every caller. I re-grepped 30001-45000 with comment lines removed, matching quoted strings with machine, MACHINES, the machine, a machine, robot(s), bot, bots, BOT, 
- 31589 [pillager bot] label(e.x,e.y-16,(e.name||'PILLAGER BOT')+' DOWNED','#ffc04a',0,true);
  scope: e, an AI pillager (kind raider) in its downed branch (e.downed=1, e.state='down' just above). This is a floating world label drawn only when canSee says the player can see him. The fallback only shows when e.name is empty.
  do: (e.name||'PILLAGER')+' DOWNED'
- 31766 [pillager bot] label(e.x,e.y-16,(e.name||kindWord(e.kind))+killWord(e),e.kind==='raider'?'#ff5a4a':'#ffc04a',0,true);
  scope: e, any enemy that dies. kindWord(e.kind) at line 6463 reads KINDWORD at line 6461, which is outside this range, and there raider:'PILLAGER BOT'. Machines already get their own kind name here (SENTRY, CRAWLER, CRIER, LISTENER, PILLBOX, WARDEN, BULWARK, HOWLER), so this line never prints a bare 'machine'.
  do: Leave this line alone and fix the table instead: KINDWORD.raider 'PILLAGER BOT' -> 'PILLAGER' at line 6461, and UNITNAME.raider 'pillager bot' -> 'pillager' at line 6456 (both outside this range). An unnamed pillager kill then reads PILLAGER ELIMINATED.
- 32554 [pillager bot] if(!G.sim) say('PILLAGER BOT TURNED HOSTILE','warn',{sub:e.name});
  scope: e, an AI pillager (inside if(e.kind==='raider'&&!e.hostile)). e.name is already the sub line.
  do: say('PILLAGER TURNED HOSTILE','warn',{sub:e.name})
- 33275 [pillager bot] if(!G.sim&&chatNear(z.x,z.y)) say('PILLAGER BOT CALLED EXTRACTION','info',{sub:String(e.name)+', Extraction '+extLetter(z)});
  scope: e is the AI pillager calling extraction; z is the extraction zone.
  do: say('PILLAGER CALLED EXTRACTION','info',{sub:String(e.name)+', Extraction '+extLetter(z)}). The sub line stays the same, and the headline is now shorter than the 34-character cap.
- 33986 [machine] desc:'40% more machines, pillager bots and criers.'
  scope: No entity in scope. This is the HEAVY PATROLS description in the TERMS table, drawn on the pre-raid terms board by renderTerms (line 55895). The 1.40 _patMul (line 16969) multiplies den, which feeds nOf/nOfM. That scales N_SENTRY, N_CRAWLER, N_SNITCH (criers) and N_RAIDER (pillagers) at lines 16979-16980, the crawler-per-house floor at line 17016, and also N_BULWARK (17147), N_HOWLER (17149) and N_LISTEN (17175). The colleague missed those last three. Pillboxes and wardens are not scaled. Display names come from KINDWORD (line 6461).
  do: desc:'40% more sentries, crawlers, listeners, howlers, bulwarks, criers and pillagers.' This names every kind it actually scales and drops 'pillager bots'. It is a lot of words, so a shorter honest choice is 'every enemy count +40%'.
- 34005 [pillager bot] desc:'Every pillager bot is hostile and already searching for you.'
  scope: No entity in scope. This is the THEY KNOW YOU description in the TERMS table, drawn on the terms board by renderTerms (line 55895).
  do: desc:'Every pillager is hostile and already searching for you.'
- 35879 [pillager bot] L.push('Downs: '+downs+'  |  Self-revives: '+revs+'  |  Pillager bots extracted: '+rExt);
  scope: No entity in scope. This is BOT SIM report text, shown in the simmodal tuning dialog (textContent at about line 35889) and saved to P.lastSim. It is a dev/tuning screen, not raid UI, so it is low priority. On lines 35868 ('BOT SIM') and 35873 ('Bot accuracy'), 'bot' means the sim stand-in for the player, not AI pillagers, so those lines are not in scope.
  do: 'Pillagers extracted: '+rExt
- 36322 [machine] {id:'outrobot',    name:'The Machine',       how:'warden:3',     kind:'outfit'},
  scope: No entity in scope. This is the name of an outfit in the COSMETICS list, shown on the cosmetics rack. It unlocks from 3 Warden kills and draws with mark 'robot' (line 36612). It names a costume, not an enemy callout, but it does put the bare word 'machine' on screen.
  do: Rename it to 'The Warden', which matches how it unlocks. If he counts costume names as fine, leave it as is.
- 44933 [pillager bot] hudPrompt('['+keyLabel('KeyE','E')+'] REVIVE '+String(G.nearDown.name||'PILLAGER BOT').toUpperCase()+
  scope: G.nearDown. It is set only at line 29797 to downRdr, which is a downed AI pillager (DE.kind==='raider'&&DE.downed) within 64 px. It is never a teammate, so the colleague's 'or teammate' was wrong. The fallback only shows when .name is empty.
  do: String(G.nearDown.name||'PILLAGER').toUpperCase()
## helper: kindWord(k) at dark_raiders.html line 6463 reads the KINDWORD map at lines 6461-6462 (sentry SENTRY, crawler CRAWLER, raider 'PILLAGER BOT', snitch CRIER, listener LISTENER, choir PILLBOX, warden WARDEN, bulwark BULWARK, howler HOWLER, stray SURVIVOR, peddler THE PEDDLER). For a live entity use e.name||kindWord(e.kind). killWord(e) is at line 6464. KINDWORD.raider (line 6461, outside 45001-60000) is the root 'PILLAGER BOT' string: change it to 'PILLAGER' and every kindWord caller follows. I re-grepped 45001-60000 for machine, MACHINES, robot, 'BOT ', ' BOTS', 'the machine', 'a machine' and quoted BOT/BOTS literals. I agree with the colleague's list: nothing to drop, nothing missed, and no in
- 47101 [pillager bot] ctx.fillText('CURRENT PILLAGER BOTS  '+live,PADX,y0-LH(2))  (HUD left board title, live count of AI pillagers)
  scope: live = count of live AI pillagers (HUDBOX.raiders board)
  do: 'CURRENT PILLAGERS  '+live
- 47209 [pillager bot] rsText('CURRENT PILLAGER BOTS  '+RSTAT.live,...)  (Raid Status overlay, hold Alt / View)
  scope: RSTAT.live count
  do: 'CURRENT PILLAGERS  '+RSTAT.live
- 55332 [pillager bot] say('No Data Core in your stash. Find them in rare containers or on elite pillager bots.')
  scope: none (Undercroft slotCore button)
  do: say('no data core in your stash. find them in rare containers or on elite pillagers.')
- 55655 [pillager bot] VENDOR_LINES.work: 'Half the pillager bots down here walk past scrap. Their loss.'
  scope: none (workshop vendor rotating line)
  do: 'half the pillagers down here walk past scrap. their loss.'
- 56055 [pillager bot] renderMercDetail: '<div class="vpills"><span class="vpill">PILLAGER BOT</span>' (merc hire detail tag)
  scope: ID = IDENTITIES[P._mercSel||0] (a hirable AI pillager)
  do: '<span class="vpill">PILLAGER</span>'
- 58018 [pillager bot] ACHS pill25: n:'PILLAGER HUNTER', d:'Kill 25 pillager bots in all.'
  scope: none; counts P.achN.raider (kills of kind raider), achRun line 58028
  do: d:'kill 25 pillagers in all.' (the name PILLAGER HUNTER and the id pill25 stay)
- 58019 [machine] ACHS mach100: n:'MACHINE BREAKER', d:'Kill 100 machines in all.'
  scope: none; a count over every non-raider kill kind (achRun line 58028: if(k==='raider') pr+=v; else mc+=v). That covers sentry, crawler, snitch, listener, choir, warden, bulwark and howler, and also stray and peddler
  do: Keep the id mach100 (the save key; the comment at 58380 shows saves carry it). Use n:'SCRAP MAKER' and d:'kill 100 sentries, crawlers and criers in all.' (the most common kinds). Side bug: mc also counts survivor and peddler kills, so line 58028 should skip stray and peddler.
- 58127 [pillager bot] _bits.push('You earn it by attacking someone who was not a threat: the Peddler, an unarmed survivor, or a pillager bot who had not fought you.') (Notoriety card)
  scope: none
  do: '... the peddler, an unarmed survivor, or a pillager who had not fought you.'
- 58133 [pillager bot] _bits.push('Pillager bots need '+(2+clamp(Math.round(_n),0,3))+' tries to stand down instead of 2.') (Notoriety card)
  scope: none
  do: 'pillagers need '+(2+clamp(...))+' tries to stand down instead of 2.'
- 46486 [pillager bot] LEGEND_PAD WORLD row: ['Y','search in a ring; hold to finish a pillager bot']
  scope: none. This is only the initial value: line 20693 rebuilds LEGEND_PAD from padLegendBuild, which holds the same string at line 20679 (outside the range). The panel is drawn at 45985 and 47491. Fix both.
  do: 'search in a ring; hold to finish a pillager'
- 46473 [pillager bot] SOUNDKEY: [SNDCOL.raider.move,'pillager bot moving']
  scope: none. SOUNDKEY appears only once in the file (dead data, never drawn)
  do: 'pillager moving' (or delete SOUNDKEY)
- 46474 [pillager bot] SOUNDKEY: [SNDCOL.raider.fire,'pillager bot firing']
  scope: none (dead data, never drawn)
  do: 'pillager firing'
- 46471 [machine] SOUNDKEY: [SNDCOL.robot.move, 'machine moving']
  scope: none; SNDCOL.robot is the shared colour for every machine kind. Dead data, never drawn
  do: 'sentry or crawler moving' (or delete SOUNDKEY)
- 46472 [machine] SOUNDKEY: [SNDCOL.robot.fire, 'machine firing']
  scope: none (dead data, never drawn)
  do: 'sentry or pillbox firing'
- 50156 [pillager bot] SLIDERS ['nRaider','Pillager bots',0,20,1,0]
  scope: none. Tuning console behind the Dev tools button
  do: 'Pillagers'
- 50163 [machine] SLIDERS ['packMax','Machines that answer a call',0,10,1,0]
  scope: none. packCall (line 15413) recruits only sentry, crawler and snitch. Dev tools tuning console
  do: 'sentries, crawlers, criers that answer a call'
- 50177 [pillager bot] SLIDERS ['raiderExtract','Seconds a pillager bot must hold the ring',3,30,1,1]
  scope: none (tuning console)
  do: 'seconds a pillager must hold the ring'
- 50187 [pillager bot] SLIDERS ['raiderFeud','Pillager bot crews feud (0 truce)',0,1,1,1]
  scope: none (tuning console)
  do: 'pillager crews feud (0 truce)'
- 50193 [pillager bot] SLIDERS ['raiderFloorN','Min pillager bots alive',0,10,1,1]
  scope: none (tuning console)
  do: 'min pillagers alive'
- 55415 [pillager bot] ROADMAP DONE: 'DECIDED and SHIPPED at v7.29: a pillager bot walking out tries a revive for a crewmate near his path.'
  scope: none. Dev tools roadmap list (renderRoadmap), history text
  do: '... a pillager walking out tries a revive ...'
- 55421 [pillager bot] ROADMAP DONE: 'Pillager bots play like people: they roll, aim, crouch over crates, and bolt for the extraction'
  scope: none (Dev tools roadmap)
  do: 'Pillagers play like people: ...'
- 55436 [pillager bot] ROADMAP DONE: 'Plain-language raid settings: pillager bots, machines, damage, length, loot, heat'
  scope: none (Dev tools roadmap); the line also has a bare 'machines'
  do: 'Plain-language raid settings: pillagers, sentries, crawlers, criers, damage, length, loot, heat'
- 55438 [pillager bot] ROADMAP DONE: 'Pillager bots that equip what they loot, heal, throw, and arrive in waves'
  scope: none (Dev tools roadmap)
  do: 'Pillagers that equip what they loot, heal, throw, and arrive in waves'
- 55439 [pillager bot] ROADMAP DONE: 'One status verb for you and for every pillager bot on the board'
  scope: none (Dev tools roadmap)
  do: '... every pillager on the board'
- 55449 [machine] ROADMAP DONE: 'Machines that answer a call and take roles: pin, flank, rush'
  scope: none (Dev tools roadmap); the packCall kinds are sentry, crawler and snitch
  do: 'Sentries, crawlers and criers answer a call and take roles: pin, flank, rush'
- 55451 [machine] ROADMAP DONE: 'Machine voices: tell a Sentry from a Crawler with your eyes shut'
  scope: none (Dev tools roadmap); the sentence already names the kinds
  do: 'Sentry and crawler voices: tell a Sentry from a Crawler with your eyes shut'
- 55461 [pillager bot] ROADMAP DONE: 'Bushes you can hide in, and pillager bots who hide in them too'
  scope: none (Dev tools roadmap)
  do: '... and pillagers who hide in them too'
- 55479 [pillager bot] DEVNOW.next: 'His ruling on the pillager bots: machines at war with them (his Q31) plus the floor rule ...' (Dev tools roadmap UP NEXT row)
  scope: none. DEVNOW (line 55477) is maintained by the ship pipeline; the line also has a bare 'machines'
  do: 'His ruling on the pillagers: sentries, crawlers and the rest at war with them ...' (ship-tool text, so make the fix in the ship step, not by hand)
## helper: kindWord(k) at line 6463 turns a kind into the player's word. It reads KINDWORD at 6461-6462: sentry SENTRY, crawler CRAWLER, raider 'PILLAGER BOT', snitch CRIER, listener LISTENER, choir PILLBOX, warden WARDEN, bulwark BULWARK, howler HOWLER, stray SURVIVOR, peddler THE PEDDLER. killWord(e) is at 6464. An older lower-case table, UNITNAME, is at 6456 (raider 'pillager bot'). Both tables sit outside 60001-80000 but feed sites inside it: netPingName at 62617 calls kindWord. Change their raider entries to 'PILLAGER' and 'pillager', and make goldDownName (66852) call kindWord instead of using the raw kind. The boss's name is BOSS_NAME='THE OVERSEER' at 15583. An AI pillager's typed name is in e.
- 65741 [pillager bot] pill3:{t:'3 PILLAGER BOTS',n:3,chip:400}
  scope: none (static GOALS table, 65739-65742). t is copied into the raid goals and drawn on the goals panel under CONDITIONS, and in the GOAL DONE callout
  do: t:'3 PILLAGERS'. This goal is current player text.
- 66293 [pillager bot] EVENTS.bounty={name:'BOUNTY PILLAGER BOT',sub:'HE HUNTS YOU',...
  scope: def (event table). The hunter is ev.d.e, made by arcadeWaveRaider at 66313 (kind 'raider', e.bounty=1). def.name is said at event start (66039), drawn on the event bar (66049/66052 'txt=def.name...') and used as the map pin label (66071), and on player 2 too (67147)
  do: name:'BOUNTY PILLAGER'
- 66329 [pillager bot] flowChip(BOUNTY.pay,'BOUNTY CLAIMED','BOUNTY PILLAGER BOT')
  scope: e = ev.d.e (the bounty hunter, kind 'raider'). flowChip (65774) says head with sub+'  +$n' in the 'ext' lane
  do: flowChip(BOUNTY.pay,'BOUNTY CLAIMED','BOUNTY PILLAGER'), or his own name: (e.name?String(e.name).toUpperCase():'BOUNTY PILLAGER')
- 66852 [pillager bot] function goldDownName(kind){ return 'golden '+(kind==='raider'?'pillager bot':(GOLD.kinds[kind]?kind:'enemy'))+' down'; }
  scope: only kind (no entity). Callers: goldDrop(x,y,kind) at 66861 and S.kind at 67307 (player 2), both say(...,'obj'). GOLD.kinds (66823) = crawler, sentry, raider, bulwark, howler, listener
  do: 'golden '+(kind==='raider'?'pillager':(GOLD.kinds[kind]?kindWord(kind).toLowerCase():'enemy'))+' down'. kindWord is at 6463; its KINDWORD raider entry must also become 'PILLAGER' (see note).
- 66223 [machine] EVENTS.convoy={name:'MACHINE CONVOY',sub:'ARMOURED TRAIN',warn:20,...
  scope: def (event table). The crew is made at 66247-66248: ev.d.car = mkBulwark (the CARRIER, 2.2x health) and ev.d.crew = four mkCrawler (elite, armoured). The name is shown at the same say/bar/pin sites as the bounty name (66039, 66049/66052, 66071, 67147)
  do: name:'CRAWLER CONVOY', sub:'BULWARK + 4 CRAWLERS' (or keep 'ARMOURED TRAIN'). Crawlers are the most common kind in it, and the sub names the bulwark carrier.
- 72764 [machine] {k:'robots', label:'Machines', hint:'Sentries and crawlers. They own the surface and they are what usually kills you.',
  scope: none (GAMEOPTS settings row; label and hint drawn at 73090-73091). Options set only nSentry, nCrawler and crawlerPerHouse
  do: label:'Sentries and crawlers'. This row changes only those two kinds, and the hint already names them.
- 72750 [pillager bot] {k:'raiders', label:'Pillager bots',
  scope: none (GAMEOPTS settings row, drawn at 73090)
  do: label:'Pillagers'
- 72751 [machine] hint:'Human-shaped rivals looting the same map. They fight each other and the machines as well as you.',
  scope: none (hint of the raiders settings row, drawn at 73091)
  do: hint:'Human-shaped rivals looting the same map. They fight each other and the sentries and crawlers as well as you.'
- 60342 [machine] '2 PLAYER PVP (SAME MACHINE)' / '2 PLAYER CO-OP (SAME MACHINE)' in netModeName
  scope: n/a. Here 'machine' means the computer, not an enemy. It is shown in the party window as 'MODE: ...' (69751) and in netModeMsg (60507)
  do: No change needed for this order, because it does not refer to an enemy. If he wants the word gone everywhere: '(SAME PC)'.
- 71123 [machine] SECTOR_CHAR[0] '...machines account for almost every death here.' and [1] (71124) '...the cold keeps the machines honest.'
  scope: none. SECTOR_CHAR is declared at 71122 and never read; a grep of the whole file finds only the declaration
  do: No change, because this text is never shown. If it is ever wired up: 'crawlers and sentries account for almost every death here' / 'the cold keeps the crawlers honest'.
