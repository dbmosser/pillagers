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

# NO REJOINING A RAID YOU DIED OR EXTRACTED IN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
}function netUpEnd(how){
  if(!NET.on) return false;
'@ @'
}function netUpEnd(how){
  if(!NET.on) return false;
  if(NET.role==='join'&&(how==='dead'||how==='extract')&&NET.upSeed) NET.lateBan=NET.upSeed>>>0;   // v17.66, his ruling 2026-10-01: no rejoining a raid you died or extracted in
'@

SubRx @'
  if(!NET.upWord||typeof G==='undefined'||!G||G.over||G.sim||!G.player){ netSend(peer,{t:'raidno'}); return 'no raid'; }
'@ @'
  if(!NET.upWord||typeof G==='undefined'||!G||G.over||G.sim||!G.player){ netSend(peer,{t:'raidno'}); return 'no raid'; }
  if(NET.lateOut&&NET.lateOut[peer.seat]===(NET.upWord.seed>>>0)){ netSend(peer,{t:'raidno',why:'out'}); return 'out'; }   // v17.66, his ruling: he died or extracted in this raid
'@

SubRx @'
  want=!!(hub&&NET.on&&NET.role==='join'&&NET.hostSeed&&state==='hub'&&!(tt&&tt.classList.contains('on'))&&!(typeof G!=='undefined'&&G&&!G.over));
'@ @'
  want=!!(hub&&NET.on&&NET.role==='join'&&NET.hostSeed&&(NET.lateBan>>>0)!==(NET.hostSeed>>>0)&&state==='hub'&&!(tt&&tt.classList.contains('on'))&&!(typeof G!=='undefined'&&G&&!G.over));
'@

SubRx @'
  if(NET.hostSeed&&!(typeof G!=='undefined'&&G&&!G.over)){ netLateAsk(); netSay('Your party is up top. Joining their raid in progress.'); return true; }   // v17.51: the lift joins a raid in progress
'@ @'
  if(NET.hostSeed&&(NET.lateBan>>>0)===(NET.hostSeed>>>0)){ netSay('You are out of this raid. You go up with your host next time.'); return true; }   // v17.66, his ruling 2026-10-01
  if(NET.hostSeed&&!(typeof G!=='undefined'&&G&&!G.over)){ netLateAsk(); netSay('Your party is up top. Joining their raid in progress.'); return true; }   // v17.51: the lift joins a raid in progress
'@

SubRx @'
  if(st==='out'&&s!==0&&typeof G!=='undefined'&&G&&!G.over&&!G.sim){ hw=netClean(m.how,12); hw=(hw==='dead')?'killed':(hw==='extract')?'extracted':(hw==='abandon')?'abandoned':''; try{ sayWhenFree(nm+' is out of this raid'+(hw?' ('+hw+')':'')+'.'); }catch(_so){} }  if(st==='no'){ NET.status=nm+' could not go up with you: '+netUpWhyText(m.why)+'.'; netRefresh(); try{ if(typeof G!=='undefined'&&G&&!G.over) sayWhenFree(NET.status); }catch(_sn){} }
'@ @'
  if(st==='out'&&s!==0&&typeof G!=='undefined'&&G&&!G.over&&!G.sim){ hw=netClean(m.how,12); hw=(hw==='dead')?'killed':(hw==='extract')?'extracted':(hw==='abandon')?'abandoned':''; try{ sayWhenFree(nm+' is out of this raid'+(hw?' ('+hw+')':'')+'.'); }catch(_so){} }  if(st==='no'){ NET.status=nm+' could not go up with you: '+netUpWhyText(m.why)+'.'; netRefresh(); try{ if(typeof G!=='undefined'&&G&&!G.over) sayWhenFree(NET.status); }catch(_sn){} }
  if(NET.role==='host'&&st==='out'&&(m.how==='dead'||m.how==='extract')&&NET.upWord){ if(!NET.lateOut) NET.lateOut={}; NET.lateOut[s]=NET.upWord.seed>>>0; }   // v17.66, his ruling: that seat sits this raid out
'@

SubRx @'
  if(m.t==='raidno'){ NET.hostSeed=0; NET.status='Your host is not up top.'; netRefresh(); return 'raidno'; }   // v17.60: a stale mark clears with the answer
'@ @'
  if(m.t==='raidno'){ NET.hostSeed=0; NET.status=(m.why==='out')?'You are out of this raid. You go up with your host next time.':'Your host is not up top.'; netRefresh(); return 'raidno'; }   // v17.66: and the answer to one who died or extracted in it
'@

SubRx @'
var VER='17.65';
'@ @'
var VER='17.66';
'@

$pat = "(?m)^  now:'v17\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.66: A teammate who died or extracted sits out the rest of that raid; leaving any other way (abandon, a closed window, a lost link) can still JOIN THE RAID IN PROGRESS. Check 17.66 fails on v17.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
