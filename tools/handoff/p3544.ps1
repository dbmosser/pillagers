$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# FEWER RAID MESSAGES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function say(m,kind,o){
'@ @'
// v35.xx (cw-msgroute), HIS COMPLAINT (2026-10-27): "there are too many messages coming in to the player", and on the plan: "You need to figure out what works".
// Built to the research rule of that night (reports/Player alerts and HUD messaging.md). The quiet hud put each line in one place; this cuts how many there are.
// A LINE REACHES THE SCREEN ONLY ON THE LADDER: P0 (a) danger to you now or your teammate down, the alert lane; P1 (b) a change in extraction; P2 (c) other
// teammate news; P3 (d) a goal or contract done (not progress); P4 (e) the one-line answer to something you tried that did not work (health full, bandages stop
// at 85, no x left: a key that silently does nothing reads as broken). Everything else (a codex entry, location revealed, weather and fog, running slowly, a
// golden enemy, a stronghold, a discovery, lore, chatter, system lines, progress counts such as notoriety) is said into the run log (G.msgLog) and drawn
// nowhere; the pause box lists the last lines of that log (pauseLogSync), so nothing is lost. msgReach() reads the kind and the words and gives the letter,
// or '' for a log-only line; o.reach names it outright (0: the log only). The medal copy and the world label copies (cw-feedall, his order 2026-10-15) leave the
// left feed (MSGLEAN): a medal shows over the cursor ring and a label where it rose. Kill lines and their figure stay (his answer g-86), "contract item nearby"
// stays as it was, and looting is not touched: the pickup stack, its rows and sounds never pass through here. The hub floor keeps every line.
// The list, call site by call site: tools/handoff/console/notes/raid-messages.md.
var MSGLEAN=1, FEEDGAP=2.5, FEEDWAIT=4, FEEDCALM=4, FEEDRANK={b:1,c:2,d:3};
var MSGCUTA=/^(NOTORIETY |CONVOY MOVING$|MACHINE CONVOY$|COOLANT RUPTURE$|GATE BREACHED$|YOUR RIVAL IS UP TOP$)/;
var MSGOBJ=/^(CONTRACT DONE|GOAL DONE.*|GUN UPGRADED|CACHE MARKED|KEYCARD DROPPED|.+ IS DEAD|.+ DESTROYED|\d+ MINUTES? LEFT)$/;
var MSGKEEP=[
  ['e',/^(HEALTH FULL|ALREADY (HEALING|APPLYING|SLOTTING)|NOT WHILE DOWN|NO .+|NOTHING TO (USE|PICK UP)|.+ STOPS? AT \d+|TOO TIRED TO ROLL|THROW BLOCKED|THROW THE ONE IN YOUR HAND FIRST|MOVE IT TO THE BACKPACK FIRST|ISSUED GEAR STAYS IN YOUR HANDS|CANNOT .+|NOT IN BACKPACK|SLOT .+ TAKES GUNS ONLY|GUNS GO ON KEYS .+|ITEMS GO ON THE WHEEL|GUN SLOT \d+ EMPTY|EMPTY SLOT|STOP FIRST|ARMOUR FULL|NEED .+|HE NEEDS .+|NOT ENOUGH .+|HE WANTS NOTHING YOU CARRY|SELF-REVIVE SPENT.*|AIR STRIKE \d+%|WARDEN ARMOUR|BULWARK SHIELD|MAX TIER|CONTROLLER DISCONNECTED|WALL GLITCH SAVED TO RUN REPORT|ERROR SAVED TO YOUR RUN REPORT|FEEDBACK (SAVED|COPIED|NOT SAVED)|SUPERHOT (ON|OFF|FOLLOWS THE HOST)|PICK OTHER INITIALS|SELECT A HEAL|.+ (JAMMED|EMPTY|ARMOUR FULL|DOES NOT NEED IT|ALREADY HEALING|COULD NOT TAKE IT|MOVED AWAY|IS SEARCHING|TO BACKPACK))$/],
  ['a',/^(MACHINE ALERT|OVERSEER RETURNS)$/],
  ['b',/^(EXTRACTION \S+ IS CLOSED|PILLAGER BOT CALLED EXTRACTION)$/],
  ['c',/^(.+ RECEIVED|GAVE .+ TO .+|TOOK .+ FROM .+|PLATE FROM .+|.+ PATCHED YOU UP|TAKING IT)$/],
  ['d',/^(SOLD \d+ ITEMS?|SURVIVOR EXTRACTED)$/]
];
var MSGKEYS={loanstash:'e',selheal:'e',arcxout:'c',cdone:'d'};
function msgReach(m,k,o){
  var s, key=(o&&o.key)?String(o.key):'', i;
  if(o&&o.reach!==undefined) return o.reach||'';
  if(G&&G.hubFloor) return 'e';   // the hub floor is not a raid: every line, at once, as before
  if(k==='pick') return 'd';
  s=String(m).toUpperCase().replace(/[.\s]+$/,'');
  if(s==='CONTRACT ITEM NEARBY') return 'e';   // close to looting: shown as it always was, at once (his call, 10-27)
  if(MSGKEYS.hasOwnProperty(key)) return MSGKEYS[key];
  if(k==='crit'||k==='warn') return MSGCUTA.test(s)?'':'a';
  if(k==='ext') return (/^(EXTRACT|KNOCKED DOWN)/).test(s)?'b':'d';
  if(k==='ally') return (/^THE PEDDLER /).test(s)?'':'c';
  if(k==='obj') return MSGOBJ.test(s)?((/MINUTES? LEFT$/).test(s)?'b':'d'):'';
  if(G&&G.paused&&(k==='sys'||k==='info')) return 'e';   // a menu answer under the co-op overlay pause (under the solo pause say() hands it to the answer line first)
  for(i=0;i<MSGKEEP.length;i++) if(MSGKEEP[i][1].test(s)) return MSGKEEP[i][0];
  return '';
}
function feedCalm(){ var p=G&&G.player; return !p||!((p.combatT||0)<FEEDCALM); }   // no shot fired or taken for 4 s (tickRegen's clock)
function feedStill(o){ if(!o||typeof o.still!=='function') return true; try{ return !!o.still(); }catch(_fst){ return true; } }   // a waiting line that knows how is asked again before it shows
function feedMateCol(){ try{ if(typeof NET==='object'&&NET&&NET.on&&NET.mode!=='pvp') return mapSeatColor(brlMe()===0?1:0); }catch(_fmc){} return ''; }   // the teammate's colour (his r3-13: P1 amber, P2 cyan)
function say(m,kind,o){
'@

SubRx @'
    if(msgAlertK(k)){ alertSay(m,k,o); return; }
'@ @'
    if(o&&o.reach===0) return;   // v35.xx (cw-msgroute): a line for the run log only (the codex, the story card), never on the pause answer line either
    if(msgAlertK(k)){ if(msgReach(m,k,o)) alertSay(m,k,o); return; }
'@

SubRx @'
    try{ feedSay(m,k,o); }catch(_fsy){}
'@ @'
    // v35.xx (cw-msgroute): a line off the ladder is in the run log and nowhere else; danger and an answer go into the feed at once, the rest take their turn
    // there (feedAdd: one new line every 2.5 s, goal done after the fight)
    var _rc=msgReach(m,k,o); if(!_rc) return;
    try{ feedSay(m,k,o,(_rc==='a'||_rc==='e')?'':_rc); }catch(_fsy){}
'@

SubRx @'
function feedSay(m,k,o){
'@ @'
function feedSay(m,k,o,cap){
'@

SubRx @'
  segs=[{t:s,c:(fk==='info'||fk==='dim')?feedCol(fk):col}];
'@ @'
  segs=[{t:s,c:(fk==='info'||fk==='dim')?feedCol(fk):col}];
  var _mc=(cap==='c')?feedMateCol():''; if(_mc){ col=_mc; segs[0].c=_mc; }   // v35.xx (cw-msgroute): teammate news in the teammate's colour in a party raid
'@

SubRx @'
  return feedAdd(segs,fk,{key:(o&&o.key)?('k:'+o.key):'',col:col});
'@ @'
  return feedAdd(segs,fk,{key:(o&&o.key)?('k:'+o.key):'',col:col,cap:cap||'',still:(o&&o.still)||null});
'@

SubRx @'
var FEED={show:10,keep:40,hold:6,dim:0.6,fade:1,again:1,merge:30,enter:0.14};
'@ @'
// v35.xx (cw-msgroute), the research rule (2026-10-27): THREE LINES, FIVE SECONDS, THEN GONE. The feed showed 10 lines, each bright for 6 s and then held at 60
// percent until ten newer ones pushed it off, so the corner was never empty. Now at most 3 lines, each fading in over 0.2 s, bright to 4.6 s and fully out at 5 s.
// A repeat still joins its line as x2 and starts its time again (FEED.merge).
var FEED={show:3,keep:40,hold:4.6,dim:0,fade:0.4,again:1,merge:30,enter:0.2};
'@

SubRx @'
    for(i=F.lines.length-1,n=0;i>=0&&n<FEED.show;i--,n++){
'@ @'
    for(i=F.lines.length-1,n=0;i>=0&&n<FEED.show;i--){
'@

SubRx @'
      ln=F.lines[i]; al=feedAlpha(ln); e=Math.min(1,(F.t-ln.born)/FEED.enter);
'@ @'
      ln=F.lines[i]; al=feedAlpha(ln); if(!(al>0)) continue; n++;   // v35.xx (cw-msgroute): a line that has faded out holds no place
      e=Math.min(1,(F.t-ln.born)/FEED.enter);
'@

SubRx @'
  ln={id:(F.seq=(F.seq|0)+1),fk:fk||'info',segs:segs,txt:txt
'@ @'
  // v35.xx (cw-msgroute): AT MOST ONE NEW FEED LINE EVERY 2.5 S, counted after repeats join their line. A line that would be new and is not danger or an answer
  // (o.cap: b extraction, c teammate, d goal done) waits in F.q while the last new line is under 2.5 s old, while others wait, or (a goal done) while a shot was
  // fired or taken in the last 4 s. feedTick lets the best ranked one in; a line said again while it waits keeps its one place.
  if(o&&o.cap&&(now-(F.lastNew===undefined?-1e9:F.lastNew)<FEEDGAP||(F.q&&F.q.length)||(o.cap==='d'&&!feedCalm()))){
    F.q=F.q||[];
    for(i=0;i<F.q.length;i++) if((key&&F.q[i].key===key)||(!key&&!F.q[i].key&&F.q[i].txt===txt)){ F.q[i].segs=segs; F.q[i].txt=txt; F.q[i].o=o; return null; }
    F.q.push({segs:segs,fk:fk,o:o,key:key,txt:txt,at:now});
    return null;
  }
  F.lastNew=now;
  ln={id:(F.seq=(F.seq|0)+1),fk:fk||'info',segs:segs,txt:txt
'@

SubRx @'
function feedTick(dt){ if(G&&G.fd) G.fd.t+=dt; }
'@ @'
function feedTick(dt){
  var F=G&&G.fd, i, e, b=-1, o2, k, n=1, calm;
  if(!F) return;
  F.t+=dt;
  if(!F.q||!F.q.length) return;   // v35.xx (cw-msgroute): the lines waiting their turn (feedAdd)
  // extraction and teammate news wait at most 4 s and are asked again (o.still); a goal done waits out the fight
  for(i=F.q.length-1;i>=0;i--){ e=F.q[i]; if((e.o.cap!=='d'&&F.t-e.at>FEEDWAIT)||!feedStill(e.o)) F.q.splice(i,1); }
  if(!F.q.length||F.t-(F.lastNew===undefined?-1e9:F.lastNew)<FEEDGAP) return;
  calm=feedCalm();
  for(i=0;i<F.q.length;i++){ e=F.q[i]; if(e.o.cap==='d'&&!calm) continue; if(b<0||(FEEDRANK[e.o.cap]||9)<(FEEDRANK[F.q[b].o.cap]||9)) b=i; }
  if(b<0) return;
  e=F.q.splice(b,1)[0]; o2={}; for(k in e.o) o2[k]=e.o[k]; o2.cap='';
  if(e.o.cap==='d'){   // every goal done that waited out the fight shows as this one line
    for(i=0;i<F.q.length;){ if(F.q[i].o.cap!=='d'){ i++; continue; } if(F.q[i].txt===e.txt) n++; else e.segs=e.segs.concat([{t:'  \u00b7  ',c:HUDC.dim}],F.q[i].segs); F.q.splice(i,1); }
    if(n>1) o2.n=n;
  }
  feedAdd(e.segs,e.fk,o2);
}
'@

SubRx @'
fk:feedKindOf(e.m,e.k,null)}); }
'@ @'
fk:feedKindOf(e.m,e.k,null),reach:msgReach(e.m,e.k,o)}); }
'@

SubRx @'
  return feedAdd([{t:s,c:c||HUDC.text}],'info',{col:c||null,gl:'info'});
'@ @'
  if(MSGLEAN) return null;   // v35.xx (cw-msgroute): a label is read where it rose (a kill's figure above still rides on its kill line)
  return feedAdd([{t:s,c:c||HUDC.text}],'info',{col:c||null,gl:'info'});
'@

SubRx @'
function feedMedal(txt,pts){
'@ @'
function feedMedal(txt,pts){
  if(MSGLEAN) return null;   // v35.xx (cw-msgroute): the medal shows over the cursor ring; no second copy in the feed
'@

SubRx @'
try{ if(L.name) feedAdd([{t:L.name,c:HUDC.warn}],'obj',{key:'lore:'+L.name}); if(L.text) feedAdd([{t:L.text,c:HUDC.text}],'info',{key:'loret:'+L.name,gl:''}); }catch(_lf){}
'@ @'
try{ if(L.name) say(L.name,'info',{reach:0}); }catch(_lf){}   // v35.xx (cw-msgroute): the story card is its one place; the run log keeps its name (22.88: no line holds the story)
'@

SubRx @'
feedSay('CODEX ENTRY','info',{sub:
'@ @'
/* v35.xx (cw-msgroute): the run log only */ say('CODEX ENTRY','info',{reach:0,sub:
'@

SubRx @'
say(String(downRdr.name).toUpperCase()+' IS BACK UP','ally',{sub:'He will remember that.'});
'@ @'
say(String(downRdr.name).toUpperCase()+' IS BACK UP','ally',{sub:'He will remember that.',reach:0});   // v35.xx (cw-msgroute): a spared bot is not your teammate
'@

SubRx @'
} else say('HE IS BACK UP','ally');
'@ @'
} else say('HE IS BACK UP','ally',{reach:0});
'@

SubRx @'
function tickExtractPoints(dt){
'@ @'
// v35.xx (cw-msgroute), HIS ORDER (2026-10-27 ~22:35): "the game is telling me about extraction b when it is happening far across the map from me". The closing and
// closed lines came for every exit on the map. A line about one exit now shows only for the exit you are heading to (G.active, or one called: its beacon runs)
// or one within 60 m; any other goes to the run log only, and the map shows its state.
var EXTNEAR=60;
function extMine(z){ var p=G&&G.player; if(!z||!G) return false; if(z===G.active||(z.beaconT!==null&&z.beaconT!==undefined)) return true; return !!p&&dist(p,z)<=EXTNEAR*U_PER_M; }
function tickExtractPoints(dt){
'@

SubRx @'
sayWhenFree('EXTRACTION '+extLetter(cz)+' CLOSING','ext',{c:'warn',sub:'Closes in '+fmtClock(Math.round(G.timeLeft-cz.closeAt))});
'@ @'
sayWhenFree('EXTRACTION '+extLetter(cz)+' CLOSING','ext',{c:'warn',sub:'Closes in '+fmtClock(Math.round(G.timeLeft-cz.closeAt)),reach:extMine(cz)?undefined:0});   // v35.xx (cw-msgroute): only your exit or a near one
'@

SubRx @'
sayWhenFree('EXTRACTION '+extLetter(cz)+' CLOSED','ext',{c:'warn'});
'@ @'
sayWhenFree('EXTRACTION '+extLetter(cz)+' CLOSED','ext',{c:'warn',reach:extMine(cz)?undefined:0});   // v35.xx (cw-msgroute): only your exit or a near one
'@

SubRx @'
  <div style="font-size:13.5px;color:var(--ash);margin-top:6px">Please provide feedback anything that went or felt wrong.</div>
'@ @'
  <!-- v35.xx (cw-msgroute): the last lines of the run log, so a line that no longer shows in the raid is not lost (pauseLogSync) -->
  <div id="pauselog" style="display:none;font-size:13px;color:var(--ash);margin-top:8px;max-width:620px;line-height:1.6;text-align:left;text-transform:lowercase;opacity:.85"></div>
  <div style="font-size:13.5px;color:var(--ash);margin-top:6px">Please provide feedback anything that went or felt wrong.</div>
'@

SubRx @'
function togglePauseBox(on){
'@ @'
// v35.xx (cw-msgroute): THE RUN LOG ON THE PAUSE BOX. Most raid lines now go only into the run log (msgReach), so the pause box lists its last 8 lines, oldest
// first, with a detail after a middle dot. It is the log the run report already keeps (G.msgLog, 16 lines), not a new screen; pickup rows are left out.
var PAUSELOGN=8;
function pauseLogSync(on){
  var el=document.getElementById('pauselog'), M=(G&&G.msgLog)||[], L=[], i, e, s, d;
  if(!el) return;
  if(!(on&&G&&!G.over)){ el.style.display='none'; return; }
  for(i=M.length-1;i>=0&&L.length<PAUSELOGN;i--){ e=M[i]; if(!e||e.k==='pick'||!e.m) continue; s=String(e.m)+(e.sub?'  \u00b7  '+String(e.sub):''); L.unshift(s.length>90?s.slice(0,88)+'...':s); }
  el.textContent='';
  if(L.length){ d=document.createElement('div'); d.textContent='run log'; d.style.color='var(--steel-hi)'; el.appendChild(d); }
  for(i=0;i<L.length;i++){ d=document.createElement('div'); d.textContent=L[i].toLowerCase(); el.appendChild(d); }
  el.style.display=L.length?'':'none';
}
function togglePauseBox(on){
'@

SubRx @'
  document.getElementById('pausebox').classList.toggle('on',on);
'@ @'
  document.getElementById('pausebox').classList.toggle('on',on);
  try{ pauseLogSync(on); }catch(_pls){}   // v35.xx (cw-msgroute): the run log's last lines
'@

SubRx @'
var VER='35.43';
'@ @'
var VER='35.44';
'@

$pat = "(?m)^  now:'v35\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.44: fewer raid messages: only danger, extraction, your teammate, goals done and failed tries show; the rest is in the run log on the pause box (43.3 to 30 lines a minute) Check 35.44 fails on v35.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
