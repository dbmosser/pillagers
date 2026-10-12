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

# DEMO DEATH: RUN OVER, OR SCORE LOST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(G&&G.arcade&&!G.sim){ if(how==='dead') return arcadeRespawn('dead');
'@ @'
  if(G&&G.arcade&&!G.sim){ if(how==='dead') return arcadeDied();
'@

SubRx @'
function arcadeRespawn(why){
'@ @'
// v23.6x (feat0f), HIS ANSWERS 1 and 4 (2026-10-12): "player should only be able to respawn in 2 player demo, should lose all score",
// and one self-revive, then death ends the raid. Going down and the one self-revive are the raid rules, unchanged. A death after it:
// in the 1 PLAYER DEMO ends the run (RUN OVER with the score he had, then initials when it makes the board); in the 2 PLAYER DEMO he
// drops back in as before but his own score and kill count go to 0 (SCORE LOST), and the other window hears the new score at once.
// A death in the burn already ends the run (feat0e).
function arcadeDied(){
  if(ARCADE.solo){ G.arcEnd='dead'; return true; }   // made at the top of the next frame (feat0e), as a burn death is
  var lost=Math.max(0,ARCADE.mine|0), r;
  ARCADE.mine=0; ARCADE.kills=0; ARCADE.streak=null;
  r=arcadeRespawn('dead');
  try{ say('SCORE LOST','warn',lost>0?{sub:'-'+arcadeCr(lost)}:undefined); }catch(_sl){}
  try{ ARCADE.scAt=0; arcadeScSend(); }catch(_ss){}
  return r;
}
function arcadeRespawn(why){
'@

SubRx @'
var VER='23.92';
'@ @'
var VER='23.93';
'@

$pat = "(?m)^  now:'v23\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.93: A death in the 1 player demo ends the run; in the 2 player demo you respawn with your score lost. Check 23.93 fails on v23.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
