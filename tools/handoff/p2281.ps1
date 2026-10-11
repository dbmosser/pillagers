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

# EMOTE AND CLOSED RING LINES IN CAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(p.downed){ say('Not while you are down.'); return; }
'@ @'
  // v22.81 (tr6fixc), the review of raid text batch 6: HIS ORDER (2026-10-09), a raid line is a short caps callout of at most 34
  // characters. The emote refusals and results were sentences; they are NOT WHILE DOWN, NOT WHILE ROLLING, LOWER YOUR GUN TO TALK,
  // NOBODY IN EARSHOT, and the pillager by name in caps: NAME WILL NOT TALK, NAME STANDS DOWN, NAME WAVES BACK (the longest tag,
  // 20 letters, keeps each within 34), and NOTHING TO SPARE with his name as the detail.
  if(p.downed){ say('NOT WHILE DOWN'); return; }
'@

SubRx @'
  if(p.roll>0){ say('Not while you are rolling.'); return; }
'@ @'
  if(p.roll>0){ say('NOT WHILE ROLLING'); return; }
'@

SubRx @'
    if(E.k==='hail') say('Lower your weapon to talk.');
'@ @'
    if(E.k==='hail') say('LOWER YOUR GUN TO TALK');
'@

SubRx @'
      if(!e.grudgeSaid){ e.grudgeSaid=1; say(e.name+' has not forgotten. He is not listening.'); }
'@ @'
      if(!e.grudgeSaid){ e.grudgeSaid=1; say(String(e.name).toUpperCase()+' WILL NOT TALK','ally'); }
'@

SubRx @'
        say(e.name+' lowers his gun.');
'@ @'
        say(String(e.name).toUpperCase()+' STANDS DOWN','ally');
'@

SubRx @'
      say(e.name+' waves back.');
'@ @'
      say(String(e.name).toUpperCase()+' WAVES BACK','ally');
'@

SubRx @'
          say(e.name+' has nothing to spare but his gun.');
'@ @'
          say('NOTHING TO SPARE','ally',{sub:String(e.name).toUpperCase()});
'@

SubRx @'
  if(E.k==='hail'&&!reached) say('Nobody in earshot.');
'@ @'
  if(E.k==='hail'&&!reached) say('NOBODY IN EARSHOT');
'@

SubRx @'
  if(code==='KeyV'&&G&&!G.over&&!G.paused&&!G.trade&&!repeat&&G.player&&G.player.downed&&!G.player.dying){ if(ev) ev.preventDefault(); say('Not while you are down.'); return; }
'@ @'
  if(code==='KeyV'&&G&&!G.over&&!G.paused&&!G.trade&&!repeat&&G.player&&G.player.downed&&!G.player.dying){ if(ev) ev.preventDefault(); say('NOT WHILE DOWN'); return; }   // v22.81 (tr6fixc): the caps callout
'@

SubRx @'
  if(G&&G.player&&G.player.downed){ if(!G.sim) say('Not while you are down.'); return; }
'@ @'
  if(G&&G.player&&G.player.downed){ if(!G.sim) say('NOT WHILE DOWN'); return; }   // v22.81 (tr6fixc): the caps callout
'@

SubRx @'
          say('Someone shot the survivor. Not on you.');
'@ @'
          say('SOMEONE SHOT THE SURVIVOR','chat',{sub:'Not on you.'});   // v22.81 (tr6fixc): the caps callout, a chat row as the raid text plan has it
'@

SubRx @'
          say('The Peddler is dead. Someone else did that.');
'@ @'
          say('THE PEDDLER IS DEAD','chat',{sub:'Someone else did that.'});   // v22.81 (tr6fixc): the caps callout, a chat row
'@

SubRx @'
      say(openZ ? ('This point is CLOSED. The open one is '+metres(openD)+'m away, marked on your map.')
                : 'This point is CLOSED.');
'@ @'
      // v22.81 (tr6fixc), the review of raid text batch 6: the caps callout. It said This point is CLOSED. and a sentence; it is
      // EXTRACTION A IS CLOSED, with the nearest open one, its distance and its direction as the detail, as the raid text plan has it.
      say('EXTRACTION '+extLetter(z)+' IS CLOSED','info',openZ?{sub:'Extraction '+extLetter(openZ)+' is open, '+metres(openD)+'m '+compass8(openZ.x-p.x,openZ.y-p.y)+'.'}:null);
'@

SubRx @'
var VER='22.80';
'@ @'
var VER='22.81';
'@

$pat = "(?m)^  now:'v22\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.81: The emote, closed ring and bystander lines read as short caps callouts, such as NOBODY IN EARSHOT and EXTRACTION A IS CLOSED. Check 22.81 fails on v22.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
