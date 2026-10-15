# merges the uic staging entries into tools\handoff\shots\ui-screens-js.json (skips names already there)
$ErrorActionPreference='Stop'
$f='C:\claudecode\dark raiders\tools\handoff\shots\ui-screens-js.json'
$spec=[IO.File]::ReadAllText($f) | ConvertFrom-Json
$have=@{}; foreach($s in @($spec.screens)){ $have[$s.name]=1 }
$kit="U.dep({kit:['gun_carbine','gun_smg','medkit','bandage','bandage','plate','frag','smoke','stim'],seed:4242,mapIx:0});"
$new=@()
function Add1([string]$name,[string]$screen,[string]$expect,[string]$js,[string]$query=''){
  if($script:have.ContainsKey($name)){ return }
  $script:new += [pscustomobject][ordered]@{name=$name;screen=$screen;before='staged by the uic audit 2026-10-14 (see js)';query=$query;expect=$expect;js=$js}
}
Add1 '61-raid-wheel-open' 'The item wheel open in a raid (hold Q), one segment hovered' "U.raid()&&!!__gx('G.wheel')" ($kit+" await U.wait(2500); U.down('KeyQ'); await U.wait(500); __gx('mouse.x=W/2+260;mouse.y=H/2-90'); await U.wait(800);")
Add1 '62-arcade-operator-menu' 'DEMO operator menu (Ctrl+Shift+F10 on the attract)' "U.on('#arcop')" @'
U.click('#modearcade1'); await U.wait(2500); window.dispatchEvent(new KeyboardEvent('keydown',{code:'F10',key:'F10',ctrlKey:true,shiftKey:true,bubbles:true,cancelable:true})); await U.wait(900);
'@
Add1 '63-arcade-operator-new-party-armed' 'DEMO operator menu, NEW PARTY pressed once (CONFIRM NEW PARTY)' "U.on('#arcop')" @'
U.click('#modearcade1'); await U.wait(2500); window.dispatchEvent(new KeyboardEvent('keydown',{code:'F10',key:'F10',ctrlKey:true,shiftKey:true,bubbles:true,cancelable:true})); await U.wait(700); await U.key('Enter'); await U.wait(800);
'@
Add1 '64-arcade-board-seeded-night' 'DEMO board after NEW PARTY (seeded night, no runs yet)' "U.on('#attract')" @'
U.click('#modearcade1'); await U.wait(2500); window.dispatchEvent(new KeyboardEvent('keydown',{code:'F10',key:'F10',ctrlKey:true,shiftKey:true,bubbles:true,cancelable:true})); await U.wait(700); await U.key('Enter'); await U.wait(500); await U.key('Enter'); await U.wait(600); if(U.on('#arcop')) await U.key('Escape'); await U.until(function(){ var pg=document.querySelector('#attract [data-ph]'); return pg&&pg.getAttribute('data-ph')==='board'&&U.on('#attract'); },20000); await U.wait(800);
'@
$career=@'
var q=__P(), now=Date.now(), L, i; q.credits=48250; q.xp=212000; q.runs=14; q.ext=9; q.weapons=["pistol","smg","rifle","carbine","magnum"]; q.equipped="rifle"; q.equippedSec="smg"; q.forged={rifle:{fk:2,el:"cryo"}}; q.stash=["gun_lmg","gun_dmr_v","gun_whisper","scrap","scrap","scrap","wire","wire","cell","cell","board","optic","servo","core","core","titan","bandage","bandage","medkit","plate","plate","frag","smoke","stim","ammobox","comp","blackbox"]; q.kit=[]; q.junk={scrap:1}; q.keep={core:1,titan:1,gun_whisper:1}; q.gunKills={rifle:137,smg:48,carbine:12,magnum:3,pistol:260}; q.codex={}; L=["pistol","smg","rifle","carbine","magnum","lmg","dmr_v","whisper","smg_v","rifle_v"]; for(i=0;i<L.length;i++) q.codex[L[i]]=now-86400000*(10-i); q.codexSeen=now-86400000*6; q.ach={firstout:now-86400000*9,ghost:now-86400000*4,haul20k:now-86400000*2}; q.trophies={firstout:now-86400000*9,ghost:now-86400000*4,centurion:now-86400000*3,forged:now-86400000*3,golden:now-86400000}; q.stashSort="type"; q.stashChip=""; q.stashTab="all"; q.stashLayout=6;
'@
Add1 '65-codex' 'The armory codex (career stash screen)' "U.modal()!==''" ("U.untitle(); "+$career+" __showScreen('hub'); __hubEnter(); __station('term','KeyE'); await U.wait(700); codexOpen(); await U.wait(700); return U.modal();")
Add1 '66-trophy-case' 'The trophy case' "U.modal()!==''" ("U.untitle(); "+$career+" __showScreen('hub'); __hubEnter(); __station('term','KeyE'); await U.wait(700); trophyOpen(); await U.wait(700); return U.modal();")
Add1 '67-career-stash-stocked' 'THE STASH with a stocked career profile (sort/filter bar, belt, wheel strip)' "U.on('#stashgrid')" ("U.untitle(); "+$career+" __showScreen('hub'); __hubEnter(); __station('term','KeyE'); await U.wait(1200); return U.modal();")
$setup="await U.floor(); __station('dev','KeyE'); await U.wait(1200);"
foreach($sec in 'THE RAID','AUDIO','CONTROLS','CONTROLLER','DISPLAY','ACCESSIBILITY'){
  $slug=($sec.ToLower() -replace ' ','-')
  $idx=@{'THE RAID'=68;'AUDIO'=69;'CONTROLS'=70;'CONTROLLER'=71;'DISPLAY'=72;'ACCESSIBILITY'=73}[$sec]
  Add1 ("$idx-settings-sec-$slug") ("Settings, section $sec (jump chip clicked)") "U.on('#settingsmodal')" ($setup+" var b=document.querySelector('.setjump button[data-sec=`"$sec`"]'); if(b) b.click(); await U.wait(900); return U.modal();")
}
Add1 '74-settings-change-pad-buttons' 'CHANGE PAD BUTTONS window' "U.on('#keysmodal')" ($setup+" U.click('#set_pad'); await U.wait(1200); return U.modal();")
Add1 '75-settings-pad-rebind-waiting' 'CHANGE PAD BUTTONS with a row waiting (PRESS A BUTTON)' "U.on('#keysmodal')" ($setup+" U.click('#set_pad'); await U.wait(900); var r=document.querySelector('#keysmodal .rebind'); if(r) r.click(); await U.wait(800); return U.modal();")
Add1 '76-haul-reveal-mid' 'Extracted card while the haul reveal is running' "U.on('#outcome')" ($kit+" await U.wait(2000); __state().bag.push('core','core','titan','board','servo','optic','scrap','wire','cell','gun_whisper','blackbox','comp'); __endRaid('extract'); await U.wait(750);")
Add1 '77-haul-reveal-done' 'Extracted card after the haul reveal (HAUL total)' "U.on('#outcome')" ($kit+" await U.wait(2000); __state().bag.push('core','core','titan','board','servo','optic','scrap','wire','cell','gun_whisper','blackbox','comp'); __endRaid('extract'); await U.wait(5500);")
Add1 '78-hub-pause-settings-pad' 'Pause box in the raid after the item wheel was used (belt/wheel strip visible)' "U.on('#pausebox')" ($kit+" await U.wait(2500); await U.key('KeyP'); await U.wait(1200);")
$spec.screens=@($spec.screens)+$new
$json=$spec | ConvertTo-Json -Depth 12
[IO.File]::WriteAllText($f,$json,(New-Object Text.UTF8Encoding($false)))
"added "+$new.Count
