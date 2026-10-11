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

# ERRORS LEAVE THE SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function noteCrash(kind,msg,where){
'@ @'
// v22.xx, the raid text rewrite (R36): ERRORS LEAVE THE SCREEN. HIS ORDER (2026-10-09): the raid text reads like Call of
// Duty, Fortnite or ARC Raiders, and none of them print a program error into the middle of the screen. A crash said Something
// broke: and up to 80 characters of the raw error, a draw fault said Render fault logged: and its raw text. The raw text now goes
// to the run report only (P.crashes as before, and the line log as kind log, which is never shown), and the screen gets one
// system row per raid, ERROR SAVED TO YOUR RUN REPORT (errRow, G.errSaid). Outside a raid a crash still says that row once a
// sitting (the crashTold latch stays). The two slow frame lines are system rows in caps with the setting in the detail, each
// still once a session, and the wall glitch camera keeps its own row so he hears the shutter on the spot.
var ERRROW='ERROR SAVED TO YOUR RUN REPORT';
function errRow(raw){
  if(G&&!G.sim){
    if(raw) say(String(raw),'log');
    if(!G.errSaid){ G.errSaid=1; crashTold=true; say(ERRROW,'sys'); }
    return;
  }
  if(!crashTold){ crashTold=true; say(ERRROW,'sys'); }
}
function noteCrash(kind,msg,where){
'@

SubRx @'
    if(!crashTold){ crashTold=true; say('Something broke: '+msg.slice(0,80)+'. It was written into your run report.'); }
'@ @'
    errRow('ERROR  \u00b7  '+msg.slice(0,80));   // v22.xx (R36): the raw text to the run report, one row on the screen
'@

SubRx @'
        say('Render fault logged: '+G.drawErr);
'@ @'
        errRow('RENDER FAULT  \u00b7  '+G.drawErr);   // v22.xx (R36): the raw text to the run report, one row on the screen
'@

SubRx @'
        say('Wall glitch logged in your run report.');
'@ @'
        say('WALL GLITCH SAVED TO RUN REPORT','sys');   // v22.xx (R36): a system row in caps
'@

SubRx @'
    if(!DRS.said){ DRS.said=1; try{ sayWhenFree('Running slowly: the render resolution stepped down on its own. Settings has Auto resolution and Effects.'); }catch(_ds){} }
'@ @'
    if(!DRS.said){ DRS.said=1; try{ sayWhenFree('RESOLUTION STEPPED DOWN','sys',{sub:'Running slowly. Auto resolution in Settings.'}); }catch(_ds){} }   // v22.xx (R36): a system row in caps
'@

SubRx @'
  if(slow*2>PERF.win.length){ PERF.said=1; try{ sayWhenFree('Running slowly? Settings has Render resolution and Effects to lighten the load.'); }catch(_ps){} return true; }
'@ @'
  if(slow*2>PERF.win.length){ PERF.said=1; try{ sayWhenFree('RUNNING SLOWLY','sys',{sub:'Lower Render resolution or Effects in Settings.'}); }catch(_ps){} return true; }   // v22.xx (R36): a system row in caps
'@

SubRx @'
var VER='22.83';
'@ @'
var VER='22.84';
'@

$pat = "(?m)^  now:'v22\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.84: A game error no longer prints its raw text on the screen; one row says it was saved to your run report. Check 22.84 fails on v22.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
