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

# AN ALERT IS UP LONG ENOUGH TO READ (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ALERTK={crit:1,warn:1,ext:1};
'@ @'
var ALERTK={crit:1,warn:1,ext:1};
// v22.xx, the raid text rewrite (fix after batch 3, tr3fixb): AN ALERT IS UP LONG ENOUGH TO READ. A line of equal or higher rank
// replaced the alert once it had shown 0.6 s, which is about half a second of reading after the fade in: EXTRACTION CALLED and its
// detail flashed and gave way to THE SIEGE, and two rings closing in the same second flashed one after the other. An alert now
// holds the slot for 2.0 s (the time a message row of kind obj or crit is protected) before anything but a crit can take it, and a
// line waiting for it waits up to 2.5 s, so it gets its turn instead of dropping into the feed. A crit still takes the slot at once.
var ALERTMIN=2.0, ALERTWAIT=2.5;
'@

SubRx @'
  if(!a||k==='crit'||(MSGK[k].r>=MSGK[msgKind(a.k)].r&&now-a.at>=0.6)){ alertQDrop(m,key); alertShow(m,k,o,now); return; }
'@ @'
  if(!a||k==='crit'||(MSGK[k].r>=MSGK[msgKind(a.k)].r&&now-a.at>=ALERTMIN)){ alertQDrop(m,key); alertShow(m,k,o,now); return; }   // v22.xx (tr3fixb): 2.0 s, was 0.6
'@

SubRx @'
    if(now-e.t>(e.back?((e.o&&e.o.hold)?8:5):1.5)) alertToFeed(q.splice(i,1)[0]);   // waited 1.5 s (a displaced alert 5 s, a held one 8 s): into the feed, never lost
'@ @'
    if(now-e.t>(e.back?((e.o&&e.o.hold)?8:5):ALERTWAIT)) alertToFeed(q.splice(i,1)[0]);   // waited 2.5 s (a displaced alert 5 s, a held one 8 s): into the feed, never lost
'@

SubRx @'
  if(b>=0&&(!a||(br>=MSGK[msgKind(a.k)].r&&now-a.at>=0.6))){ e=q.splice(b,1)[0]; alertShow(e.m,e.k,e.o,now); }
'@ @'
  if(b>=0&&(!a||(br>=MSGK[msgKind(a.k)].r&&now-a.at>=ALERTMIN))){ e=q.splice(b,1)[0]; alertShow(e.m,e.k,e.o,now); }   // v22.xx (tr3fixb): 2.0 s, was 0.6
'@

SubRx @'
var VER='22.45';
'@ @'
var VER='22.46';
'@

$pat = "(?m)^  now:'v22\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.46: An alert now stays up at least 2 seconds before another one replaces it, unless the new one is critical. Check 22.46 fails on v22.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
