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

# PLAIN GAME LANGUAGE, THE LARGER PASS. His order of 2026-09-26. Text only; TXSHIP keys untouched.

SubRx @'
    if(E.k==='hail') say('Nobody parleys with a raised gun.');
'@ @'
    if(E.k==='hail') say('Lower your weapon to talk.');
'@

SubRx @'
  if(n>=2) return 'Hiring costs more and pillagers are slower to trust you. Word has got round.';
'@ @'
  if(n>=2) return 'Word has spread. Hires cost more and pillagers trust you less.';
'@

SubRx @'
  return 'Hiring costs more and pillagers are slower to trust you.';
'@ @'
  return 'Hires cost more and pillagers trust you less.';
'@

SubRx @'
    say('He tells you where a cache is. It is on your map.'+_tail);
'@ @'
    say('He marks a cache on your map.'+_tail);
'@

SubRx @'
  if(!_pAmmo&&bagWeight()+wt>cap){ say('No room in the backpack for that.'); return; }
'@ @'
  if(!_pAmmo&&bagWeight()+wt>cap){ say('Backpack full.'); return; }
'@

SubRx @'
      var _loanLn='You are carrying a loaner. Your own gun waits in your stash: choose Equip as your gun on it there before your next ascent.';
'@ @'
      var _loanLn='You are carrying a loaner. Equip your own gun from the stash before your next ascent.';
'@

SubRx @'
  say(_unkeyed?'No throwable you carry is on your tactical belt.':'No throwables');
'@ @'
  say(_unkeyed?'No throwable on your tactical belt.':'No throwables');
'@

SubRx @'
      if(!G.sim){ say('No legs left to roll with.'); blip('clank'); }
'@ @'
      if(!G.sim){ say('Too tired to roll.'); blip('clank'); }
'@

SubRx @'
      var _hotLine=G.sim?'':'Hot ground. There is more in here than there should be.';
'@ @'
      var _hotLine=G.sim?'':'Hot ground. Extra loot in here.';
'@

SubRx @'
  if(!g||g.id==='fists'||g.mag===0){ say('Nothing there to put in your backpack.'); return false; }   // v14.78: his word
'@ @'
  if(!g||g.id==='fists'||g.mag===0){ say('Nothing to pick up.'); return false; }   // v14.78: his word
'@

SubRx @'
      say('Knocked down. The hold is lost, start again.');
'@ @'
      say('Knocked down. Extraction hold lost.');
'@

SubRx @'
      var _why=(_g>=0.66)?' They heard THAT: you are carrying too much to be quiet about it.'
'@ @'
      var _why=(_g>=0.66)?' Heavy backpack: they heard that.'
'@

SubRx @'
              :((_g>=0.33)?' That is a heavy backpack to be standing still with.'
'@ @'
              :((_g>=0.33)?' Your backpack is heavy. Expect company.'
'@

SubRx @'
                          :' A light backpack brings the fewest of them.');
'@ @'
                          :' Light backpack. Fewer will come.');
'@

SubRx @'
  if(!G.sim) say('Another wave of pillagers has entered.');
'@ @'
  if(!G.sim) say('More pillagers have entered the area.');
'@

SubRx @'
  G.tel.revives++; blip('pick'); say('Back on your feet. That was your one.');
'@ @'
  G.tel.revives++; blip('pick'); say('Back on your feet. Self-revive used.');
'@

SubRx @'
    if(!p.autoJog&&mg>0){ if(!G.sim) say('Auto-jog arms from a standstill. Stop first, then tap CAPS.'); }
'@ @'
    if(!p.autoJog&&mg>0){ if(!G.sim) say('Stop first, then tap CAPS to auto-jog.'); }
'@

SubRx @'
        say('Wall glitch caught and recorded, the run report has the exact spot.');
'@ @'
        say('Wall glitch logged in your run report.');
'@

SubRx @'
          say('Someone shot the survivor. Not your doing, not your notoriety.');
'@ @'
          say('Someone shot the survivor. Not on you.');
'@

SubRx @'
        if(!G.sim) say(e.name+' destroyed. It has stopped listening, and it dropped a cache.');   // v11.94, HIS NOTE: he could not tell this was a death
