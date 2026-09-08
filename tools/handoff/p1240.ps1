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

# FROM THE 2026-09-07 READ-ONLY AUDIT (merc-loots-hostiles), specced from the
# source and attacked by a skeptic before a line was written.
#
# The pickup branch asks two things: is this man a pillager, and is he in my
# crew. Neither question asks which side either man is on. The merc you hire is
# built by the same maker as every other pillager and rolls a crew there out of
# two, so he shares a number with about half the map. Told to loot on his own he
# reaches this branch, and a downed HOSTILE inside 760 units carrying that
# number read as one of his own: he left your job, knelt over the man who had
# been shooting at you, and put him back on his feet.
SubRx @'
          if(RD===e||RD.kind!=='raider'||!RD.downed) continue;
          if(RD.crew!==e.crew) continue;
'@ @'
          if(RD===e||RD.kind!=='raider'||!RD.downed) continue;
          // v12.40, audit merc-loots-hostiles: A CREW NUMBER IS NOT A SIDE. The man
          // you hired is built by mkRaider like every other pillager and rolls a
          // crew there (raiderCrews 2), so he shares a number with about half the
          // map. Told to loot on his own he reaches this branch, and a downed
          // HOSTILE inside 760 carrying that number read as one of his own: he
          // left your job, knelt over the man who had been shooting at you and put
          // him back on his feet on 40 percent health. The test below is the one
          // mercEngage already uses to decide who is his business, so the pillager
          // he would shoot is the pillager he will not pick up. A man who has
          // thrown in with you, or who is passive, is still picked up, and no
          // other reviver in the game has his crew rule changed.
          if(e.merc&&!RD.merc&&RD.hostile!==false&&!RD.friendlyPC) continue;
          if(RD.crew!==e.crew) continue;
'@

# NEW IN.
SubRx @'
  'A GUN YOU DIED WITH IS NOT COMING UP WITH YOU. A death that took your sidearm left gun 2 still naming it, and the last screen before the lift told you it was going up in your hands. The slot is emptied now, and that screen makes the same test the deploy makes.',
'@ @'
  'A GUN YOU DIED WITH IS NOT COMING UP WITH YOU. A death that took your sidearm left gun 2 still naming it, and the last screen before the lift told you it was going up in your hands. The slot is emptied now, and that screen makes the same test the deploy makes.',
  'THE MAN YOU HIRED STOPS PICKING UP THE MEN SHOOTING AT YOU. A crew number is not a side: your hire shares one with about half the map, so a downed hostile carrying that number used to be worth breaking off your job for. He still picks up anyone who has thrown in with you.',
'@

# STAMPS.
SubRx @'
var VER='12.39';
'@ @'
var VER='12.40';
'@
SubRx @'
var WHATSNEW_VER='12.39';
'@ @'
var WHATSNEW_VER='12.40';
'@
$cnt=([regex]::Matches($s,"now:'v12\.39:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.39 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.39:[^']*'",{ param($m) "now:'v12.40: 2026-09-07 audit (merc-loots-hostiles). The pickup branch asks two things, is this man a pillager and is he in my crew, and neither question asks which side either man is on. The merc you hire is built by the same maker as every other pillager and rolls a crew there out of two, so he shares a number with about half the map. Told to loot on his own he reaches this branch, and a downed HOSTILE inside 760 units carrying that number read as one of his own: he left your job, knelt over the man who had been shooting at you, and put him back on his feet on 40 percent health. One guard between the two tests, so it reads as the side question that has to be answered before the crew question is even asked, and it is the same test mercEngage already uses to decide who is his business: the pillager he would shoot is the pillager he will not pick up. A man who has thrown in with you, or who is passive, is still picked up, and no other reviver in the game has his crew rule changed. Check 12.40 stages a reviver and a downed man twenty units apart on a crew number no raid can roll, a thousand units from the player so nothing else can reach them, and runs three arms: the hire and a downed hostile, an ordinary crew picking its own up, and the hire and a man who has thrown in with you; fails on v12.39.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
