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

# A PAIR THAT NEVER LINKS SAYS SO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
NET.p2win=w; NET.same='host'; NET.mode=mode; netModeMsg('');
'@ @'
NET.p2win=w; NET.same='host'; NET.mode=mode; netModeMsg('');
  NET.sameT0=Date.now(); NET.noLink=0;   // v33.58 (cw-p2nolink): the 15 s no-link watch starts at the pick
'@

SubRx @'
NET.bc=null; NET.same=''; NET.pair=''; NET.mode=''; NET.p2win=null; NET.sameBusy=false;
'@ @'
NET.bc=null; NET.same=''; NET.pair=''; NET.mode=''; NET.p2win=null; NET.sameBusy=false; NET.sameT0=0; NET.noLink=0;
'@

SubRx @'
function netMateTick(dt){
'@ @'
function netMateTick(dt){ try{ netSameWatch(Date.now()); }catch(_nw){}   // v33.58 (cw-p2nolink): the no-link watch rides the Undercroft frame, no timer of its own
'@

SubRx @'
function netSamePost(m){ if(!NET.bc) return false;
'@ @'
// v33.58 (cw-p2nolink), coord-06 (2026-10-21): A PAIR THAT NEVER LINKS SAYS SO. In a cross-site frame (itch) player 2 booted and nothing on screen said why
// nothing happened. 15 s after the pick with nobody in, the status reads "player 2 not linked" where "waiting for player 2" showed, the title note
// says it with RETRY, and the hub feed says it once. It is drivable: netSameWatch(now) is called from the Undercroft frame (netMateTick) and by checks.
var NET_NOLINK_MS=15000;
function netSameWatch(now){
  if(NET.same!=='host'||!NET.sameT0) return 'off';
  if(netInCount()>0){
    if(NET.noLink){ NET.noLink=0; if(NET.status==='player 2 not linked') NET.status=''; netModeMsg(''); netRefresh(); }
    NET.sameT0=0; return 'linked';
  }
  if(NET.noLink) return 'shown';
  if(!(now-NET.sameT0>=NET_NOLINK_MS)) return 'wait';
  NET.noLink=1; NET.status='player 2 not linked';
  netModeMsg('player 2 not linked',true); netSay('player 2 not linked'); netRefresh();
  return 'nolink';
}
function netSamePost(m){ if(!NET.bc) return false;
'@

SubRx @'
var VER='33.56';
'@ @'
var VER='33.57';
'@

$pat = "(?m)^  now:'v33\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.57: If player 2 does not link within 15 seconds, the game says player 2 not linked and offers RETRY. Check 33.57 fails on v33.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
