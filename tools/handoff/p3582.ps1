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

# PILLAGERS, AND EVERY MACHINE BY NAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var UNITPLURAL={sentry:'sentries',crawler:'crawlers',raider:'pillager bots',snitch:'criers',listener:'listeners'};
'@ @'
// v35.xx (cw-pillagersword), HIS ORDERS (2026-10-28, the HUD Improver chat): "pillagers should always be referred to as 'pillagers' never 'pillager bots'". Reverses the 10-18 word: a player and an AI one are both pillagers. Every machine kind has its plural too.
var UNITPLURAL={sentry:'sentries',crawler:'crawlers',raider:'pillagers',snitch:'criers',listener:'listeners',choir:'pillboxes',warden:'wardens',bulwark:'bulwarks',howler:'howlers'};
'@

SubRx @'
var UNITNAME={sentry:'sentry',crawler:'crawler',raider:'pillager bot',snitch:'crier',listener:'listener'};
'@ @'
var UNITNAME={sentry:'sentry',crawler:'crawler',raider:'pillager',snitch:'crier',listener:'listener'};   // v35.xx (cw-pillagersword): pillager, never pillager bot
'@

SubRx @'
var KINDWORD={sentry:'SENTRY',crawler:'CRAWLER',raider:'PILLAGER BOT',snitch:'CRIER',
'@ @'
var KINDWORD={sentry:'SENTRY',crawler:'CRAWLER',raider:'PILLAGER',snitch:'CRIER',
'@

SubRx @'
function kindWord(k){ return KINDWORD[k]||String(k||'').toUpperCase(); }
'@ @'
function kindWord(k){ return KINDWORD[k]||String(k||'').toUpperCase(); }
// v35.xx (cw-pillagersword), HIS ORDERS (2026-10-28, the HUD Improver chat): "this should never say 'machine' without telling me which machine....eg overseer? etc" and "this applies across the game -- there are 'machine alerts' on the left hand side -- need to tell player which type of machine". The word for one machine as the player knows it: the Overseer by
// name (he is a warden with the boss mark), every other kind by its KINDWORD. machNear finds the machine nearest a spot (within r), for the lines that only know a place.
function machWord(e){ return (e&&e.boss)?'OVERSEER':kindWord(e&&e.kind); }
function machNear(x,y,r){ var i, e, d, best=null, bd=(r>0?r:300); if(!G||!G.ents||!isFinite(x)||!isFinite(y)) return null; for(i=0;i<G.ents.length;i++){ e=G.ents[i]; if(!e||!(e.hp>0)||!ELEM_MACH[e.kind]) continue; d=Math.hypot(e.x-x,e.y-y); if(d<=bd){ bd=d; best=e; } } return best; }
'@

SubRx @'
desc:'Destroy '+n+' '+(n>1?UNITPLURAL[tgt]:(UNITNAME[tgt]||tgt))};
'@ @'
desc:(tgt==='raider'?'Eliminate ':'Destroy ')+n+' '+(n>1?UNITPLURAL[tgt]:(UNITNAME[tgt]||tgt))};   // v35.xx (cw-pillagersword): a pillager is eliminated, as killWord says
'@

SubRx @'
    if(t==='kill') return 'destroy '+((n>1)?(UNITPLURAL[c.tgt]||c.tgt):(UNITNAME[c.tgt]||c.tgt));
'@ @'
    if(t==='kill') return (c.tgt==='raider'?'eliminate ':'destroy ')+((n>1)?(UNITPLURAL[c.tgt]||c.tgt):(UNITNAME[c.tgt]||c.tgt));
'@

