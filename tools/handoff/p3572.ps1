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

# NEW PLAYERS START ON HIS SETTINGS PAGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
dayMigrated:1,gameOpts:{flashRed:1},
'@ @'
dayMigrated:1,gameOpts:{flashRed:1},np1:1,
'@

SubRx @'
if(!Object.prototype.hasOwnProperty.call(P.gameOpts,'flashRed')) P.gameOpts.flashRed=(P.cfg&&P.cfg.flashRed===1)?1:0;
'@ @'
if(!Object.prototype.hasOwnProperty.call(P.gameOpts,'flashRed')) P.gameOpts.flashRed=(P.cfg&&P.cfg.flashRed===1)?1:0;
try{ newpKeep(P); }catch(_np){}   // v35.xx (cw-newpdefs): a save from before the new player defaults keeps the rows it was playing on, once (P.np1 marks it done)
'@

SubRx @'
if(ON_ITCH) itchDefs(1);
'@ @'
// v35.xx (cw-newpdefs), HIS ORDER (2026-10-28), with a picture of his settings page: "these should be the default settings for a new player", then "and for arcade mode".
// THE NEW PLAYER SET IS THE DEFAULT FOR EVERY BRAND NEW PROFILE, on every host (it was itch only): difficulty new player (forgiving hits, the long raid, rich loot,
// light shake, the large crosshair, seven extras off), with the rows that already stood where his picture has them (edit the words off, superhot off, shared sight
// on, fog of war off, few pillagers, few machines, light heat). Only the row defaults move. A SAVE FROM BEFORE keeps what it was playing on: newpKeep, once per
// save (P.np1, born set on a new profile), writes the old default as a pick for each of the twelve rows it never picked whose default moved, so his save, and
// any other, plays exactly as it did; a pick a save already holds is never touched. The storage key is unchanged. A brand new profile pays x1.05 (superhot off;
// the other rows sit on their easiest step, which pays the base). THE DEMO takes the same list at every start in either window (newpSandbox, newpDials), as it
// already took superhot off and reduced flashing; the sandbox is a copy, so leaving puts his career choices back. A linked window still builds its raid from the
// host word. Raid length and loot amount: the row defaults only; a career and a demo raid keep their own 10 minute clock.
var NEWP_SET=(function(){ var o={textEdit:0,superhot:0,sharedSight:0,fogWar:0,raiders:2,robots:2,ext:2}, k; for(k in ITCH_EASY) if(Object.prototype.hasOwnProperty.call(ITCH_EASY,k)) o[k]=ITCH_EASY[k]; return o; })();
function newpRow(k){ var i; for(i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].k===k) return GAMEOPTS[i]; return null; }
function newpHome(){ itchDefs(1); return true; }
function newpKeep(p){
  if(!p||typeof p!=='object'||p.np1===1) return false;
  if(typeof DIFF_KEYS==='undefined'||!DIFF_KEYS||typeof MAIN_GAME==='undefined'||!MAIN_GAME) return false;
  var t=ON_ITCH?ITCH_EASY:MAIN_GAME, i, k, row, was;
  if(!p.gameOpts||typeof p.gameOpts!=='object') p.gameOpts={};
  for(i=0;i<DIFF_KEYS.length;i++){
    k=DIFF_KEYS[i]; if(typeof p.gameOpts[k]==='number') continue;
    row=newpRow(k); if(!row||typeof t[k]!=='number') continue;
    was=gameOptDefault({k:k,def:t[k]});
    if(was!==gameOptDefault(row)) p.gameOpts[k]=was;
  }
  p.np1=1;
  return true;
}
function newpSandbox(sb){
  var k, row, oi, o;
  if(!sb||typeof sb!=='object') return false;
  sb.gameOpts=sb.gameOpts||{};
  for(k in NEWP_SET) if(Object.prototype.hasOwnProperty.call(NEWP_SET,k)){
    row=newpRow(k); if(!row) continue;
    sb.gameOpts[k]=NEWP_SET[k];
    if(sb.tuned&&typeof sb.tuned==='object') for(oi=0;oi<row.opts.length;oi++) for(o in row.opts[oi].cfg) delete sb.tuned[o];
  }
  return true;
}
function newpDials(){
  var k, row, sel, c;
  for(k in NEWP_SET) if(Object.prototype.hasOwnProperty.call(NEWP_SET,k)&&k!=='superhot'){
    row=newpRow(k); sel=row&&row.opts[NEWP_SET[k]]; if(!sel) continue;
    for(c in sel.cfg) CFG[c]=sel.cfg[c];
  }
  return true;
}
newpHome();
'@

SubRx @'
  var d=diffNow(), home=ON_ITCH?'new player':'main game';
'@ @'
  var d=diffNow(), home='new player';   // v35.xx (cw-newpdefs): new player is the default on every host now
'@

SubRx @'
  sb.gameOpts.superhot=0; if(sb.tuned) delete sb.tuned.superhot;
'@ @'
  newpSandbox(sb);   // v35.xx (cw-newpdefs), his order of 10-28 "and for arcade mode": every demo start takes the new player list
  sb.gameOpts.superhot=0; if(sb.tuned) delete sb.tuned.superhot;
'@

SubRx @'
  if(netShHost()===null) CFG.superhot=0;   // v35.xx (cw-shoff)
'@ @'
  newpDials();   // v35.xx (cw-newpdefs): the new player list takes effect in either window at entry (superhot keeps its own line, under the host word)
  if(netShHost()===null) CFG.superhot=0;   // v35.xx (cw-shoff)
'@

SubRx @'
var VER='35.71';
'@ @'
var VER='35.72';
'@

$pat = "(?m)^  now:'v35\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.72: a brand new save starts on new player: forgiving, long raid, rich, few pillagers and machines, light heat, superhot and fog of war off, shared sight on; every demo start takes the same list; saves from before keep their settings Check 35.72 fails on v35.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
