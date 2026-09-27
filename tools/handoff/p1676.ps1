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

# NO HUM THROUGH A PARTY PAUSE (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).

SubRx @'
  if(G.paused&&!G.over){ if(!G._ambDuck){ G._ambDuck=1; try{ ambienceOff(); }catch(_ap){} } }
  else if(G._ambDuck){ G._ambDuck=0; }
'@ @'
  // v16.76, his order: weird noises when we pause, two-player on one machine. In a shared raid the box does not stop the
  // world until every player is paused (v16.04, v16.20), so this duck landed on the first paused frame while the world and
  // tickAmbience below still ran: the same frame drove the bed straight back up, and when the other player paused too and
  // the world stood still, the flag was already set and nothing cut it. The drone, the room noise, the rain and the dread
  // held their last level through the whole pause in the window that paused first (both windows when they paused together),
  // the hum v10.86 already cut in solo. The duck now lands on the first frame the world actually stands still, and it re-arms
  // whenever the world runs on, so it lands again when the party pauses once more. Solo is unchanged: with no party the world
  // stands still on the first paused frame as before. No player text, no number and no seeded draw moved.
  if(G.paused&&!G.over&&!netPauseLive()){ if(!G._ambDuck){ G._ambDuck=1; try{ ambienceOff(); }catch(_ap){} } }
  else if(G._ambDuck){ G._ambDuck=0; }
'@

SubRx @'
var VER='16.75';
'@ @'
var VER='16.76';
'@

$pat = "(?m)^  now:'v16\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.76: NO HUM THROUGH A PARTY PAUSE. His report during his co-op session: weird noises when we pause. In a shared raid the pause box does not stop the world until every player is paused, and the sound bed was turned down for the pause and written back up on the same frame, over and over, which came out as a hum. The bed now stays down for the whole pause. Check 16.76 fails on v16.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
