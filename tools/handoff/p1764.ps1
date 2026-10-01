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

# A LATE TEAMMATE IS CHARGED FOR THE TIME HE PLAYED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function abandonRepCost(el){ return Math.min(400,100+Math.round(el/10)); }
'@ @'
// v17.64: the time THIS player has been in the raid. A teammate who joined a raid in progress takes the host clock (netLateApply),
// so elapsed() counts the minutes before he came up; his run length and the XP an abandon costs him count from when he joined.
function runElapsed(){ return Math.max(0,elapsed()-((typeof G!=='undefined'&&G&&G.lateEl)||0)); }function abandonRepCost(el){ return Math.min(400,100+Math.round(el/10)); }
'@

SubRx @'
    var _el=(G&&!G.over)?elapsed():0;
'@ @'
    var _el=(G&&!G.over)?runElapsed():0;   // v17.64: from when this player joined
'@

SubRx @'
    var _rc=Math.min(abandonRepCost(elapsed()),(P.xp||0));
'@ @'
    var _rc=Math.min(abandonRepCost(runElapsed()),(P.xp||0));   // v17.64: from when this player joined
'@

SubRx @'
    dur:Math.round(elapsed()),
'@ @'
    dur:Math.round(runElapsed()),   // v17.64: from when this player joined
'@

SubRx @'
  if(typeof L.left==='number'&&isFinite(L.left)) G.timeLeft=L.left;
'@ @'
  if(typeof L.left==='number'&&isFinite(L.left)) G.timeLeft=L.left;
  try{ G.lateEl=elapsed(); }catch(_le){}   // v17.64: this player came up now; his own run counts from here
'@

SubRx @'
var VER='17.63';
'@ @'
var VER='17.64';
'@

$pat = "(?m)^  now:'v17\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.64: JOIN THE RAID IN PROGRESS: the abandon XP cost and the run length count from when you joined, not from when your host went up. Check 17.64 fails on v17.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