'@ @'
        if(!G.sim) say(e.name+' destroyed. It dropped a cache.');   // v11.94, HIS NOTE: he could not tell this was a death
'@

SubRx @'
            if(!G.sim) say('The Peddler sets up a new pitch where he stands.');
'@ @'
            if(!G.sim) say('The Peddler has set up shop here.');
'@

SubRx @'
say(sees?'The Crier raised the alarm. It kept eyes on you: they know exactly where you are.'   // v11.94, HIS NOTE: name the Crier
'@ @'
say(sees?'The Crier raised the alarm. They know exactly where you are.'   // v11.94, HIS NOTE: name the Crier
'@

SubRx @'
                 :'The Crier raised the alarm. They are coming to where it LAST saw you.');
'@ @'
                 :'The Crier raised the alarm. They are heading to where it last saw you.');
'@

SubRx @'
   desc:'Forty percent more of everything out there: machines, pillagers and criers alike.'},
'@ @'
   desc:'40% more machines, pillagers and criers.'},
'@

SubRx @'
     if(full<=0) return 'The raid clock is off, so there is no clock to cut.';
'@ @'
     if(full<=0) return 'No effect: the raid clock is off.';
'@

SubRx @'
   desc:'Every pillager out there is hostile and already looking.'},
'@ @'
   desc:'Every pillager is hostile and already searching for you.'},
'@

SubRx @'
   desc:'One more Listener, and they all hear half again as far.'}
'@ @'
   desc:'One extra Listener. All Listeners hear 50% farther.'}
'@