SubRx @'
if(P.contracts) for(var _cm=0;_cm<P.contracts.length;_cm++){
  var _CC=P.contracts[_cm];

'@ @'
if(P.contracts) for(var _cm=0;_cm<P.contracts.length;_cm++){
  var _CC=P.contracts[_cm];
  if(_CC&&typeof _CC.desc==='string'&&/pillager bot/i.test(_CC.desc)) _CC.desc=_CC.desc.replace(/^Destroy (\d+ pillager)/,'Eliminate $1').replace(/pillager bot/gi,'pillager');   // v35.xx (cw-pillagersword): a contract already on his board says pillager too

'@

SubRx @'
function alarmOk(wx,wy){

'@ @'
function alarmOk(wx,wy){
  var _am;

'@

SubRx @'
  try{ if(G&&G.player&&!G.over) say('MACHINE ALERT','info'); }catch(_as){}
'@ @'
  // v35.xx (cw-pillagersword), HIS ORDERS (2026-10-28, the HUD Improver chat): "this applies across the game -- there are 'machine alerts' on the left hand side -- need to tell player which type of machine". The alarm cue names the machine that raised it (the nearest one
  // to the sound): SENTRY ALERT, LISTENER ALERT, OVERSEER ALERT. The ship landing, the seal and the notoriety stamp raise the cue with no machine there: no line.
  try{ if(G&&G.player&&!G.over&&wx!==undefined&&wx!==null){ _am=machNear(wx,wy,260); if(_am) say(machWord(_am)+' ALERT','info'); } }catch(_as){}
'@

SubRx @'
  ['a',/^(MACHINE ALERT|OVERSEER RETURNS)$/],
'@ @'
  ['a',/^((SENTRY|CRAWLER|CRIER|LISTENER|PILLBOX|WARDEN|BULWARK|HOWLER|OVERSEER) ALERT|OVERSEER RETURNS)$/],   // v35.xx (cw-pillagersword): the alert names its machine
'@

SubRx @'
  if(!MSIREN.said){ MSIREN.said=1; try{ say('LOCKED ON','warn',{key:'msiren',sub:'MACHINE HAS YOU IN SIGHT'}); }catch(_lo){} }
'@ @'
  // v35.xx (cw-pillagersword), HIS ORDERS (2026-10-28, the HUD Improver chat): "this should never say 'machine' without telling me which machine....eg overseer? etc". The nearest machine that has him is named; two or more of one kind count
  // in the plural (2 SENTRIES HAVE YOU IN SIGHT), a mix names the nearest and the rest (SENTRY +1 HAS YOU IN SIGHT).
  if(!MSIREN.said){ MSIREN.said=1; try{ say('LOCKED ON','warn',{key:'msiren',sub:machSightSub(near,n)}); }catch(_lo){} }
'@

SubRx @'
function tickMachSiren(dt,still){
'@ @'
function machSightSub(near,n){   // the loop just marked each machine that has him (sirenOn)
  var w=machWord(near), one=1, i, e, pl;
  if(n>1){ for(i=0;i<G.ents.length;i++){ e=G.ents[i]; if(e&&e!==near&&e.sirenOn===1&&(machWord(e)!==w)){ one=0; break; } } }
  if(n<=1) return w+' HAS YOU IN SIGHT';
  pl=(w==='OVERSEER')?'OVERSEERS':String(UNITPLURAL[near.kind]||(near.kind+'s')).toUpperCase();
  return one?(n+' '+pl+' HAVE YOU IN SIGHT'):(w+' +'+(n-1)+' HAVE YOU IN SIGHT');
}
function tickMachSiren(dt,still){
'@

SubRx @'
EVENTS.convoy={name:'MACHINE CONVOY',sub:'ARMOURED TRAIN',
'@ @'
EVENTS.convoy={name:'CRAWLER CONVOY',sub:'ARMOURED TRAIN',
'@

SubRx @'
var MSGCUTA=/^(NOTORIETY |CONVOY MOVING$|MACHINE CONVOY$|
'@ @'
var MSGCUTA=/^(NOTORIETY |CONVOY MOVING$|CRAWLER CONVOY$|
'@

SubRx @'
SPK_INFO.evConvoyWarn={grp:'events',lab:'MACHINE CONVOY: announce',
'@ @'
SPK_INFO.evConvoyWarn={grp:'events',lab:'CRAWLER CONVOY: announce',
'@

SubRx @'
SPK_INFO.convoyRoll={grp:'events',lab:'MACHINE CONVOY: the train sets off',
'@ @'
SPK_INFO.convoyRoll={grp:'events',lab:'CRAWLER CONVOY: the train sets off',
'@

SubRx @'
        desc:'Hit '+up(2)+' machine weak points, then extract'};
'@ @'
        desc:'Hit '+up(2)+' sentry or warden weak points, then extract'};   // v35.xx (cw-pillagersword): names the kinds, not a machine
'@

SubRx @'
['xfFeud','machines vs pillagers','they fight on sight','w'],
'@ @'
['xfFeud','wardens and bulwarks vs pillagers','they fight on sight','w'],
'@

SubRx @'
['xfEvConvoy','event: machine convoy','an armoured train crosses','w'],
'@ @'
['xfEvConvoy','event: crawler convoy','an armoured train crosses','w'],
'@

SubRx @'
['xfEvBounty','event: bounty pillager bot','a marked boss hunts you','w'],
'@ @'
['xfEvBounty','event: bounty pillager','a marked boss hunts you','w'],
'@

SubRx @'
['xfTell','aim lanes','a machine paints its aim','w'],
'@ @'
['xfTell','aim lanes','sentries and wardens paint their aim','w'],
'@

SubRx @'
.replace(/^pillager roles$/i,'pillager bot roles').replace(/^machines vs pillagers$/i,'machines vs pillager bots'); }
'@ @'
; }   // v35.xx (cw-pillagersword): the rows say pillagers as written
'@

SubRx @'
{k:'raiders', label:'Pillager bots',
'@ @'
{k:'raiders', label:'Pillagers',
'@

SubRx @'
They fight each other and the machines as well as you.',
'@ @'
They fight each other and the sentries and crawlers as well as you.',
'@

SubRx @'
{k:'robots', label:'Machines',
'@ @'
{k:'robots', label:'Sentries and crawlers',
'@

SubRx @'
w2:'SHRED \u00b7 ANTI-MACHINE'}
'@ @'
w2:'SHRED \u00b7 ANTI-ARMOUR'}
'@

SubRx @'
say('PILLAGER BOT REINFORCEMENTS','warn');
'@ @'
say('PILLAGER REINFORCEMENTS','warn');
'@

SubRx @'
(e.name||'PILLAGER BOT')+' DOWNED'
'@ @'
(e.name||'PILLAGER')+' DOWNED'
'@

SubRx @'
say('PILLAGER BOT TURNED HOSTILE','warn',{sub:e.name});
'@ @'
say('PILLAGER TURNED HOSTILE','warn',{sub:e.name});
'@

SubRx @'
say('PILLAGER BOT CALLED EXTRACTION','info',
'@ @'
say('PILLAGER CALLED EXTRACTION','info',
'@

SubRx @'
  ['b',/^(EXTRACTION \S+ IS CLOSED|PILLAGER BOT CALLED EXTRACTION)$/],
'@ @'
  ['b',/^(EXTRACTION \S+ IS CLOSED|PILLAGER CALLED EXTRACTION)$/],
'@

SubRx @'
(f.by.name||'A PILLAGER BOT')+"'S CHARGE"
'@ @'
(f.by.name||'A PILLAGER')+"'S CHARGE"
'@

SubRx @'
String(G.nearDown.name||'PILLAGER BOT').toUpperCase()
'@ @'
String(G.nearDown.name||'PILLAGER').toUpperCase()
'@

SubRx @'
rsText('CURRENT PILLAGER BOTS  '+RSTAT.live,
'@ @'
rsText('CURRENT PILLAGERS  '+RSTAT.live,
'@

SubRx @'
[n(3),'search in a ring; hold to finish a pillager bot']
'@ @'
[n(3),'search in a ring; hold to finish a pillager']
'@

SubRx @'
['Y','search in a ring; hold to finish a pillager bot']
'@ @'
['Y','search in a ring; hold to finish a pillager']
'@

SubRx @'
pill3:{t:'3 PILLAGER BOTS',
'@ @'
pill3:{t:'3 PILLAGERS',
'@

SubRx @'
EVENTS.bounty={name:'BOUNTY PILLAGER BOT',
'@ @'
EVENTS.bounty={name:'BOUNTY PILLAGER',
'@

SubRx @'
flowChip(BOUNTY.pay,'BOUNTY CLAIMED','BOUNTY PILLAGER BOT');
'@ @'
flowChip(BOUNTY.pay,'BOUNTY CLAIMED','BOUNTY PILLAGER');
'@

SubRx @'
return 'golden '+(kind==='raider'?'pillager bot':(GOLD.kinds[kind]?kind:'enemy'))+' down'; }
'@ @'
return 'golden '+(kind==='raider'?'pillager':(GOLD.kinds[kind]?kindWord(kind).toLowerCase():'enemy'))+' down'; }   // v35.xx (cw-pillagersword)
'@

SubRx @'
desc:'40% more machines, pillagers and criers.'}
'@ @'
desc:'40% more sentries, crawlers, criers and pillagers.'}
'@

SubRx @'
return 'Word has spread. Hires cost more and pillager bots trust you less.';
'@ @'
return 'Word has spread. Hires cost more and pillagers trust you less.';
'@

SubRx @'
return 'Hires cost more and pillager bots trust you less.';
'@ @'
return 'Hires cost more and pillagers trust you less.';
'@

SubRx @'
or a pillager bot who had not fought you.');
'@ @'
or a pillager who had not fought you.');
'@

SubRx @'
_bits.push('Pillager bots need '+
'@ @'
_bits.push('Pillagers need '+
'@

SubRx @'
Find them in rare containers or on elite pillager bots.'
'@ @'
Find them in rare containers or on elite pillagers.'
'@

SubRx @'
'Half the pillager bots down here walk past scrap. Their loss.',
'@ @'
'Half the pillagers down here walk past scrap. Their loss.',
'@

SubRx @'
<span class="vpill">PILLAGER BOT</span>
'@ @'
<span class="vpill">PILLAGER</span>
'@

SubRx @'
d:'Kill 25 pillager bots in all.'}
'@ @'
d:'Kill 25 pillagers in all.'}
'@

SubRx @'
d:'Kill 100 machines in all.'}
'@ @'
d:'Kill 100 sentries, crawlers and other machines in all.'}
'@

SubRx @'
['nRaider','Pillager bots',0,20,1,0],
'@ @'
['nRaider','Pillagers',0,20,1,0],
'@

SubRx @'
['packMax','Machines that answer a call',0,10,1,0],
'@ @'
['packMax','Sentries, crawlers, criers that answer a call',0,10,1,0],
'@

SubRx @'
['raiderExtract','Seconds a pillager bot must hold the ring',
'@ @'
['raiderExtract','Seconds a pillager must hold the ring',
'@

SubRx @'
['raiderFeud','Pillager bot crews feud (0 truce)',
'@ @'
['raiderFeud','Pillager crews feud (0 truce)',
'@

SubRx @'
['raiderFloorN','Min pillager bots alive',
'@ @'
['raiderFloorN','Min pillagers alive',
'@

SubRx @'
'  |  Pillager bots extracted: '+rExt
'@ @'
'  |  Pillagers extracted: '+rExt
'@

SubRx @'
[SNDCOL.robot.move, 'machine moving'],
'@ @'
[SNDCOL.robot.move, 'sentry or crawler moving'],
'@

SubRx @'
[SNDCOL.robot.fire, 'machine firing'],
'@ @'
[SNDCOL.robot.fire, 'sentry or pillbox firing'],
'@

SubRx @'
[SNDCOL.raider.move,'pillager bot moving'],
'@ @'
[SNDCOL.raider.move,'pillager moving'],
'@

SubRx @'
[SNDCOL.raider.fire,'pillager bot firing'],
'@ @'
[SNDCOL.raider.fire,'pillager firing'],
'@

SubRx @'
a pillager bot walking out tries a revive
'@ @'
a pillager walking out tries a revive
'@

SubRx @'
['DONE','Pillager bots play like people:
'@ @'
['DONE','Pillagers play like people:
'@

SubRx @'
['DONE','Plain-language raid settings: pillager bots, machines, damage,
'@ @'
['DONE','Plain-language raid settings: pillagers, sentries, crawlers, damage,
'@

SubRx @'
['DONE','Pillager bots that equip what they loot,
'@ @'
['DONE','Pillagers that equip what they loot,
'@

SubRx @'
for you and for every pillager bot on the board'],
'@ @'
for you and for every pillager on the board'],
'@

SubRx @'
['DONE','Machines that answer a call and take roles:
'@ @'
['DONE','Sentries, crawlers and criers answer a call and take roles:
'@

SubRx @'
['DONE','Machine voices: tell a Sentry
'@ @'
['DONE','Sentry and crawler voices: tell a Sentry
'@

SubRx @'
and pillager bots who hide in them too'],
'@ @'
and pillagers who hide in them too'],
'@

SubRx @'
var VER='35.81';
'@ @'
var VER='35.82';
'@

$pat = "(?m)^  now:'v35\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.82: pillagers, never pillager bots; alerts and locked on name the machine Check 35.82 fails on v35.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
