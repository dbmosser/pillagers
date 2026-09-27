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

# PLAYER 2 STOPS HEARING THE ENEMIES ONCE THE HOST LEAVES HIS RUN CARD (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).

SubRx @'
    if(NET.specAcc>=NET_HUB_STEP){ NET.specAcc=0; NET.upN++; netEntsTick(); netContTick(); if(NET.upN%5===0) netWorldSend(); }
'@ @'
    if(NET.specAcc>=NET_HUB_STEP){ NET.specAcc=0; NET.upN++; netEntsTick(); netContTick(); if(NET.upN%5===0) netWorldSend(); }
    // v16.67, stability: every sound the kept raid makes is queued for the party (netFxNoise), and the queue went out only in
    // netFxStep, which runs in a raid frame. Once the host left his run card for the Undercroft no raid frame ran, so a teammate
    // still up top stopped hearing the enemies and lost their red sound rings. With the host off the kept raid the queue goes
    // out from here, in the same word on the same beat; on the run card the raid frame still sends it, so it never goes twice.
    if(keep!==S){ NET.fxAcc=(NET.fxAcc||0)+dt; if(NET.fxAcc>=NET_HUB_STEP&&NET.fxQ&&NET.fxQ.length){ NET.fxAcc=0; var fm={t:'fx',k:'n',s:NET.seat,n:NET.fxQ.slice(0,16)}; NET.fxQ=[]; for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSendFast(NET.peers[i],fm); } }
'@

SubRx @'
var VER='16.66';
'@ @'
var VER='16.67';
'@

$pat = "(?m)^  now:'v16\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.67: PLAYER 2 KEEPS HEARING THE ENEMIES AFTER THE HOST LEAVES HIS RUN CARD. Stability pass before a co-op session. Every sound the raid makes reaches the party in a word the host sends from his raid frame, and once the host left his run card for the Undercroft while his teammate was still up top, no raid frame ran: the teammate stopped hearing the enemies and lost their red sound rings. The raid the host keeps for the party now sends that word itself when he is not looking at it. Check 16.67 fails on v16.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
