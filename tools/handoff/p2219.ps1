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

# Y ON A TRADE OFFER OPENS NOTHING ELSE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(pressed(3)&&!PAD.prev[3]&&typeof netHubGiftKey==='function'&&NET.hg&&NET.hg.in&&!NET.hg.in.yes){ netHubGiftKey(); }   // v18.05: Y takes an offer on the floor
    padHold('KeyF',pressed(3));
'@ @'
    // v22.19, from the whole-game bug hunt of 2026-10-08 (K30): THE Y THAT TAKES AN OFFER IS SPENT ON IT, as T is on the keyboard
    // (v18.05). The same press went on to hold the station Y key, so a controller player who took an offer at the lift, the shop
    // counter or the Mainframe also opened PARTY, HIRE or RACKS over it in the same frame. The station Y now waits until Y is let
    // go; with no offer waiting, or one that has run out, Y works the station as before.
    if(pressed(3)&&!PAD.prev[3]&&typeof netHubGiftKey==='function'&&NET.hg&&NET.hg.in&&!NET.hg.in.yes&&netHubGiftKey()) PAD.yGift=1;   // v18.05: Y takes an offer on the floor
    if(!pressed(3)) PAD.yGift=0;
    padHold('KeyF',pressed(3)&&!PAD.yGift);
'@

SubRx @'
  PAD.xWas=false;
  if(PAD.held){ for(var c in PAD.held){ if(PAD.held[c]) keys[c]=false; } PAD.held={}; }
'@ @'
  PAD.xWas=false; PAD.yGift=0;   // v22.19 (K30): and the Y spent on a trade offer, so a panel in between never eats the next Y on the floor
  if(PAD.held){ for(var c in PAD.held){ if(PAD.held[c]) keys[c]=false; } PAD.held={}; }
'@

SubRx @'
var VER='22.18';
'@ @'
var VER='22.19';
'@

$pat = "(?m)^  now:'v22\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.19: Taking a trade offer with Y on the controller no longer opens the station window behind it. Check 22.19 fails on v22.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
