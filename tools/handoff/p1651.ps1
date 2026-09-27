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

# THE PAUSE BOX SHUTS WHEN A CO-OP RAID ENDS UNDER IT (stability pass before his co-op session, 2026-09-27).

SubRx @'
  // already guards its own write with if(G), so nothing below needs a raid.
  if(G&&G.over) return;
'@ @'
  // already guards its own write with if(G), so nothing below needs a raid.
  // v16.51, stability: an ended raid refuses only an OPENING. In a shared raid the box does not stop the world, so a teammate
  // who pressed Start while downed could bleed out (or the host leave, or the clock run out) with it open; endRaid then asked
  // it to shut and this line refused, leaving the box over the outcome card, and a controller drove the box, not the card.
  if(on&&G&&G.over) return;
'@

SubRx @'
var VER='16.50';
'@ @'
var VER='16.51';
'@

$pat = "(?m)^  now:'v16\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.51: THE PAUSE BOX SHUTS WHEN A CO-OP RAID ENDS UNDER IT. Stability pass before a co-op session. In a shared raid the pause box does not stop the world, so a teammate could bleed out, or the host leave, with it open. The raid end asked the box to shut and it refused, so it sat over the end of raid card and a controller could not reach the card. An ended raid now refuses only an opening of the box. Check 16.51 fails on v16.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
