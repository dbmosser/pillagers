$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# THE RIVAL WARNING WROTE OVER WHATEVER WAS SHOWING, AND ONE WAITING SLOT COULD HOLD
# ONLY ONE LINE.
#
# v13.32 gave landing one waiting line, G.msgNext, shown when the current message runs
# out. The rival warning is a separate 4 second timer that calls say() directly, and
# say() holds one message and overwrites it. On a raid with a weather line and a rival,
# the weather line shows for 3.2 seconds, the loaner line takes its turn, and 0.8
# seconds later the rival line writes over it. A second line waiting at the same time
# as the first would also replace it in the slot.
#
# A SHORT QUEUE, G.msgQ, replaces the slot. sayWhenFree(m) says the line at once when
# nothing is showing, and otherwise queues it; the frame loop shows the next queued
# line each time the current message runs out. The loaner line and the rival warning
# both go through it. Every other say() is unchanged, so nothing else waits.
#
# THE RIVAL LINE KEEPS ITS 4 SECOND DELAY and its guard, and only its say() changes.
SubRx @'
      if(G.msgT>0) G.msgNext=_loanLn; else say(_loanLn);
'@ @'
      sayWhenFree(_loanLn);   // v13.33: through the queue, so nothing writes over it
'@

SubRx @'
      if(G.msgNext&&!(G.msgT>0)){ var _mNext=G.msgNext; G.msgNext=null; say(_mNext); }
'@ @'
      // v13.33: a short queue in place of the one slot, so two waiting lines both show.
      if(G.msgQ&&G.msgQ.length&&!(G.msgT>0)) say(G.msgQ.shift());
'@

SubRx @'
      setTimeout((function(nm,g0){return function(){ if(G===g0&&!G.over) say('YOUR RIVAL is out here: '+nm+'. He will shoot on sight.'); };})(G.ents[_rv].name,G),4000);
'@ @'
      setTimeout((function(nm,g0){return function(){ if(G===g0&&!G.over) sayWhenFree('YOUR RIVAL is out here: '+nm+'. He will shoot on sight.'); };})(G.ents[_rv].name,G),4000);   // v13.33: waits its turn
'@

SubRx @'
function say(m){
'@ @'
// v13.33: SAY IT WHEN NOTHING ELSE IS SHOWING. say() holds one message and a second
// call writes over it; a line that must not be lost waits in G.msgQ, and the frame
// loop shows the next one when the current message runs out. Outside a live raid
// it is just say().
function sayWhenFree(m){
  if(G&&!G.sim&&G.msgT>0){ (G.msgQ=G.msgQ||[]).push(m); return; }
  say(m);
}
function say(m){
'@

SubRx @'
var VER='13.32';
'@ @'
var VER='13.33';
'@

$pat = "(?m)^  now:'v13\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.33: THE RIVAL WARNING WROTE OVER WHATEVER WAS SHOWING, AND ONE WAITING SLOT COULD HOLD ONLY ONE LINE. v13.32 gave landing one waiting line, shown when the current message runs out. The rival warning is a separate 4 second timer that called say directly, and say holds one message and overwrites it, so on a raid with a weather line and a rival the loaner line showed for under a second before the rival line wrote over it, and a second waiting line would have replaced the first in the slot. A short queue replaces the slot: sayWhenFree says a line at once when nothing is showing and otherwise queues it, and the frame loop shows the next queued line each time the current message runs out. The loaner line and the rival warning both go through it; the rival line keeps its 4 second delay and its guard, and every other say is unchanged. Check 13.33 starts a raid, shows a message, queues two lines behind it through sayWhenFree, steps the real frame loop, and requires all three to be shown in order with none lost, and fails on v13.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
