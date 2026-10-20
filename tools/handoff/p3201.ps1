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

# THE PARTY IS THE PLAIN DEMO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
/* v30.xx (cw-party), his Q28: in the party launch mode (?party=1) Career, the saves and the stash are out of reach. The windows that go straight to the arcade never show the title at all; a host window with no pair code keeps only the 2 player arcade row. */
html.partyhide #title{ display:none !important; }
html.party #slotpanel, html.party #titlesub, html.party #titlestart, html.party #modecoop, html.party #modearcade1, html.party #modepvp, html.party .modelater, html.party #titleset{ display:none !important; }

'@ @'

'@

SubRx @'
// v30.xx (cw-party), HIS Q28 (2026-10-18): "one-click shortcut that opens both windows full screen on attract, with Career and stash out of reach". ?party=1 on
// the address is the party launch mode. Without it nothing below does anything. With it the title is never shown: the host window goes
// straight into the arcade (partyHostBoot), the player 2 window shows its attract at once (partyP2Boot), and the title rows stay hidden by CSS.
function partyOf(q){ return (/[?&]party=1(&|$)/).test(String(q||'')); }
var PARTY=partyOf((typeof location!=='undefined'&&location.search)||''), PARTY_EXIT=0;
if(PARTY){ try{ document.documentElement.classList.add('party'); if(NETP2||netPairOf(location.search)) document.documentElement.classList.add('partyhide'); }catch(_pc){} }

'@ @'
/* v28.xx (cw-cx-demoplain), his order (2026-10-19): "party" and "demo" need to be synonymous. Open the normal title and click the demo. */

'@

SubRx @'
// v30.xx (cw-partykeys), the coordinator: AT THE PARTY F2 AND F8 NEED CTRL. The party launch mode (?party=1, and the 2 player arcade demo played from it) is a guest on keyboard and mouse at localhost, so these two
// keys are live there, and the F keys sit right above the gun number keys: a stray F2 or F8 froze the raid in a state the guest cannot read. In party mode a plain F2 or F8 is not taken (nothing changes, nothing
// is swallowed) and Ctrl+F2 and Ctrl+F8 do the job, the same hidden-operator pattern as the Ctrl+Shift+F10 operator card. Outside party mode the keys are exactly what they were (a Ctrl chord is still not taken there).
function partyKeyOk(e){ if(!e||e.altKey||e.metaKey||e.shiftKey) return false; return PARTY?!!e.ctrlKey:!e.ctrlKey; }
// The Ctrl that starts the chord has already flipped the crouch in raidKey (one change per press), so the chord gives that one change back, exactly as Ctrl with the wheel does (v15.65): a party guest who
// uses the chord keeps the stance he had.
function partyCtrlGive(e){ try{ if(PARTY&&e&&e.ctrlKey&&G&&!G.over&&!G.sim&&('ctrlUndo' in G)&&G.ctrlUndo!==null&&(keys.ControlLeft||keys.ControlRight)){ G.crouchTog=G.ctrlUndo; G.ctrlUndo=null; } }catch(_pg){} }   // 'in', not != null: a stance that was never set is undefined, and that is a stance too

'@ @'
// v28.xx (cw-cx-demoplain), his order (2026-10-19): the plain demo needs Ctrl with F2 and F8, from the attract through the raid. Career keeps the plain keys.
function demoKeysOn(){ return !!((typeof ARCADE==='object'&&ARCADE&&ARCADE.on)||(typeof G!=='undefined'&&G&&G.arcade)); }
function partyKeyOk(e){ if(!e||e.altKey||e.metaKey||e.shiftKey) return false; return demoKeysOn()?!!e.ctrlKey:!e.ctrlKey; }
// v28.xx (cw-cx-demoplain): give back the crouch change made by the Ctrl press that began an editor or snip chord.
function partyCtrlGive(e){ try{ if(demoKeysOn()&&e&&e.ctrlKey&&G&&!G.over&&!G.sim&&('ctrlUndo' in G)&&G.ctrlUndo!==null&&(keys.ControlLeft||keys.ControlRight)){ G.crouchTog=G.ctrlUndo; G.ctrlUndo=null; } }catch(_pg){} }

'@

SubRx @'
var on=(DEV_LOCAL&&CFG.textEdit===1)?1:0, el=TXTAG;
  if(on===_txTagOn&&(!on||(el&&el.isConnected))) return on;
'@ @'
var on=(DEV_LOCAL&&CFG.textEdit===1)?1:0, el=TXTAG, label=demoKeysOn()?'edit words: on (ctrl f2)':'edit words: on (f2)';
  if(on===_txTagOn&&(!on||(el&&el.isConnected&&el.textContent===label))) return on;