SubRx @'
    ctx.fillText(p.revived?'You are bleeding out. Crawl to an open extraction point if possible.':
'@ @'
    ctx.fillText(p.revived?'Bleeding out. Crawl to an open extraction point.':
'@

SubRx @'
    ctx.fillText(weaponDown()?'weapon down, they will listen':'lower your weapon first, or it is just noise',
'@ @'
    ctx.fillText(weaponDown()?'weapon down, they will listen':'lower your weapon first',
'@

SubRx @'
         :(autoN?('nothing is packed, so '+autoN+' item'+(autoN===1?' goes':'s go')+' up from your stash, picked for you: grenades first, then plates, ammo and heals. Anything that goes up can be lost.')
'@ @'
         :(autoN?('nothing is packed, so '+autoN+' item'+(autoN===1?' goes':'s go')+' auto-packed from your stash: grenades, plates, ammo and heals. Anything you take up can be lost.')
'@

SubRx @'
  if(!nm){ say('Type what to call them first.'); return; }
'@ @'
  if(!nm){ say('Enter a name first.'); return; }
'@

SubRx @'
  if(P.intel){ say('A core is already slotted. It burns on your next ascent.'); return; }
'@ @'
  if(P.intel){ say('A core is already slotted for your next raid.'); return; }
'@

SubRx @'
  if(ix<0){ say('No Data Core in the stash. They come off rare shelves and elite pillagers.'); return; }
'@ @'
  if(ix<0){ say('No Data Core in your stash. Find them in rare containers or on elite pillagers.'); return; }
'@

SubRx @'
  say('Core slotted. Your next ascent carries intel.'+(_cp?' Used '+_cp+' packed Data Core out of your backpack.':''));
'@ @'
  say('Core slotted. Your next raid starts with intel.'+(_cp?' Used '+_cp+' packed Data Core out of your backpack.':''));
'@

SubRx @'
    ?'Your next raid deploys with intel: every locked-room key and every elite, live on your map. One core, one raid.'
'@ @'
    ?'Next raid: every locked-room key and every elite shown live on your map. One core per raid.'
'@

SubRx @'
  ['DONE','The Mainframe: junk builds racks that pay on extraction, cores buy next-raid intel'],
'@ @'
  ['DONE','The Mainframe: build racks that pay on extraction, or spend cores on intel'],
'@

SubRx @'
      if(P.equipped===_rg||P.equippedSec===_rg){ say2('That one goes up in your hands already.'); return; }
'@ @'
      if(P.equipped===_rg||P.equippedSec===_rg){ say2('That gun is already equipped.'); return; }
'@

SubRx @'
      if(!P.hotAssign||P.hotAssign[_bs]!==key){ say2('That is not on that key any more.'); return; }
'@ @'
      if(!P.hotAssign||P.hotAssign[_bs]!==key){ say2('That item is no longer on that key.'); return; }
'@

SubRx @'
  if(room<=0) return 'Every one of those is already packed.';
'@ @'
  if(room<=0) return 'All of those are already packed.';
'@

SubRx @'
  if(!held) return 'That is not in your stash any more.';
'@ @'
  if(!held) return 'That item is no longer in your stash.';
'@

SubRx @'
          say2('Point at an item in the stash, then press its key number on the tactical belt below.');
'@ @'
          say2('Hover an item in the stash and press a number key to put it on your tactical belt.');
'@

SubRx @'
      if(P.equipped===_sg||P.equippedSec===_sg){ say2('That one goes up in your hands already.'); try{ sfx('clank'); }catch(e){} return; }
'@ @'
      if(P.equipped===_sg||P.equippedSec===_sg){ say2('That gun is already equipped.'); try{ sfx('clank'); }catch(e){} return; }
'@

SubRx @'
          'everything you have extracted, minus everything you carried in, over every run. A run that died or was abandoned lost what it carried in.');
'@ @'
          'Total value extracted minus value carried in, across all runs. Deaths and abandons count what you lost.');
'@

SubRx @'
      _bits.push('Starting a fight with someone who was not fighting you is what earns it: the Peddler, an unarmed survivor, or a pillager who had not raised a hand to you.');
'@ @'
      _bits.push('You earn it by attacking someone who was not a threat: the Peddler, an unarmed survivor, or a pillager who had not fought you.');
'@

SubRx @'
  L.push('One line. Paste it into Settings to rebuild this character.');
'@ @'
  L.push('Paste this code into Settings to restore this character.');
'@

SubRx @'
  if(craftHold&&craftHold.t>0.12&&craftHold.t<CRAFT_HOLD){ try{ say2('Let go too soon. Hold it for a full second.'); }catch(_cu){} }
'@ @'
  if(craftHold&&craftHold.t>0.12&&craftHold.t<CRAFT_HOLD){ try{ say2('Released too early. Hold for one second.'); }catch(_cu){} }
'@

SubRx @'
    b.onclick=function(e){ if(e&&e.detail){ try{ say2('Hold it down for a second. A click on its own spends nothing.'); }catch(_cs){} return; } btn.click(); };
'@ @'
    b.onclick=function(e){ if(e&&e.detail){ try{ say2('Hold for one second to confirm.'); }catch(_cs){} return; } btn.click(); };
'@

SubRx @'
      NET.status='Send this invite code to one friend. When they send a reply code back, paste it below and press LET THEM IN.';
'@ @'
      NET.status='Send this invite code to a friend. Paste their reply code below, then press LET THEM IN.';
'@

SubRx @'
        NET.status='Send this reply code back to your host. You are linked a few seconds after they paste it in.';
'@ @'
        NET.status='Send this reply code to your host. You will connect a few seconds after they enter it.';
'@

SubRx @'
        netLater(peer,NET_WAIT_JOIN,function(){ if(peer.state==='answer'){ NET.err='No link three minutes after the reply code was made. Ask your host for a new invite code, or try from another network.'; netDrop(peer,'timeout'); } });
'@ @'
        netLater(peer,NET_WAIT_JOIN,function(){ if(peer.state==='answer'){ NET.err='Connection timed out. Ask your host for a new invite code, or try another network.'; netDrop(peer,'timeout'); } });
'@

SubRx @'
    NET.status='Linked. Saying hello to the host.';
'@ @'
    NET.status='Connected. Joining the host.';
'@

SubRx @'
    netLater(peer,NET_WAIT_HELLO,function(){ if(peer.state==='open'){ NET.err='The host never answered.'; netDrop(peer,'silent'); } });
'@ @'
    netLater(peer,NET_WAIT_HELLO,function(){ if(peer.state==='open'){ NET.err='The host did not respond.'; netDrop(peer,'silent'); } });
'@

SubRx @'
    NET.status='Linked. Waiting for their hello.';
'@ @'
    NET.status='Connected. Waiting for them to join.';
'@

SubRx @'
               :'A copy that links up a different way tried to join. Both copies need to be the same build.';
'@ @'
               :'A player on a different build tried to join. Both players need the same build.';
'@

SubRx @'
                                                  :'The host copy links up a different way. Both copies need to be the same build.')
'@ @'
                                                  :'The host is on a different build. Both players need the same build.')
'@

SubRx @'
             :((m.why==='full')?'That party is full. Four is the most.':'The host turned the link down.');
'@ @'
             :((m.why==='full')?'That party is full. Four is the most.':'The host declined.');
'@

SubRx @'
    if(!NET.err) NET.err=(was==='in')?'The link to the host was lost.':'Could not link up with the host. One of your routers may be blocking a direct link; ask for a new invite code, or try from another network.';
'@ @'
    if(!NET.err) NET.err=(was==='in')?'Connection to host lost.':'Could not link up with the host. One of your routers may be blocking a direct link; ask for a new invite code, or try from another network.';
'@

SubRx @'
      NET.err='No link to your friend. One of your routers may be blocking a direct link. Make a new invite code, or try from another network.';
'@ @'
      NET.err='Could not connect. A router may be blocking the connection. Make a new invite code, or try another network.';
'@

SubRx @'
  if(typeof BroadcastChannel!=='function'||!netSupported()){ netModeMsg('This browser cannot link two windows of the game. 1 PLAYER still plays.'); return 'unsupported'; }
'@ @'
  if(typeof BroadcastChannel!=='function'||!netSupported()){ netModeMsg('This browser cannot run two game windows. 1 PLAYER still works.'); return 'unsupported'; }
'@

SubRx @'
  if(!NET.pair){ NET.err='This window was opened without a pair code. Close it and pick the mode again in the player 1 window.'; netRefresh(); return 'nopair'; }
'@ @'
  if(!NET.pair){ NET.err='This window is missing its pair code. Close it and pick the mode again in the player 1 window.'; netRefresh(); return 'nopair'; }
'@

SubRx @'
  st.textContent=NET.status||(role?'':'You are not in a party. Host one, or paste an invite code from a friend who is hosting.');
'@ @'
  st.textContent=NET.status||(role?'':'Not in a party. Host one, or paste an invite code from a friend.');
'@

SubRx @'
  if(sr){ sr.style.display=NET.same?'':'none'; if(NET.same){ if(sb2) sb2.textContent='THIS WINDOW: '+netSndLabel(NET.sndOn); if(sn) sn.textContent='Press to change. The other window: '+netSndOtherLabel()+'. Two windows on one PC play the same world sound twice, so one of them is switched off. A window switched off keeps every sound running and comes straight back when switched on.'; } }
'@ @'
  if(sr){ sr.style.display=NET.same?'':'none'; if(NET.same){ if(sb2) sb2.textContent='THIS WINDOW: '+netSndLabel(NET.sndOn); if(sn) sn.textContent='Press to change. The other window: '+netSndOtherLabel()+'. Only one window should play world sound, or you hear everything twice.'; } }
'@

SubRx @'
  g('partyhost').onclick=function(){ netUi(netHost,'Making an invite code. This takes a few seconds.'); };
'@ @'
  g('partyhost').onclick=function(){ netUi(netHost,'Creating invite code.'); };
'@

SubRx @'
  g('partyinvite').onclick=function(){ netUi(netHost,'Making a new invite code. This takes a few seconds.'); };
'@ @'
  g('partyinvite').onclick=function(){ netUi(netHost,'Creating a new invite code.'); };
'@

SubRx @'
    netUi(function(){ return netJoin(v); },'Reading the invite code and making your reply code. This takes a few seconds.');
'@ @'
    netUi(function(){ return netJoin(v); },'Creating your reply code.');
'@

SubRx @'
    line+='<div style="margin-top:5px">You have a gun of your own in your stash. To take it up, close this and choose Equip as your gun on it at the stash.</div>';
'@ @'
    line+='<div style="margin-top:5px">Your own gun is in your stash. Close this and choose Equip as your gun on it to take it up.</div>';
'@

SubRx @'
    'Last stop before the lift. Everything on this page can still be changed. '+
'@ @'
    'Final check before the lift. You can still change anything here. '+
'@

SubRx @'
      if(P.equipped===_rg2||P.equippedSec===_rg2){ say2('That one goes up in your hands already.'); return; }
'@ @'
      if(P.equipped===_rg2||P.equippedSec===_rg2){ say2('That gun is already equipped.'); return; }
'@

SubRx @'
    W.innerHTML='<b>Going up with '+escHtml(warn.join(', '))+'.</b> That is allowed, and it is how short raids happen.'; }
'@ @'
    W.innerHTML='<b>Going up with '+escHtml(warn.join(', '))+'.</b> You can still go up.'; }
