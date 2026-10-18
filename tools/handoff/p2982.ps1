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

# Hub windows ease in too (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
scope:'#title,#partymodal,#pausebox,#outcome,#settingsmodal,#keysmodal',ring:null
'@ @'
scope:'#title,#partymodal,#pausebox,#outcome,#settingsmodal,#keysmodal,#tradermodal,#gamblemodal,#barmodal,#appearmodal,#trophymodal,#codexmodal,#lbmodal,#wnmodal,#sectormodal,#stagemodal,#carrymodal,#cratemodal,#opmodal,#welcomemodal,#termsmodal',ring:null
'@

SubRx @'
['title','partymodal','pausebox','outcome','settingsmodal','keysmodal'].forEach(function(id){ UIM.watch(document.getElementById(id)); });
'@ @'
// v29.82 (cw-uimotion3), UI STEP 2b (his words: "they are just reallly compelling and smooth"): the hub windows (trader, gamble, bar, looks, trophies, codex, board, news, sector, stage, carry, crate, ops, welcome, terms) ease open and shut on the same layer.
['title','partymodal','pausebox','outcome','settingsmodal','keysmodal','tradermodal','gamblemodal','barmodal','appearmodal','trophymodal','codexmodal','lbmodal','wnmodal','sectormodal','stagemodal','carrymodal','cratemodal','opmodal','welcomemodal','termsmodal'].forEach(function(id){ UIM.watch(document.getElementById(id)); });
'@

SubRx @'
var VER='29.81';
'@ @'
var VER='29.82';
'@

$pat = "(?m)^  now:'v29\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.82: The hub windows now ease open and shut. Check 29.82 fails on v29.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