'@

SubRx @'
    el.textContent=PARTY?'edit words: on (ctrl f2)':'edit words: on (f2)';

'@ @'

'@

SubRx @'
  el.style.display=on?'block':'none';
'@ @'
  el.textContent=label; el.style.display=on?'block':'none';
'@

SubRx @'
      if(!partyKeyOk(e)) return;   // v30.xx (cw-partykeys): in party mode the chord is Ctrl+F2, plain F2 does nothing
'@ @'
      if(!partyKeyOk(e)) return;   // v28.xx (cw-cx-demoplain): Ctrl+F2 in the demo, F2 in career.
'@

SubRx @'
      if(e.code==='F8'&&partyKeyOk(e)){   // v30.xx (cw-partykeys): in party mode the chord is Ctrl+F8, plain F8 does nothing
'@ @'
      if(e.code==='F8'&&partyKeyOk(e)){   // v28.xx (cw-cx-demoplain): Ctrl+F8 in the demo, F8 in career.
'@

SubRx @'
g.arcade&&PARTY&&g.mapFirstT>=MAPFIRST.auto
'@ @'
g.arcade&&g.mapFirstT>=MAPFIRST.auto
'@

SubRx @'
if(DEV_LOCAL) KEYS_LOCKED.push(['EDIT THE WORDS',PARTY?'CTRL + F2':'F2']);   // v30.xx (cw-txkey): the Keys window names it too (this machine only)
'@ @'
if(DEV_LOCAL) KEYS_LOCKED.push(['EDIT THE WORDS','F2']);   // v28.xx (cw-cx-demoplain): keysFixedHtml sets the current demo chord.
'@

SubRx @'
if(DEV_LOCAL) KEYS_LOCKED.push(['SNIP THE SCREEN',PARTY?'CTRL + F8':'F8']);   // v30.xx (cw-snip): the Keys window names it too (this machine only)
'@ @'
if(DEV_LOCAL) KEYS_LOCKED.push(['SNIP THE SCREEN','F8']);   // v28.xx (cw-cx-demoplain): keysFixedHtml sets the current demo chord.
'@

SubRx @'
  for(i=0;i<KEYS_LOCKED.length;i++) h+='<div class="row"><div style="flex:1"><b>'+KEYS_LOCKED[i][0]+'</b></div><span class="keyfixed">'+KEYS_LOCKED[i][1]+'</span></div>';
'@ @'
  // v28.xx (cw-cx-demoplain): this page stays open while entering and leaving the demo, so these two labels follow the current mode.
  for(i=0;i<KEYS_LOCKED.length;i++){
    if(KEYS_LOCKED[i][0]==='EDIT THE WORDS') KEYS_LOCKED[i][1]=demoKeysOn()?'CTRL + F2':'F2';
    if(KEYS_LOCKED[i][0]==='SNIP THE SCREEN') KEYS_LOCKED[i][1]=demoKeysOn()?'CTRL + F8':'F8';
    h+='<div class="row"><div style="flex:1"><b>'+KEYS_LOCKED[i][0]+'</b></div><span class="keyfixed">'+KEYS_LOCKED[i][1]+'</span></div>';
  }
'@

SubRx @'
// v30.xx (cw-party), the stale player 2 marks: a player 2 window killed mid raid leaves salvagerun:p2raid and p2live, and for 75 s the 2 PLAYER row refuses ("still in a raid in the other window"). At a party boot nothing else can be open, so both go before anything reads them.
function partyClearMarks(){ try{ localStorage.removeItem(p2RaidKey()); localStorage.removeItem(p2LiveKey()); }catch(_pm){} return true; }
if(PARTY) partyClearMarks();
'@ @'

'@

SubRx @'
// v30.xx (cw-party), the party launch mode (his Q28, Q30, Q31, Q24 of 2026-10-18). The host window of ?party=1&pair=CODE does what arcadePick does, without
// window.open (the shortcut opens player 2 itself). With no pair code it returns nopair and the title keeps only the 2 player arcade row.
function partyHostUp(){ if(NET.same!=='host'||!NET.pair) return false; if(netInCount()>0) return false; return netSamePost({t:'hostup',pair:NET.pair}); }
function partyHostBoot(q){
  q=(typeof q==='string')?q:((typeof location!=='undefined'&&location.search)||'');
  if(!partyOf(q)) return 'off';
  var pair=netPairOf(q), tl=document.getElementById('title');
  partyClearMarks();
  if(!pair) return 'nopair';
  NET.pair=pair; NET.arcPick=1; NET.mode='coop'; NET.pick='coop'; NET.same='host'; NET.p2win=null;
  if(!NET.role) netStartHost();
  netSameChan(); netPadInit(); netSndInit(); netSameHostLink();
  try{ if(typeof NET.start==='function') NET.start(); }catch(_ns){}
  if(tl) tl.style.display='none';
  if(!arcadeEnter('host')){ partyReload(); return 'fail'; }
  partyHostUp();
  try{ clearInterval(NET.partyT); NET.partyT=setInterval(partyHostUp,5000); }catch(_pi){}
  return 'host';
}
// The player 2 window never shows its title: the arcade attract is up at once (arcon from the host then changes nothing).
function partyP2Boot(r){
  if(!PARTY) return 'off';
  var tl=document.getElementById('title');
  if(tl) tl.style.display='none';
  if(r!=='ready') return 'wait';
  return arcadeEnter('p2')?'arcade':'fail';
}
function partyNav(u){ try{ location.href=u; }catch(_pn){} }
function partyPlainUrl(){ return String(location.href).split('#')[0].split('?')[0]; }
// A reload back into the party attract, at most 4 in 30 s so a build that cannot enter the arcade never spins.
function partyReload(){
  var now=Date.now(), a=[], k='pillagers:partyreloads';
  try{ a=JSON.parse(sessionStorage.getItem(k)||'[]').filter(function(x){ return now-x<30000; }); }catch(_p0){ a=[]; }
  if(a.length>=4) return false;
  a.push(now); try{ sessionStorage.setItem(k,JSON.stringify(a)); }catch(_p1){}
  try{ location.reload(); }catch(_p2){ return false; }
  return true;
}
// The operator's EXIT DEMO (the card row and the chord): in the party launch mode it goes to the same address without ?party, the full title.
function arcadeOpLeave(){
  if(!PARTY) return arcadeLeave();
  PARTY_EXIT=1;
  var r=arcadeLeave();
  partyNav(partyPlainUrl());
  return r;
}// THE TITLE.
'@ @'
// v28.xx (cw-cx-demoplain), his order (2026-10-19): EXIT DEMO leaves in place, through the ordinary demo teardown.
function arcadeOpLeave(){ return arcadeLeave(); }
// v28.xx (cw-cx-demoplain): THE TITLE.
'@

SubRx @'
  if(PARTY&&st) st.onclick=function(){ arcadePick(); };   // v30.xx (cw-party): no Career start in the party launch mode
  if(PARTY&&!(typeof NETP2!=='undefined'&&NETP2)){ try{ partyHostBoot(); }catch(_pb){} }

'@ @'

'@

SubRx @'
  if(PARTY){ try{ partyP2Boot(r); }catch(_pp){} }   // v30.xx (cw-party)

'@ @'

'@

SubRx @'
  if(PARTY&&typeof arcadePick==='function'){ arcadePick(); return 'start'; }   // v30.xx (cw-party): ENTER on a party title is the arcade row, never Career

'@ @'

'@

SubRx @'
  if(PARTY&&!PARTY_EXIT) partyReload();   // v30.xx (cw-party): any leave except the operator's EXIT DEMO goes straight back into the party attract (the reload keeps ?party=1), never to the title

'@ @'

'@

SubRx @'
   hint:'Turns every line of text in the game into something you can click and type over. Click a word anywhere, in a menu or on the screen during a raid, and rewrite it. Clear the box and press Enter to put the original back. Your wording is saved with your profile and follows the phrase everywhere it appears. '+(PARTY?'Ctrl with F2 turns':'F2 turns')+' it on and off from anywhere, and a raid stands still while it is on.',
'@ @'
   // v28.xx (cw-cx-demoplain): the existing hint is read when Settings renders, so its key follows the demo too.
   get hint(){ return 'Turns every line of text in the game into something you can click and type over. Click a word anywhere, in a menu or on the screen during a raid, and rewrite it. Clear the box and press Enter to put the original back. Your wording is saved with your profile and follows the phrase everywhere it appears. '+(demoKeysOn()?'Ctrl with F2 turns':'F2 turns')+' it on and off from anywhere, and a raid stands still while it is on.'; },
'@

SubRx @'
var VER='32.00';
'@ @'
var VER='32.01';
'@

$pat = "(?m)^  now:'v32\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.01: The normal title opens the demo. Its sector map starts automatically and its word editor and snip tools require Ctrl. Leaving the demo stays on the page. Check 32.01 fails on v32.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
