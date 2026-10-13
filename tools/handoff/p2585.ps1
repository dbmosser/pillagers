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

# DEMO RUN OVER SHOWS THE BOARD FIRST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeOverGuard(){ return !!(ARCADE.on&&ARCADE.over&&ARCADE.over.at>0&&Date.now()-ARCADE.over.at<ARCADE_OVER_GUARD_MS&&!(G&&G.arcade&&!G.over)); }
'@ @'
// v25.xx (demoendboard), HIS ORDER (2026-10-13): "if I end run in demo mode it should show the high score table before starting next run".
// END RUN (and a death, an extraction or an idle out, which share the run end) showed the RUN OVER card, and the first press after it
// dropped the next run in, so the board only came up if he waited the card out (12 s). Now the RUN OVER card is followed by the board
// every time: a press on the card (after the 1.5 s hold) closes it and shows TONIGHTS BEST, with the run on it, and the initials
// finishing do the same; the press on the board starts the next run after a short hold (ARCADE_BOARD_HOLD), so a mashed button does not
// skip it. Waiting changes nothing (card 12 s, then the board, as before). Player 2 pressing A asks again until the board has been up.
var ARCADE_BOARD_HOLD=900;
function arcadeOverGuard(){ var o=ARCADE.over, n=Date.now(); return !!(ARCADE.on&&o&&!(G&&G.arcade&&!G.over)&&((o.at>0&&n-o.at<ARCADE_OVER_GUARD_MS)||(o.bat>0&&n-o.bat<ARCADE_BOARD_HOLD))); }
function arcadeOverAdvance(){
  var o=ARCADE.over;
  if(!ARCADE.on||!o||o.board||(G&&G.arcade&&!arcadeBenched())||arcadeIniLive()) return false;
  if(!(Date.now()-(+o.at||0)<ARCADE_IDLE.overMs)) return false;   // the card has gone: the loop is on the board already
  o.board=1; o.bat=Date.now();
  if(ARCADE.att){ ARCADE.att.ov=1; ARCADE.att.ph=''; }
  try{ arcadeAttShow(); }catch(_ab){}
  return true;
}
function arcadeOverWait(){
  var o=ARCADE.over;
  if(!ARCADE.on||!o||o.board||(G&&G.arcade)) return false;
  if(arcadeIniLive()||arcadeOverGuard()) return true;
  return arcadeOverAdvance();
}
'@

SubRx @'
oc=!!(o&&Date.now()-(+o.at||0)<ARCADE_IDLE.overMs)
'@ @'
oc=!!(o&&!o.board&&Date.now()-(+o.at||0)<ARCADE_IDLE.overMs)
'@

SubRx @'
  if(arcadeBenched()) arcadeUnbench(); else arcadeDropIn();   // v23.25 (arcade6)
'@ @'
  if(!arcadeBenched()&&arcadeOverAdvance()) return true;   // v25.xx (demoendboard): a press on the RUN OVER card shows the board first
  if(arcadeBenched()) arcadeUnbench(); else arcadeDropIn();   // v23.25 (arcade6)
'@

SubRx @'
  return anyNew?arcadeDropIn():false;
'@ @'
  if(anyNew&&arcadeOverAdvance()) return true;   // v25.xx (demoendboard): a press on the RUN OVER card shows the board first
  return anyNew?arcadeDropIn():false;
'@

SubRx @'
    if(ARCADE.role==='host') netSamePost({t:'arcinis',pair:NET.pair,run:n.run,on:0});
'@ @'
    if(ARCADE.role==='host') netSamePost({t:'arcinis',pair:NET.pair,run:n.run,on:0});
    if(ARCADE.over&&!ARCADE.over.board&&!(G&&G.arcade)){ ARCADE.over.board=1; ARCADE.over.bat=Date.now(); if(ARCADE.att) ARCADE.att.ov=1; }   // v25.xx (demoendboard): the initials are in, so the board is next
'@

SubRx @'
function arcadeJoinAsk(){
  if(!ARCADE.on||ARCADE.role!=='host') return 'off';
'@ @'
function arcadeJoinAsk(){
  if(!ARCADE.on||ARCADE.role!=='host') return 'off';
  if(arcadeOverWait()) return 'wait';   // v25.xx (demoendboard): the board is shown before the next run; player 2 asks again in 3 s
'@

SubRx @'
var VER='25.84';
'@ @'
var VER='25.85';
'@

$pat = "(?m)^  now:'v25\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.85: A demo run now ends on the high score board before the next run can start. Check 25.85 fails on v25.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
