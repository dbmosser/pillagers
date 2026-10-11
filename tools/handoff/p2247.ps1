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

# THE ALERT LANE IN THE SHOOTER VOICE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ALERTK={crit:1,warn:1,ext:1};
'@ @'
// v22.xx, the raid text rewrite (fix after batch 3, tr3fixc): THE ALERT LANE IN THE SHOOTER VOICE. HIS ORDER (2026-10-09): a line
// the player reads in a raid is a short caps headline and, only when needed, a short detail, never an explaining sentence. The
// review of batch 3 found details that still explained (the pillager who does not like it, the siege that is coming to this ring,
// how to call again, who called and where in a sentence, why you now run the raid) and three narrated headlines. They now read as
// callouts: SIEGE INCOMING with About N machines inbound, a closing ring with the time left as m:ss, EXTRACTION MISSED, the call
// with only its inbound figure, a teammate call as NAME then EXTRACT and the letter, HOST DISCONNECTED or HOST IS OUT with You
// are hosting now, PILLAGER REINFORCEMENTS, SPOTTED BY SOMETHING HUGE, and the in-ring hints in two to four words. The inbound hint
// keeps its seconds (his v12.93 audit rule: it says how long the ride is). No state, sound or timing changes.
var ALERTK={crit:1,warn:1,ext:1};
'@

SubRx @'
          if(!G.sim) say('PILLAGER TURNED HOSTILE','warn',{sub:e.name+' does not like that.'});   // v22.32, the raid text rewrite (R09): a threat is an alert headline in the shooter voice (his order of 2026-10-09)
'@ @'
          if(!G.sim) say('PILLAGER TURNED HOSTILE','warn',{sub:e.name});   // v22.32, the raid text rewrite (R09): a threat is an alert headline in the shooter voice (his order of 2026-10-09)   // v22.xx (tr3fixc): the shooter voice
'@

SubRx @'
      say('THE SIEGE','warn',{key:'siege',sub:'About '+_sc+(_sc===1?' machine is':' machines are')+' coming to this ring.'});
'@ @'
      say('SIEGE INCOMING','warn',{key:'siege',sub:'About '+_sc+(_sc===1?' machine':' machines')+' inbound'});   // v22.xx (tr3fixc): the shooter voice
'@

SubRx @'
      sayWhenFree('EXTRACTION '+extLetter(cz)+' CLOSING','ext',{c:'warn',sub:'It closes in two minutes.'});   // v22.38 (R13)   // v21.92: an extraction line, ranked over ordinary rows so the queue never drops it;   // v14.11, HUD audit: waits its turn instead of writing over a line
'@ @'
      sayWhenFree('EXTRACTION '+extLetter(cz)+' CLOSING','ext',{c:'warn',sub:'Closes in '+fmtClock(Math.round(G.timeLeft-cz.closeAt))});   // v22.38 (R13)   // v21.92: an extraction line, ranked over ordinary rows so the queue never drops it;   // v14.11, HUD audit: waits its turn instead of writing over a line   // v22.xx (tr3fixc): the shooter voice, the time it really has left
'@

SubRx @'
        say('EXTRACTION LEFT WITHOUT YOU','ext',{c:'warn',key:'xcall',sub:((z.closeAt!==undefined&&G.timeLeft<=z.closeAt)?'':((raidClockOn()&&G.timeLeft<CFG.extractWait)?'Another call cannot beat the raid clock.':('Hold ['+keyLabel('KeyE','E')+'] in a ring to call for extraction.')))}); }   // v22.38 (R13)
'@ @'
        say('EXTRACTION MISSED','ext',{c:'warn',key:'xcall',sub:((z.closeAt!==undefined&&G.timeLeft<=z.closeAt)?'':((raidClockOn()&&G.timeLeft<CFG.extractWait)?'No time to call again':('Hold ['+keyLabel('KeyE','E')+'] to call again')))}); }   // v22.38 (R13)   // v22.xx (tr3fixc): the shooter voice
'@

SubRx @'
      say('EXTRACTION CALLED','ext',{key:'xcall',sub:'Inbound '+_xs+((raidClockOn()&&G.timeLeft<CFG.extractWait)?'. The raid clock runs out first.':('. Then hold '+_xk+' to extract.'))});   // v12.24: not with the clock OFF
'@ @'
      say('EXTRACTION CALLED','ext',{key:'xcall',sub:'Inbound '+_xs+((raidClockOn()&&G.timeLeft<CFG.extractWait)?' \u00b7 Clock runs out first':'')});   // v12.24: not with the clock OFF   // v22.xx (tr3fixc): the shooter voice
