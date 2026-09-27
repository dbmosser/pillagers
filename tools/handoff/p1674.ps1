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

# HOST OUT OF THE RAID, NOT GONE (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).

SubRx @'
  var s, st, out, i, nm;
'@ @'
  var s, st, out, i, nm, hw, ln;   // v16.74, his order: hw and ln carry how the host run ended and the line a friend reads
'@

SubRx @'
  if(NET.role==='join'&&st==='spec'&&s===0){ NET.status='Host has left the raid. Extract to finish your run.'; try{ if(typeof G!=='undefined'&&G&&!G.over) sayWhenFree('Host has left the raid. Extract to finish your run.'); }catch(_sw){} }   // v16.14, his ruling
'@ @'
  // v16.74, his order: the host is not gone when he spectates (v16.14): his run ended and he keeps the raid running for the
  // party. A friend read Host has left the raid while the host was still on his KILLED IN ACTION card. Now the party status
  // and the raid line name the host, say he is out of this raid and how his run ended (killed, extracted, abandoned, from the
  // how the word carries; nothing when it carries none), and Extract to finish your run. Nobody reads left.
  if(NET.role==='join'&&st==='spec'&&s===0){
    hw=netClean(m.how,12); hw=(hw==='dead')?'killed':(hw==='extract')?'extracted':(hw==='abandon')?'abandoned':'';
    ln=(netSeatName(0)||'The host')+' is out of this raid'+(hw?' ('+hw+')':'')+'. Extract to finish your run.';
    NET.status=ln; netRefresh();
    try{ if(typeof G!=='undefined'&&G&&!G.over) sayWhenFree(ln); }catch(_sw){}
  }
'@

SubRx @'
// out, so nobody is ended; a friend hears Host has left the raid. Extract to finish your run. It stops when no friend is up
'@ @'
// out, so nobody is ended; a friend hears NAME is out of this raid (killed / extracted / abandoned). Extract to finish your
// run. (v16.74 wording: the host is out, not gone.) It stops when no friend is up
'@

SubRx @'
var VER='16.73';
'@ @'
var VER='16.74';
'@

$pat = "(?m)^  now:'v16\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.74: THE HOST IS OUT OF THE RAID, NOT GONE. His report during his co-op session: player 1 died and gave up, and player 2 read Host has left the raid while player 1 was still on his KILLED IN ACTION card. The host is not gone: his run ended and he keeps the raid running for the party. Player 2 now reads the host name and how his run ended, killed, extracted or abandoned, and is told to extract to finish his run. Check 16.74 fails on v16.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
