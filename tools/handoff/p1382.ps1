$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# COMBAT AND PLAYER STATE AUDIT OF 2026-09-14, finding 3: A BURST'S LATER ROUNDS CAME OUT OF THE GUN
# YOU SWAPPED TO. A Burst Carbine queues its second and third rounds 70 ms apart, and each one
# takes a round from G.player.ammo, which is whatever gun is in hand when it fires. Swap to the
# Magnum inside those 140 ms and three carbine rounds fly while the Magnum pays for two of them:
# the carbine is stowed with 23 of 24 where it fired three, and the Magnum comes up with 4 of 6.
# Bagging or equipping over the carbine mid-burst did the same. The queued round carries the gun
# that fired it, and a round whose gun is no longer in hand does not fire.
SubRx @'
          if(G.player.ammo<=0) continue;
'@ @'
          // v13.82, combat audit: the gun that fired the burst must still be in hand, or its
          // later rounds come out of whatever gun replaced it.
          if(G.player.wep!==BE.wep||G.player.ammo<=0) continue;
'@
SubRx @'
var VER='13.81';
'@ @'
var VER='13.82';
'@

$pat = "(?m)^  now:'v13\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.82: A BURST STOPS WHEN ITS GUN LEAVES YOUR HAND. Combat and player state audit of 2026-09-14, finding 3: a Burst Carbine queues its second and third rounds 70 ms apart and each took a round from whatever gun was in hand, so swapping to the Magnum inside 140 ms fired carbine rounds paid for by the Magnum, stowing the carbine with 23 and the Magnum with 4 of 6. The queued rounds carry the gun that fired them and do not fire once it is out of hand. Check 13.82 fires a burst and swaps at once, requiring the Magnum untouched and the carbine charged one round, with the same burst and no swap spending three as the control; it fails on v13.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