'@

SubRx @'
  blip('beacon'); say('EXTRACTION CALLED','ext',{key:'xcall',sub:(netSeatName(peer.seat)||'Your teammate')+' called for extraction at '+extLetter(Z)+'.'});   // v22.38 (R13)
'@ @'
  blip('beacon'); say('EXTRACTION CALLED','ext',{key:'xcall',sub:String(netSeatName(peer.seat)||'Teammate').toUpperCase()+' \u00b7 EXTRACT '+extLetter(Z)});   // v22.38 (R13)   // v22.xx (tr3fixc): the shooter voice
'@

SubRx @'
  try{ say('YOU ARE RUNNING THE RAID','crit',{sub:(why==='out')?'Your host is out.':'The connection to your host was lost.',icon:'party'}); }catch(_hs){}   // v22.35 (R11): an alert at once
'@ @'
  try{ say((why==='out')?'HOST IS OUT':'HOST DISCONNECTED','crit',{sub:'You are hosting now',icon:'party'}); }catch(_hs){}   // v22.35 (R11): an alert at once   // v22.xx (tr3fixc): the shooter voice
'@

SubRx @'
                   :('Extraction inbound in '+Math.ceil(ac.beaconT)+'s. Stay in the ring.');
'@ @'
                   :('Inbound '+Math.ceil(ac.beaconT)+'s \u00b7 Stay in the ring');   // v22.xx (tr3fixc): the shooter voice
'@

SubRx @'
  if(!no) return 'Every extraction is closed.';
'@ @'
  if(!no) return 'All extractions closed';   // v22.xx (tr3fixc): the shooter voice
'@

SubRx @'
  if(no.d<no.z.r) return 'Hold '+_K+' here to call for extraction.';
'@ @'
  if(no.d<no.z.r) return 'Hold '+_K+' to call extraction';   // v22.xx (tr3fixc): the shooter voice
'@

SubRx @'
  if(!G.sim) say('MORE PILLAGERS HAVE COME UP','warn');
'@ @'
  if(!G.sim) say('PILLAGER REINFORCEMENTS','warn');   // v22.xx (tr3fixc): the shooter voice
'@

SubRx @'
        if(!e.announced){ e.announced=true; if(p&&p.net){ if(NET.on) netMarkSend({t:'mark',k:'big',nid:e.nid|0,seat:p.seat|0}); } else say('SOMETHING HUGE HAS NOTICED YOU','warn'); sfx('alarm',e.x,e.y); } }   // v20.38 (H11): said to the player it noticed
'@ @'
        if(!e.announced){ e.announced=true; if(p&&p.net){ if(NET.on) netMarkSend({t:'mark',k:'big',nid:e.nid|0,seat:p.seat|0}); } else say('SPOTTED BY SOMETHING HUGE','warn'); sfx('alarm',e.x,e.y); } }   // v20.38 (H11): said to the player it noticed   // v22.xx (tr3fixc): the shooter voice
'@

SubRx @'
  if(k==='big'){ if(mine&&!G.sim) say('SOMETHING HUGE HAS NOTICED YOU','warn'); return 'mark:big'; }
'@ @'
  if(k==='big'){ if(mine&&!G.sim) say('SPOTTED BY SOMETHING HUGE','warn'); return 'mark:big'; }   // v22.xx (tr3fixc): the shooter voice
'@

SubRx @'
  if(blocked&&rngT<(tk==='frag'?(CFG.fragR===undefined?190:CFG.fragR):110)){ if(tk==='frag') say('GRENADE HIT COVER','warn',{sub:'Get clear of the blast.'}); else say('THROW BLOCKED','info'); }   // v12.20: the warning covers the whole blast
'@ @'
  if(blocked&&rngT<(tk==='frag'?(CFG.fragR===undefined?190:CFG.fragR):110)){ if(tk==='frag') say('GRENADE HIT COVER','warn',{sub:'Get clear'}); else say('THROW BLOCKED','info'); }   // v12.20: the warning covers the whole blast   // v22.xx (tr3fixc): the shooter voice
'@

SubRx @'
var VER='22.46';
'@ @'
var VER='22.47';
'@

$pat = "(?m)^  now:'v22\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.47: Raid alerts read as short callouts: SIEGE INCOMING, EXTRACTION MISSED, HOST DISCONNECTED, PILLAGER REINFORCEMENTS and short details instead of sentences. Check 22.47 fails on v22.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
