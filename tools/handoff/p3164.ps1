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

# NO RAIDERS ON SCREEN: THE AI ONES ARE PILLAGER BOTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var UNITPLURAL={sentry:'sentries',crawler:'crawlers',raider:'pillagers'
'@ @'
// v31.xx (cw-vocab-bots), HIS ORDER 2026-10-18: "get rid of the conept of praiders -- there are players, who are pillagers, then there are pillager bots". A player is a pillager; the AI ones are pillager bots; raider never shows. Words only: kind:'raider' and CFG.nRaider are code names and stay.
var UNITPLURAL={sentry:'sentries',crawler:'crawlers',raider:'pillager bots'
'@

SubRx @'
var UNITNAME={sentry:'sentry',crawler:'crawler',raider:'pillager'
'@ @'
var UNITNAME={sentry:'sentry',crawler:'crawler',raider:'pillager bot'
'@

SubRx @'
var KINDWORD={sentry:'SENTRY',crawler:'CRAWLER',raider:'PILLAGER'
'@ @'
var KINDWORD={sentry:'SENTRY',crawler:'CRAWLER',raider:'PILLAGER BOT'
'@

SubRx @'
'Word has spread. Hires cost more and pillagers trust you less.'
'@ @'
'Word has spread. Hires cost more and pillager bots trust you less.'
'@

SubRx @'
return 'Hires cost more and pillagers trust you less.'
'@ @'
return 'Hires cost more and pillager bots trust you less.'
'@

SubRx @'
[n(3),'search in a ring; hold to finish a pillager']
'@ @'
[n(3),'search in a ring; hold to finish a pillager bot']
'@

SubRx @'
['Y','search in a ring; hold to finish a pillager']
'@ @'
['Y','search in a ring; hold to finish a pillager bot']
'@

SubRx @'
(f.by.name||'A PILLAGER')
'@ @'
(f.by.name||'A PILLAGER BOT')
'@

SubRx @'
say('PILLAGER REINFORCEMENTS'
'@ @'
say('PILLAGER BOT REINFORCEMENTS'
'@

SubRx @'
(e.name||'PILLAGER')+' DOWNED'
'@ @'
(e.name||'PILLAGER BOT')+' DOWNED'
'@

SubRx @'
say('PILLAGER TURNED HOSTILE'
'@ @'
say('PILLAGER BOT TURNED HOSTILE'
'@

SubRx @'
say('PILLAGER CALLED EXTRACTION'
'@ @'
say('PILLAGER BOT CALLED EXTRACTION'
'@

SubRx @'
desc:'40% more machines, pillagers and criers.'
'@ @'
desc:'40% more machines, pillager bots and criers.'
'@

SubRx @'
desc:'Every pillager is hostile and already searching for you.'
'@ @'
desc:'Every pillager bot is hostile and already searching for you.'
'@

SubRx @'
|  AI pillagers extracted: '
'@ @'
|  Pillager bots extracted: '
'@

SubRx @'
String(G.nearDown.name||'PILLAGER')
'@ @'
String(G.nearDown.name||'PILLAGER BOT')
'@

SubRx @'
[SNDCOL.raider.move,'pillager moving']
'@ @'
[SNDCOL.raider.move,'pillager bot moving']
'@

SubRx @'
[SNDCOL.raider.fire,'pillager firing']
'@ @'
[SNDCOL.raider.fire,'pillager bot firing']
'@

SubRx @'
ctx.fillText('CURRENT PILLAGERS  '+live
'@ @'
ctx.fillText('CURRENT PILLAGER BOTS  '+live
'@

SubRx @'
rsText('CURRENT PILLAGERS  '+RSTAT.live
'@ @'
rsText('CURRENT PILLAGER BOTS  '+RSTAT.live
'@

SubRx @'
['nRaider','AI pillagers'
'@ @'
['nRaider','Pillager bots'
'@

SubRx @'
['raiderExtract','Seconds a pillager must hold the ring'
'@ @'
['raiderExtract','Seconds a pillager bot must hold the ring'
'@

SubRx @'
['raiderFeud','Pillager crews feud (0 truce)'
'@ @'
['raiderFeud','Pillager bot crews feud (0 truce)'
'@

SubRx @'
['raiderFloorN','Min pillagers alive'
'@ @'
['raiderFloorN','Min pillager bots alive'
'@

SubRx @'
Find them in rare containers or on elite pillagers.'
'@ @'
Find them in rare containers or on elite pillager bots.'
'@

SubRx @'
a pillager walking out tries a revive for a crewmate near his path.
'@ @'
a pillager bot walking out tries a revive for a crewmate near his path.
'@

SubRx @'
['DONE','Pillagers play like people:
'@ @'
['DONE','Pillager bots play like people:
'@

SubRx @'
Plain-language raid settings: pillagers, machines
'@ @'
Plain-language raid settings: pillager bots, machines
'@

SubRx @'
['DONE','Pillagers that equip what they loot
'@ @'
['DONE','Pillager bots that equip what they loot
'@

SubRx @'
for you and for every pillager on the board
'@ @'
for you and for every pillager bot on the board
'@

SubRx @'
Bushes you can hide in, and raiders who hide in them too
'@ @'
Bushes you can hide in, and pillager bots who hide in them too
'@

SubRx @'
next:'His ruling on the pillagers: machines at war with them
'@ @'
next:'His ruling on the pillager bots: machines at war with them
'@

SubRx @'
'Half the pillagers down here walk past scrap. Their loss.'
'@ @'
'Half the pillager bots down here walk past scrap. Their loss.'
'@

SubRx @'
<span class="vpill">PILLAGER</span>
'@ @'
<span class="vpill">PILLAGER BOT</span>
'@

SubRx @'
d:'Kill 25 pillagers in all.'
'@ @'
d:'Kill 25 pillager bots in all.'
'@

SubRx @'
_bits.push('Pillagers need '+(2+clamp
'@ @'
_bits.push('Pillager bots need '+(2+clamp
'@

SubRx @'
an unarmed survivor, or a pillager who had not fought you.
'@ @'
an unarmed survivor, or a pillager bot who had not fought you.
'@

SubRx @'
flowChip(BOUNTY.pay,'BOUNTY CLAIMED','BOUNTY PILLAGER')
'@ @'
flowChip(BOUNTY.pay,'BOUNTY CLAIMED','BOUNTY PILLAGER BOT')
'@

SubRx @'
t:'3 PILLAGERS'
'@ @'
t:'3 PILLAGER BOTS'
'@

SubRx @'
EVENTS.bounty={name:'BOUNTY PILLAGER'
'@ @'
EVENTS.bounty={name:'BOUNTY PILLAGER BOT'
'@

SubRx @'
{k:'raiders', label:'Other pillagers'
'@ @'
{k:'raiders', label:'Pillager bots'
'@

SubRx @'
var VER='31.63';
'@ @'
var VER='31.64';
'@

$pat = "(?m)^  now:'v31\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.64: The AI humans are now called pillager bots everywhere on screen, and raider is gone. Check 31.64 fails on v31.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