'@

SubRx @'
    '<span>'+(on?'Taking the freebie kit. '+escHtml(freeKitText())+(P.kitSaved?' Your own packing is kept for when you switch back.':''):
'@ @'
    '<span>'+(on?'Taking the freebie kit. '+escHtml(freeKitText())+(P.kitSaved?' Your own loadout is saved for when you switch back.':''):
'@

SubRx @'
    '<div class="row"><div style="flex:1"><b>Music</b><div class="hint">A faint 16-bit loop, five pieces, one picked at random each time you come back down. UNDERCROFT plays it, OFF is silence. The surface is deliberately silent either way.</div></div>'+
'@ @'
    '<div class="row"><div style="flex:1"><b>Music</b><div class="hint">A quiet 16-bit loop in the Undercroft. OFF turns it off. There is no music on the surface.</div></div>'+
'@

SubRx @'
    '<div class="row"><div style="flex:1"><b>Back up your progress</b><div class="hint">Everything you own lives in this browser, and one browser cleanup erases it forever. This saves it all to a file in your Downloads. Do it once in a while.</div></div>'+
'@ @'
    '<div class="row"><div style="flex:1"><b>Back up your progress</b><div class="hint">Your progress lives in this browser. Clearing browser data erases it. This saves a backup file to your Downloads.</div></div>'+
'@

SubRx @'
    '<div class="row"><div style="flex:1"><b>Restore from a backup</b><div class="hint">Pick a backup file and your profile becomes what it was when you saved it. The profile you are on right now is kept until the next restore, so if you pick the wrong file, UNDO puts it back.</div></div>'+
'@ @'
    '<div class="row"><div style="flex:1"><b>Restore from a backup</b><div class="hint">Load a backup file to restore your profile. UNDO brings back the profile you replaced.</div></div>'+
'@

SubRx @'
    '<div class="row"><div style="flex:1"><b>Mouse cursor</b><div class="hint">The cursor hides while you are aiming and returns with the backpack. BACKSPACE forces it back at any time.</div></div>'+
'@ @'
    '<div class="row"><div style="flex:1"><b>Mouse cursor</b><div class="hint">The cursor hides while you aim and shows with the backpack open. BACKSPACE brings it back.</div></div>'+
'@

SubRx @'
    '<div class="row"><div style="flex:1"><b>Tuning console</b><div class="hint">Every dial the rows above set, and the rest of them, as live sliders. A slider you move is yours until you click its row again. SHIFT and the backquote key open it too.</div></div>'+
'@ @'
    '<div class="row"><div style="flex:1"><b>Tuning console</b><div class="hint">Every setting as a live slider. A slider you move stays set until you click its row again. SHIFT and backquote also open it.</div></div>'+
'@

SubRx @'
      'Click a slot to change it. Headgear and hair are earned and change nothing about how you play.</div>';
'@ @'
      'Click a slot to change it. Headgear and hair are cosmetic and earned through play.';
'@

SubRx @'
var VER='16.15';
'@ @'
var VER='16.16';
'@

$pat = "(?m)^  now:'v16\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.16: PLAIN GAME LANGUAGE, THE LARGER PASS. His order. About eighty on-screen lines that explained mechanics like a rulebook now read the way a game says them: raid messages, the stash and loadout screens, the Mainframe, the terms, the reputation card, the PARTY window, Settings hints. His TXSHIP sentences, the pillager and hire barks, the lore and every line a check reads word for word are untouched. Text only. Check 16.16 fails on v16.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
