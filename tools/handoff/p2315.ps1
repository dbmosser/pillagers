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

# TWO TEAMMATES DOWN ARE TWO ALERTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function alertSay(m,k,o){
'@ @'
// v23.xx, the raid text rewrite (fix after batch 9, tr9fixo): TWO TEAMMATES DOWN ARE TWO ALERTS. v23.10 made two keyed lines with
// one headline two lines in the feed; the alert lane still matched an alert by its headline alone. In a party of three or four,
// a second teammate going down said TEAMMATE DOWN under his own key (tmdown and his seat) while the first one's alert showed, and
// it refreshed that alert in place: the detail became REVIVE the second name and the first man's alert was gone while he still
// lay there. Now an alert whose key differs from the one showing is a new alert, so the crit takes the slot and the first goes
// back to the alert queue with its hold, as any displaced held alert does (tr3fixa), and returns when the slot is free. The same
// key or no key behaves exactly as before.
function alertSay(m,k,o){
'@

SubRx @'
  if(a&&(a.m===m||(key&&a.key===key))){   // the same line, or the same key: refreshed in place, with no new fade and no new start
'@ @'
  if(a&&((a.m===m&&!msgDiffKey(a.key,key))||(key&&a.key===key))){   // the same line, or the same key: refreshed in place, with no new fade and no new start   // v23.xx (tr9fixo): two keyed alerts with one headline are two alerts
'@

SubRx @'
  if(a&&a.m!==m&&(now-a.at<0.6||alertHeld(a)||(a.T>1.0&&!a.hold)))   // v22.xx (tr3fixa): it goes back to the queue with the life it had left
'@ @'
  if(a&&(a.m!==m||msgDiffKey(a.key,(o&&o.key)||''))&&(now-a.at<0.6||alertHeld(a)||(a.T>1.0&&!a.hold)))   // v22.xx (tr3fixa): it goes back to the queue with the life it had left   // v23.xx (tr9fixo): two keyed alerts with one headline are two alerts
'@

SubRx @'
function alertQDrop(m,key){ var q=G.alertQ, i; if(!q) return; for(i=q.length-1;i>=0;i--) if(q[i].m===m||(key&&q[i].key===key)) q.splice(i,1); }
'@ @'
function alertQDrop(m,key){ var q=G.alertQ, i; if(!q) return; for(i=q.length-1;i>=0;i--) if((q[i].m===m&&!msgDiffKey(q[i].key,key))||(key&&q[i].key===key)) q.splice(i,1); }   // v23.xx (tr9fixo): two keyed alerts with one headline are two alerts
'@

SubRx @'
  for(i=0;i<q.length;i++) if(q[i].m===m||(key&&q[i].key===key)){ q[i].m=m; q[i].k=k; q[i].o=o||null; q[i].key=key; return; }
'@ @'
  for(i=0;i<q.length;i++) if((q[i].m===m&&!msgDiffKey(q[i].key,key))||(key&&q[i].key===key)){ q[i].m=m; q[i].k=k; q[i].o=o||null; q[i].key=key; return; }   // v23.xx (tr9fixo): two keyed alerts with one headline are two alerts
'@

SubRx @'
var VER='23.14';
'@ @'
var VER='23.15';
'@

$pat = "(?m)^  now:'v23\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.15: With two teammates down, each one keeps a TEAMMATE DOWN alert. Check 23.15 fails on v23.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
