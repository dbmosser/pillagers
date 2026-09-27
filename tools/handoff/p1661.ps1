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

# PINGING TWICE MARKS DANGER, AS THE CONTROLS LEGEND SAYS (stability pass, 2026-09-27).

SubRx @'
  if(NET.pingAt&&Date.now()-NET.pingAt<500) return null;
  if(G.mapOpen) return netWpFromMap();   // v16.46: a ping on the open map is your map marker, as in Fortnite
  if(NET.pingAt&&Date.now()-NET.pingAt<400){   // v16.46: pressed twice, the last ping becomes DANGER
    if(NET.pingLast&&!NET.pingLast.dg){ NET.pingLast.dg=1; netBroadcast(NET.pingLast); netPingPush(NET.seat,NET.pingLast); }
    return NET.pingLast||null;
  }
'@ @'
  // v16.61, stability (co-op review): the double press is read BEFORE the 0.5 s limit. That limit stood first and answered
  // every press inside 0.5 s with nothing, so the 0.4 s double press the controls legend promises (twice: danger) never came.
  if(!G.mapOpen&&NET.pingAt&&Date.now()-NET.pingAt<400){   // v16.46: pressed twice, the last ping becomes DANGER
    if(NET.pingLast&&!NET.pingLast.dg){ NET.pingLast.dg=1; netBroadcast(NET.pingLast); netPingPush(NET.seat,NET.pingLast); }
    return NET.pingLast||null;
  }
  if(NET.pingAt&&Date.now()-NET.pingAt<500) return null;
  if(G.mapOpen) return netWpFromMap();   // v16.46: a ping on the open map is your map marker, as in Fortnite
'@

SubRx @'
var VER='16.60';
'@ @'
var VER='16.61';
'@

$pat = "(?m)^  now:'v16\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.61: PINGING TWICE MARKS DANGER, AS THE CONTROLS LEGEND SAYS. Stability pass before a co-op session. The legend says a second ping in quick succession marks danger, but a limit of one ping each half second stood in front of it and threw the second press away, so danger never came. The double press is now read first. Check 16.61 fails on v16.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
