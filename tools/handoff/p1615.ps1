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

# PLAIN GAME LANGUAGE FOR CO-OP. His note of 2026-09-26 on how the new lines read. Text only.

SubRx @'
  'YOUR PARTY GOES UP TOGETHER AND SHARES ONE SURFACE. The mode menu opens a second window for your other screen with its own controller, and world sound plays from one of the two. In a party only the host takes the lift: the party ascends together and sees each other up top. The pillagers and machines are one set for everyone: they go for whoever is nearest, your hits and kills count in your own tally, and nobody in your party can hurt you. One of you searches a box at a time and the loot goes to whoever searched it. Hold E beside a downed teammate to pull them up. The clock, the weather, the lightning and the extraction points are the same for everyone, and a beacon any of you calls comes for the party. If the host leaves the party, the run ends as abandoned for everyone; if the host extracts or dies, the raid runs on until the rest of you are out. Pause no longer stops the world in co-op. C crouches even with Shift held when you are out of breath, a controller leaves the end of raid card with B, holding ESC or P no longer flickers the pause box, a pillager grenade sounds where it lands, a lightning flash shows you to the enemy from farther off, and only a Medkit takes you past 85.',
'@ @'
  'YOUR PARTY GOES UP TOGETHER AND SHARES ONE SURFACE. The mode menu opens a second window for your other screen with its own controller, and world sound plays from one of the two. In a party only the host takes the lift: the party ascends together and sees each other up top. The pillagers and machines are one set for everyone: they go for whoever is nearest, your hits and kills count in your own tally, and nobody in your party can hurt you. One of you searches a box at a time and the loot goes to whoever searched it. Hold E next to a downed teammate to revive them. The clock, the weather, the lightning and the extraction points are the same for everyone, and a beacon any of you calls comes for the party. If the host leaves the party, the run ends as abandoned for everyone; if the host extracts or dies, the rest of the party keeps playing. Pause no longer stops the world in co-op. C crouches even with Shift held when you are out of breath, a controller leaves the end of raid card with B, holding ESC or P no longer flickers the pause box, a pillager grenade sounds where it lands, a lightning flash shows you to the enemy from farther off, and only a Medkit takes you past 85.',
'@

SubRx @'
   line:'Storm. Lightning strikes, and every flash shows you the map and shows you to them from farther off.'}   // v16.03, his order: the flash shows you to them, farther, not across the whole map
'@ @'
   line:'Storm. Lightning lights up the map, and every flash makes you visible from farther away.'}   // v16.03, his order: the flash shows you to them, farther, not across the whole map
'@

SubRx @'
    if(MW.lightning) wv.push('lightning strikes, and a flash shows you to them from farther');   // v16.03: the flash lifts the fog for you and doubles how far they see you
'@ @'
    if(MW.lightning) wv.push('lightning strikes: flashes reveal you from farther away');   // v16.03: the flash lifts the fog for you and doubles how far they see you
'@

SubRx @'
  if(typeof NET==='object'&&NET&&NET.specG){ netSay('Your party is still up top. The lift waits until they are out.'); return true; }   // v16.14: a spectating host does not go up again
'@ @'
  if(typeof NET==='object'&&NET&&NET.specG){ netSay('Cannot ascend while your party is still in the raid.'); return true; }   // v16.14: a spectating host does not go up again
'@

SubRx @'
  netSay('Your host takes the party up. Stay here and you go up together.');
'@ @'
  netSay('Only the host can start the raid. You ascend with them.');
'@

SubRx @'
  if(NET.role==='join'&&st==='spec'&&s===0){ NET.status='Your host is out. The raid runs on until you are out.'; try{ if(typeof G!=='undefined'&&G&&!G.over) sayWhenFree('Your host is out. The raid runs on until you are out.'); }catch(_sw){} }   // v16.14, his ruling
'@ @'
  if(NET.role==='join'&&st==='spec'&&s===0){ NET.status='Host has left the raid. Extract to finish your run.'; try{ if(typeof G!=='undefined'&&G&&!G.over) sayWhenFree('Host has left the raid. Extract to finish your run.'); }catch(_sw){} }   // v16.14, his ruling
'@

SubRx @'
  blip('beacon'); say((netSeatName(peer.seat)||'Your teammate')+' called the extraction. Inbound '+Math.ceil(Z.beaconT)+'s.');
'@ @'
  blip('beacon'); say((netSeatName(peer.seat)||'Your teammate')+' called extraction. Inbound in '+Math.ceil(Z.beaconT)+'s.');
'@

SubRx @'
  if(!md||typeof md.getUserMedia!=='function') return Promise.resolve({err:'This browser cannot use a microphone here.'});
'@ @'
  if(!md||typeof md.getUserMedia!=='function') return Promise.resolve({err:'Voice chat is not available in this browser.'});
'@

