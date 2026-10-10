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

# EVERY RAID LINE KNOWS WHAT KIND IT IS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function sayWhenFree(m){
  if(G&&!G.sim&&G.msgT>0){ (G.msgQ=G.msgQ||[]).push(m); return; }
  say(m);
}
function say(m){
  if(G&&!G.sim){ G.msg=m; G.msgT=3.2; return; }
'@ @'
// v21.80, THE RAID TEXT REWRITE, step 1 of the one message module. HIS ORDER (2026-10-09): "the way you phrase player-facing
// language is so fucking weird and not aligned with AAA games". Every line the raid shows is to read like a shooter HUD, and
// the lanes that draw them (an alert slot, a feed, a pickup stack) need to know what KIND of line each one is. Until now a line
// was a bare string: say(m) wrote G.msg and G.msgT=3.2 and nothing else, so nothing could tell a lethal warning from a weather
// remark. Now say(m,kind,o) and sayWhenFree(m,kind,o) take a kind from MSGK and an options object o {sub,key,hold,life,item,n,
// tag}; a call with one string is kind info, exactly as before. Nothing about drawing or timing changes in this build: G.msg,
// G.msgT=3.2 and the G.msgQ strings behave as they did. What is new is a record a later build and a check can read: G.msgK
// (the kind of the line showing), G.msgSub (its detail), G.msgLog (the last 16 lines said, {m,k,t}) and G.msgQM, the kind of
// each waiting line, kept beside G.msgQ so G.msgQ stays an array of strings. Cosmetic only: it returns at once when G.sim is
// set, draws no random number and changes no game state, so no seed, bot run or paired A/B can move.
// Rank decides what may replace what (crit 6 > warn 5 > ext 4 > obj 3 > ally 2 = info 2 > chat 1 > sys 0); pick is the pickup
// stack and log is the run report only (it is recorded and never shown). c is the HUDC colour token, life the seconds it shows.
var MSGK={
  crit:{r:6,c:'danger',life:4.5}, warn:{r:5,c:'danger',life:3.5}, ext:{r:4,c:'extract',life:3.5}, obj:{r:3,c:'warn',life:3.5},
  ally:{r:2,c:'ally',life:3.2}, info:{r:2,c:'text',life:3.2}, chat:{r:1,c:'dim',life:3.2}, sys:{r:0,c:'dim',life:3.2},
  pick:{r:-1,c:'text',life:4}, log:{r:-1,c:'dim',life:0}
};
function msgKind(k){ return (typeof k==='string'&&MSGK.hasOwnProperty(k))?k:'info'; }
function sayWhenFree(m,kind,o){
  if(G&&!G.sim&&G.msgT>0){
    var q=(G.msgQ=G.msgQ||[]), qm=(G.msgQM=G.msgQM||[]);
    qm.length=q.length;   // anything that emptied G.msgQ alone leaves no stale kinds behind
    q.push(m); qm.push({k:msgKind(kind),o:o||null}); return;
  }
  say(m,kind,o);
}
function say(m,kind,o){
  if(G&&G.sim) return;
  if(G){
    var k=msgKind(kind), lg=(G.msgLog=G.msgLog||[]);
    lg.push({m:m,k:k,t:G.t||0}); if(lg.length>16) lg.shift();
    if(k==='log') return;
    G.msg=m; G.msgT=3.2; G.msgK=k; G.msgSub=(o&&o.sub)||''; return;
  }
'@

SubRx @'
if(G.msgQ&&G.msgQ.length&&!(G.msgT>0)) say(G.msgQ.shift());
'@ @'
if(G.msgQ&&G.msgQ.length&&!(G.msgT>0)){ var _qm=(G.msgQM&&G.msgQM.length===G.msgQ.length)?G.msgQM.shift():(G.msgQM=[],null); say(G.msgQ.shift(),_qm&&_qm.k,_qm&&_qm.o); }   // v21.80: a waiting line keeps its kind
'@

SubRx @'
var VER='21.79';
'@ @'
var VER='21.80';
'@

$pat = "(?m)^  now:'v21\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.80: Raid messages now carry a kind and a short log, the base for the shooter style text. Nothing on screen changes yet. Check 21.80 fails on v21.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
