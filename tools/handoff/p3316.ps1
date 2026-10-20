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

# THE 2-PLAYER PARTY LINES BECOME SHORT CALLOUTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      NET.status=peer.name+' joined your party.'; NET.err='';
'@ @'
      // v33.xx (cw-partycallouts), job 66 (RULES: never an explaining sentence on screen; his answer 27 lets us reword): every 2-player
      // party line below, in the hub toast and the PARTY window, is a short lower-case callout with no full stop and no second sentence.
      NET.status=peer.name+' joined'; NET.err='';
'@

SubRx @'
NET.status=(m.why==='out')?'You are out of this raid. You go up with your host next time.':'Your host is not up top.';
'@ @'
NET.status=(m.why==='out')?'out until the next raid':'host not up top';
'@

SubRx @'
NET.status='You are in the party hosted by '+(hn||'your host')+'.';
'@ @'
NET.status='in '+(hn||'your host')+'\'s party';
'@

SubRx @'
NET.status+=' They are in a raid now: go up at the lift to join it.';
'@ @'
NET.status+=' \u00b7 ascend at the lift to join';
'@

SubRx @'
NET.status=peer.name+' left your party.';
'@ @'
NET.status=peer.name+' left';
'@

SubRx @'
netSay('Cannot ascend while your party is still in the raid.');
'@ @'
netSay('cannot ascend \u00b7 party still in the raid');
'@

SubRx @'
netSay('You are out of this raid. You go up with your host next time.');
'@ @'
netSay('out until the next raid');
'@

SubRx @'
netSay('Your party is up top. Joining their raid in progress.');
'@ @'
netSay('joining the raid in progress');
'@

SubRx @'
netSay('Only the host can start the raid. You ascend with them.');
'@ @'
netSay('only the host can start the raid');
'@

SubRx @'
netSay('Your party went up without you: this window could not build the same surface. Open the PARTY window at the lift.');
'@ @'
netSay('party ascended without you');
'@

SubRx @'
NET.status='Your party ascended together.';
'@ @'
NET.status='party ascended';
'@

SubRx @'
NET.status='Asking to join the raid in progress.';
'@ @'
NET.status='asking to join the raid';
'@

SubRx @'
ln=(netSeatName(0)||'The host')+' is out of this raid'+(hw?' ('+hw+')':'')+'. Extract to finish your run.';
'@ @'
ln=(netSeatName(0)||'the host')+' is out'+(hw?' ('+hw+')':'')+' \u00b7 extract to finish';
'@

SubRx @'
{sub:(netSeatName(0)||'The host')+' '+((hw==='killed')?'was killed':hw?hw:'is out')+'. Extract to finish.',icon:'party'}
'@ @'
{sub:(netSeatName(0)||'the host')+' '+((hw==='killed')?'was killed':hw?hw:'is out')+' \u00b7 extract to finish',icon:'party'}
'@

SubRx @'
NET.status=nm+' could not go up with you: '+netUpWhyText(m.why)+'.';
'@ @'
NET.status=nm+' did not ascend \u00b7 '+netUpWhyText(m.why);
'@

SubRx @'
function netUpWhyText(w){
  w=netClean(w,24);
  if(w==='surface') return 'it could not build the same surface';
  if(w==='up top already') return 'it was up top already';
  if(w==='on the title') return 'it was on the title';
  if(w==='still on the run card') return 'it was still on the run card';
  return 'it could not go up';
}
'@ @'
// v33.xx (cw-partycallouts), job 66: the reason a teammate did not ascend, as the short end of a callout
function netUpWhyText(w){
  w=netClean(w,24);
  if(w==='surface') return 'map did not match';
  if(w==='up top already') return 'already up top';
  if(w==='on the title') return 'on the title';
  if(w==='still on the run card') return 'still on the run card';
  return 'not ready';
}
'@

SubRx @'
NET.status='Your party is still in the raid. Waiting for them to finish.';
'@ @'
NET.status='waiting for the party to finish';
'@

SubRx @'
NET.status='Your party is back. Raid over.';
'@ @'
NET.status='party back \u00b7 raid over';
'@

SubRx @'
NET.status='Waiting for your party to choose a kit.';
'@ @'
NET.status='waiting for the party to pick a kit';
'@

SubRx @'
NET.status=(why==='out')?'Your host is out of the raid. You are running it now.':'Connection to your host was lost. You are running the raid now.';
'@ @'
NET.status=(why==='out')?'host out \u00b7 you are running the raid':'host lost \u00b7 you are running the raid';
'@

SubRx @'
  if(!NET.role) netStartHost();
  NET.status='Waiting for the player 2 window to link up.';
'@ @'
  if(!NET.role) netStartHost();
  NET.status='waiting for player 2';
'@

SubRx @'
  netSamePost({t:'offer',pair:NET.pair,mode:NET.mode,code:r.code});
  NET.status='Waiting for the player 2 window to link up.';
'@ @'
  netSamePost({t:'offer',pair:NET.pair,mode:NET.mode,code:r.code});
  NET.status='waiting for player 2';
'@

SubRx @'
var VER='33.15';
'@ @'
var VER='33.16';
'@

$pat = "(?m)^  now:'v33\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.16: They read as short callouts with no full stop: pillager joined, waiting for player 2, party ascended, out until the next raid. Check 33.16 fails on v33.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
