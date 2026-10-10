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

# THE LANES KEEP TIME IN THE DEATH BEAT AND THE BURN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function sayWhenFree(m,kind,o){
'@ @'
// v22.36, the raid text rewrite (R12): THE LANES KEEP TIME IN THE DEATH BEAT AND THE BURN. The message rows, the alert and the
// waiting queue ran down only in the running branch of the frame, so they froze in the 1.5 s death beat and for the whole burn:
// a remark said just before stood on screen through the burn, and the queue never moved. msgTick runs them on frame time (dt,
// capped at 0.1 s) in the running branch, the death beat and the burn alike; only a solo pause, which stops the world, stops them.
// MERIDIAN IS BURNING THE SITE is a critical alert held while the site burns (G.nuking).
function msgTick(dt){
  if(!G) return;
  dt=(dt>0)?Math.min(0.1,dt):0;
  if(G.msgT>0) G.msgT-=dt;
  if(G.feed&&G.feed[1]&&G.feed[1].T>0) G.feed[1].T-=dt;   // v21.86 (R04): the second message row runs out on the same clock
  alertTick(dt);   // the alert lane and its queue (R08)
  // v13.32, v13.33: a short queue of lines that must not be lost, shown when the rows free up. v21.88 (R06): only into a row that is
  // free or past its protection. v21.91 (R07): the highest ranked waiting line first, stale ones dropped, 1.8 s while two or more wait.
  if(G.msgQ&&G.msgQ.length&&msgFree()){ var _qn=msgQNext(); if(_qn){ G.msgDrain=1; try{ say(_qn.m,_qn.k,_qn.o); } finally { G.msgDrain=0; } if(_qn.n>=2&&G.msg===_qn.m&&G.msgT>1.8) G.msgT=1.8; } }
}
function sayWhenFree(m,kind,o){
'@

SubRx @'
      if(G.msgT>0) G.msgT-=dt;
      if(G.feed&&G.feed[1]&&G.feed[1].T>0) G.feed[1].T-=dt;   // v21.86 (R04): the second message row runs out on the same clock
      alertTick(dt);   // v22.13 (R08): the alert lane and its queue run on the same clock
      // v13.32: one waiting line, shown when the current message runs out rather than
      // written over it in the same frame.
      // v13.33: a short queue in place of the one slot, so two waiting lines both show.
      // v21.88 (R06): a waiting line comes out as soon as a row is free or past its protection (msgFree), and only into such a row.
      // v21.91 (R07): the highest ranked waiting line first, stale ones dropped (msgQNext), and 1.8 s while two or more wait.
      if(G.msgQ&&G.msgQ.length&&msgFree()){ var _qn=msgQNext(); if(_qn){ G.msgDrain=1; try{ say(_qn.m,_qn.k,_qn.o); } finally { G.msgDrain=0; } if(_qn.n>=2&&G.msg===_qn.m&&G.msgT>1.8) G.msgT=1.8; } }   // v21.80: a waiting line keeps its kind
'@ @'
      msgTick(dt);   // v22.36 (R12): the rows, the alert and the queue (see msgTick)
'@

SubRx @'
    G.deathBeat-=dt;
'@ @'
    G.deathBeat-=dt;
    msgTick(dt);   // v22.36 (R12): the lanes keep time in the death beat
'@

SubRx @'
    } else if(G.nuking){
      tickNuke(dt);
'@ @'
    } else if(G.nuking){
      msgTick(dt);   // v22.36 (R12): and in the burn
      tickNuke(dt);
'@

SubRx @'
      say('MERIDIAN IS BURNING THE SITE.');
'@ @'
      say('MERIDIAN IS BURNING THE SITE','crit',{key:'burn',hold:'nuking'});   // v22.36 (R12): a critical alert held while it burns
'@

SubRx @'
var VER='22.35';
'@ @'
var VER='22.36';
'@

$pat = "(?m)^  now:'v22\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.36: Raid lines keep running down after you die and while the site burns, and the burn is a critical alert. Check 22.36 fails on v22.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
