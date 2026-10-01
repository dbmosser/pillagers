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

# A TEAMMATE WHO LINKS WHILE THE HOST IS UP TOP CAN DROP IN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netOnMsg0(peer,data){
'@ @'
// v17.53, drop-in after a window comes back: A TEAMMATE WHO LINKS WHILE THE HOST IS UP TOP IS TOLD SO. The raid word goes out
// once, when the host ascends, so a window that linked later (player 2 opened late, or his window was closed and opened again)
// never heard the host was up: no JOIN THE RAID IN PROGRESS, and the lift said only the host can start the raid. The welcome
// now carries the seed of the raid the host is in (0 when it is not), and the teammate keeps it as the raid word would.
function netWelcomeUp(){ return (NET.upWord&&typeof G!=='undefined'&&G&&!G.over&&!G.sim&&typeof NET.upWord.seed==='number')?(NET.upWord.seed>>>0):0; }function netOnMsg0(peer,data){
'@

SubRx @'
      netSend(peer,{t:'welcome',you:seat,roster:NET.roster,ver:VER});
'@ @'
      netSend(peer,{t:'welcome',you:seat,roster:NET.roster,ver:VER,up:netWelcomeUp()});   // v17.53: and the raid the host is in, for a teammate who links late
'@

SubRx @'
      NET.reply=''; NET.err=''; NET.status='You are in the party hosted by '+(hn||'your host')+'.';
'@ @'
      NET.reply=''; NET.err=''; NET.status='You are in the party hosted by '+(hn||'your host')+'.';
      if(typeof m.up==='number'&&m.up>0){ NET.hostSeed=m.up>>>0; NET.status+=' They are in a raid now: go up at the lift to join it.'; }   // v17.53: a teammate who links late can drop in
'@

SubRx @'
var VER='17.52';
'@ @'
var VER='17.53';
'@

$pat = "(?m)^  now:'v17\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.53: Drop-in after a window comes back: if player 2 links while you are up top (his window was closed, or opened late), he is told you are in a raid and can join it from the lift. Check 17.53 fails on v17.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