SubRx @'
    if(!NET.micTrack) return {err:'The browser gave no microphone.'};
'@ @'
    if(!NET.micTrack) return {err:'No microphone found.'};
'@

SubRx @'
    NET.status=(NET.micMode==='open')?'Mic on. Everyone linked hears you.':'Mic on. Hold Y to talk.';
'@ @'
    NET.status=(NET.micMode==='open')?'Mic on. Open mic.':'Mic on. Hold Y to talk.';
'@

SubRx @'
  },function(e){ return {err:'The microphone was not allowed ('+netErrText(e)+'). Emotes still work.'}; });
'@ @'
  },function(e){ return {err:'Microphone access was blocked ('+netErrText(e)+').'}; });
'@

SubRx @'
// out, so nobody is ended; a friend hears Your host is out. The raid runs on until you are out. It stops when no friend is up
'@ @'
// out, so nobody is ended; a friend hears Host has left the raid. Extract to finish your run. It stops when no friend is up
'@

SubRx @'
  NET.status='Your party is still up top. The raid runs on until they are out.';
'@ @'
  NET.status='Your party is still in the raid. Waiting for them to finish.';
'@

SubRx @'
  NET.status='Your party is back down. The raid is over.';
'@ @'
  NET.status='Your party is back. Raid over.';
'@

SubRx @'
  if(!G.netRevT) say('Picking up '+nm+'. Keep holding '+keyLabel('KeyE','E')+'.');
'@ @'
  if(!G.netRevT) say('Reviving '+nm+'. Hold '+keyLabel('KeyE','E')+'.');
'@

SubRx @'
  say('You pull '+nm+' up.'); blip('pick');
'@ @'
  say(nm+' revived.'); blip('pick');
'@

SubRx @'
  blip('pick'); say((netSeatName(by)||'Your teammate')+' pulls you up.');
'@ @'
  blip('pick'); say('Revived by '+(netSeatName(by)||'a teammate')+'.');
'@

SubRx @'
  G.netLeft=(why==='out')?'YOUR HOST LEFT THE SURFACE. THE RUN ENDS AS ABANDONED FOR THE WHOLE PARTY.'
'@ @'
  G.netLeft=(why==='out')?'HOST LEFT THE RAID. RUN ABANDONED.'
'@

SubRx @'
                         :'THE LINK TO YOUR HOST WAS LOST. THE RUN ENDS AS ABANDONED FOR THE WHOLE PARTY.';
'@ @'
                         :'CONNECTION TO HOST LOST. RUN ABANDONED.';
'@

SubRx @'
  NET.status=(why==='out')?'Your host left the surface. The run counts as abandoned for the whole party.'
'@ @'
  NET.status=(why==='out')?'Host left the raid. Run abandoned.'
'@

SubRx @'
                          :'The link to your host was lost. The run counts as abandoned for the whole party.';
'@ @'
                          :'Connection to host lost. Run abandoned.';
'@

SubRx @'
    if(g('partyvoicenote')) g('partyvoicenote').textContent=NET.micTrack?((NET.micMode==='open')?'Everyone linked hears you. Wear a headset.':'Hold Y to talk. Wear a headset.'):'Press MIC to talk to your party. The browser asks first.'; }
'@ @'
    if(g('partyvoicenote')) g('partyvoicenote').textContent=NET.micTrack?((NET.micMode==='open')?'Open mic: your party can hear you. Headset recommended.':'Hold Y to talk. Headset recommended.'):'Turn on MIC to use voice chat.'; }
'@

SubRx @'
  if(g('partymicbtn')) g('partymicbtn').onclick=function(){ if(NET.micTrack){ voiceMicOff(); renderParty(); } else netUi(function(){ return voiceMicOn(); },'Asking the browser for the microphone.'); };   // v16.09
'@ @'
  if(g('partymicbtn')) g('partymicbtn').onclick=function(){ if(NET.micTrack){ voiceMicOff(); renderParty(); } else netUi(function(){ return voiceMicOn(); },'Requesting microphone access.'); };   // v16.09
'@

SubRx @'
  label(p.x,p.y-22,'PICKED UP','#4de3d0',0,true);
  return 'up';
'@ @'
  label(p.x,p.y-22,'REVIVED','#4de3d0',0,true);
  return 'up';
'@

SubRx @'
var VER='16.14';
'@ @'
var VER='16.15';
'@

$pat = "(?m)^  now:'v16\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.15: PLAIN GAME LANGUAGE FOR CO-OP. His note: the co-op lines read like a rulebook. Every line added for co-op, the storm and voice now reads the way a game says it: Reviving NAME, Revived by NAME, Host has left the raid, Your party is still in the raid, Only the host can start the raid, Connection to host lost, and the storm, CONDITIONS row and voice lines in the same plain style. Text only. Check 16.15 fails on v16.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
