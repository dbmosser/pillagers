$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}
function CutRx([string]$startLine, [string]$keepLine, [int]$expectLines) {
  if (([regex]::Matches($script:s, [regex]::Escape($startLine))).Count -ne 1) { throw "cut start matched not once: $startLine" }
  if (([regex]::Matches($script:s, [regex]::Escape($keepLine))).Count -ne 1) { throw "cut keep matched not once: $keepLine" }
  $a = $script:s.IndexOf($startLine); $b = $script:s.IndexOf($keepLine)
  if ($a -lt 0 -or $b -lt 0 -or $b -le $a) { throw "cut markers out of order: $startLine" }
  $cut = $script:s.Substring($a, $b - $a)
  $lines = ($cut -split "`n").Count - 1
  if ($lines -ne $expectLines) { throw "cut would remove $lines lines, expected $expectLines" }
  $script:s = $script:s.Remove($a, $b - $a)
  $script:n++
  Write-Output "  cut $lines lines: $($startLine.Trim().Substring(0,[Math]::Min(56,$startLine.Trim().Length)))"
}

# THE CHECK THAT TESTED THE POCKET GOES WITH THE POCKET. Keeping it would be a
# check that can only ever skip, and a skip is not a pass.
CutRx "  {v:'12.15',what:'the safe pocket refuses a grenade and an ammo box, which cannot come home from it, still takes a medkit, and a saved pocket on a grenade is cleared on load (2026-09-06 menu audit)'," "  {v:'12.14',what:'the controls card no longer teaches an X (or pad Y) gun swap that has no handler; it names the belt keys instead (2026-09-06 first-ten-minutes audit)'," 24

# AND THE SCREEN IS FOUR THINGS NOW, not five. Check 9.98 counts the parts of
# the stash screen by name, so it has to lose the part that is gone or it fails
# for the right reason at the wrong time.
SubRx @'
  {v:'9.98',what:'the stash screen is five things: stash, backpack, hotbar, safe pocket, freebie kit, with one way out',
'@ @'
  {v:'9.98',what:'the stash screen is four things: stash, backpack, hotbar, freebie kit, with one way out (the safe pocket was the fifth until v12.35 deleted it)',
'@
SubRx @'
     var need={stash:'#stashgrid',backpack:'#kitgrid',hotbar:'#hotplanwrap',safe:'#safegrid',freebie:'#hubfreekit .fkbtn'};
'@ @'
     var need={stash:'#stashgrid',backpack:'#kitgrid',hotbar:'#hotplanwrap',freebie:'#hubfreekit .fkbtn'};
'@

# v12.35 CHECK, inserted before the v12.34 entry. A deletion is proved by what
# is gone AND by what is untouched, so this asks for both: nothing of the pocket
# survives anywhere it used to live, a death still pays out and lists what it
# cost with no pocket line on the card, and the world container that shares the
# word is still built, still drawn and still searchable.
SubRx @'
  {v:'12.34',what:'the Peddler stall is not a pause: with the trade window open the inbound extraction still counts down, a landed extraction still spends its boarding window, and a point whose closing time passes while he shops shuts (2026-09-07 audit, trade-freeze)',
'@ @'
  {v:'12.35',what:'the safe pocket is gone from the screen, the code and the profile, a death pays out and lists the loss with no pocket line, and the secure cases in the world, which share the word, are untouched (his order of 2026-09-08)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__hubEnter&&window.__showScreen)) return 'SKIP: this fixture cannot reach the floor and a raid';
     var bad=[], P2=__P(), keep={stash:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice()};
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // ONE: nothing of it is left in the code.
       if(typeof setSafe!=='undefined') bad.push('setSafe is still defined');
       if(typeof safeKey!=='undefined') bad.push('safeKey is still defined');
       if(typeof safeUpKey!=='undefined') bad.push('safeUpKey is still defined');
       if(typeof renderSafe!=='undefined') bad.push('renderSafe is still defined');
       // TWO: nothing of it is left on the screen. The floor is opened for real,
       // because an element can exist in the document and never be drawn.
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       try{ renderHub(); }catch(_rh){}
       if(document.getElementById('safegrid')) bad.push('the safe pocket grid is still in the stash screen');
       if(document.getElementById('safen')) bad.push('the safe pocket counter is still in the stash screen');
       var hub=document.getElementById('hub');
       if(hub&&/safe pocket/i.test(hub.innerText||'')) bad.push('the stash screen still says safe pocket somewhere');
       // THREE: A DEATH STILL PAYS OUT, which is the path the pocket branch lived in.
       // (The profile migration runs at load and this fixture is already loaded,
       // so it is named in Not verified rather than half-driven here.)
       __deploy({kit:['medkit','plate'],mapIx:0,seed:4242});
       var g=__state();
       if(!g) bad.push('control: the raid did not start');
       else{
         g.bag=['comp','servo'];
         g.player.downed=false; __endRaid('dead');
         var txt=''; try{ txt=((document.getElementById('outcome')||{}).innerText||'').replace(/\s+/g,' '); }catch(_t){}
         if(txt.indexOf('KILLED IN ACTION')<0) bad.push('control: a death did not open the outcome card, so the payout path is not being measured');
         if(txt.indexOf('LOST')<0) bad.push('control: the death card lists nothing as lost, so the ledger it shares with the pocket branch is not running');
         if(/safe pocket/i.test(txt)) bad.push('the death card still says safe pocket');
       }
       // FIVE, AND THIS IS THE ONE A CARELESS DELETION BREAKS: the world container
       // called a safe is a different thing with the same five letters.
       __topClear();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g2=__state(), i, safes=0;
       if(!g2||!g2.containers) bad.push('control: the raid built no containers at all');
       else{
         for(i=0;i<g2.containers.length;i++) if(g2.containers[i].type==='safe') safes++;
         if(safes<1) bad.push('the map built no secure cases: the deletion took the world container that shares the word');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g3=__state(); if(g3&&!g3.over){ g3.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       P2.stash=keep.stash; P2.kit=keep.kit;
       try{ delete P2.safe; delete P2.safeUp; saveProfile(); }catch(_s){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.34',what:'the Peddler stall is not a pause: with the trade window open the inbound extraction still counts down, a landed extraction still spends its boarding window, and a point whose closing time passes while he shops shuts (2026-09-07 audit, trade-freeze)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + ([regex]::Matches($src, "(?m)^CutRx ")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
