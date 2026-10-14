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

# AUTO-RELOAD AND PAUSE ON FOCUS LOSS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {k:'rumble', label:'Controller rumble',
'@ @'
  // v26.xx (settings4), HIS ORDER 2026-10-14 ("ok add all this stuff to settings"): AUTO-RELOAD WHEN EMPTY and PAUSE WHEN THE WINDOW LOSES FOCUS.
  // Both start as the game was: the trigger on an empty magazine reloads (v5.44, v10.56) and a lost window does not pause. AUTO-RELOAD OFF: the
  // empty gun only clicks until R. PAUSE ON FOCUS LOSS (a solo raid only, never in a party or a same machine pair) opens the pause box when
  // the window loses focus or is hidden, as ESC would.
  {k:'autoReload', label:'AUTO-RELOAD WHEN EMPTY', sec:'CONTROLS',
   hint:'THE TRIGGER ON AN EMPTY MAGAZINE RELOADS IT. OFF: IT ONLY CLICKS UNTIL YOU PRESS RELOAD.',
   opts:[
     {n:'ON',  cfg:{autoRel:1}},
     {n:'OFF', cfg:{autoRel:0}}
   ], def:0},
  {k:'pauseBlur', label:'PAUSE WHEN THE WINDOW LOSES FOCUS', sec:'CONTROLS',
   hint:'A SOLO RAID PAUSES WHEN YOU SWITCH AWAY. NEVER IN A PARTY.',
   opts:[
     {n:'OFF', cfg:{pauseBlur:0}},
     {n:'ON',  cfg:{pauseBlur:1}}
   ], def:0},
  {k:'rumble', label:'Controller rumble',
'@

SubRx @'
if(mouse.down&&p.reloading<=0&&!p.hand&&p.wep.mag>0&&p.ammo<=0&&p.reserve>0&&!p.downed&&p.jam<=0){
'@ @'
if(mouse.down&&p.reloading<=0&&!p.hand&&p.wep.mag>0&&p.ammo<=0&&p.reserve>0&&!p.downed&&p.jam<=0&&CFG.autoRel!==0){   // v26.xx (settings4): AUTO-RELOAD WHEN EMPTY
'@

SubRx @'
        if(p.reserve>0&&p.reloading<=0){
'@ @'
        if(p.reserve>0&&p.reloading<=0&&CFG.autoRel!==0){
'@

SubRx @'
} else if(p.reserve<=0&&!p.dryTold){ p.dryTold=1; if(!G.sim) blipMine('dry'); }
'@ @'
} else if((p.reserve<=0||(CFG.autoRel===0&&p.reloading<=0))&&!p.dryTold){ p.dryTold=1; if(!G.sim) blipMine('dry'); }   // v26.xx (settings4): with AUTO-RELOAD off the empty gun with a reserve clicks too
'@

SubRx @'
window.addEventListener('blur',function(){ releaseAllKeys(true); });
'@ @'
// v26.xx (settings4), HIS ORDER 2026-10-14: PAUSE WHEN THE WINDOW LOSES FOCUS. With the Settings row on, a raid on your own (no party, no same machine pair)
// opens the pause box when the window loses focus or is hidden, the box ESC opens. It never runs in a party, where the raid cannot stop for one
// player, and not when the box is already up. The row is off by default.
function focusPause(){
  if(CFG.pauseBlur!==1) return false;
  if(state!=='raid'||!G||G.over||G.sim||pauseOpen) return false;
  if(typeof NET==='object'&&NET&&(NET.on||NET.same||NET.specG)) return false;
  togglePauseBox(true);
  return !!pauseOpen;
}
window.addEventListener('blur',function(){ releaseAllKeys(true); try{ focusPause(); }catch(_fp){} });
'@

SubRx @'
if(document.hidden){ releaseAllKeys(); try{ if(AC&&AC.suspend) AC.suspend(); }catch(e){} } else lastTs=performance.now();
'@ @'
if(document.hidden){ releaseAllKeys(); try{ if(AC&&AC.suspend) AC.suspend(); }catch(e){} try{ focusPause(); }catch(_fp2){} } else lastTs=performance.now();
'@

SubRx @'
var VER='26.43';
'@ @'
var VER='26.44';
'@

$pat = "(?m)^  now:'v26\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.44: Controls has auto-reload when empty and pause when the window loses focus. Check 26.44 fails on v26.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
