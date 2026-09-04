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

# ============ THE QUESTION I LEFT OPEN AT v11.07, ANSWERED, AND THE ANSWER IS
# ============ ABOUT THE INSTRUMENT RATHER THAN THE GAME.
# ============
# ============ At v11.07 I fixed the crawler that could not see a hidden man it
# ============ was touching, and said plainly that I had not measured what it does
# ============ to the bot's extract rate. Then I tried to measure it and could
# ============ not: one paired seed takes about thirty five seconds here, so the
# ============ 320 pairs the standard asks for is several hours, and a single pair
# ============ outlives the window I can drive a call in.
# ============
# ============ SO I MEASURED THE THING THAT DECIDES THE ANSWER INSTEAD. The bug
# ============ only fires when concealment drops far enough that a crawler's
# ============ sight, 100 units times concealment, falls under its own 36 unit
# ============ reach. That needs concealment below about 0.36.
# ============
# ============ MEASURED over three seeded bot raids, 1,647 steps: crawlers were
# ============ inside biting distance of the bot for 693 frames and ZERO of those
# ============ frames were in the blind band. Over 300 frames the bot's own
# ============ concealment ran 0.40 at its lowest, 1.00 at its highest, 0.884 on
# ============ average, and it crouched in NOT ONE FRAME.
# ============
# ============ THE BOT NEVER GETS THERE. It cannot exhibit the bug, which is why
# ============ the seven pairs that did run showed no difference and why three
# ============ hundred more would have shown none either. The bug only ever
# ============ reached a HUMAN who hides, which is exactly why he hit it twice and
# ============ no number I have ever run showed it.
# ============
# ============ THIS BUILD CHANGES NO BEHAVIOUR. It writes that limit down where it
# ============ cannot be forgotten, because the mistake it prevents is one I was
# ============ one sentence away from making: quoting a sim number as if it
# ============ covered how he actually plays.
SubRx @'
var VER='11.09';
'@ @'
var VER='11.10';
'@
SubRx @'
  now:'v11.09: the menus, measured. v10.95 put the canvas on one font and left the DOM as my word for it. Every element in the document is now read for the family it actually computes to, and they all come back the game font. Nothing needed changing, so nothing was: the only two exceptions are the game name itself and the dev text editor, both deliberate. A check holds it there from now on.',
'@ @'
  now:'v11.10: the crawler question from v11.07, answered. The bot cannot show that bug: over 1,647 simulated steps crawlers were inside biting distance for 693 frames and none of them were in the blind band, because the bot never crouches and its concealment never drops below 0.40 while the bug needs 0.36. It only ever reached a human who hides, which is why you hit it twice and no number I have run ever showed it. Nothing in the game changed here.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'NOTHING IN THE GAME CHANGED IN THIS BUILD. It records a limit of the robot that tests it: the robot never crouches and never hides, so no number it has ever produced describes playing carefully. The crawler bug fixed two builds ago could only ever have reached a person.',
'@
SubRx @'
var WHATSNEW_VER='11.09';
'@ @'
var WHATSNEW_VER='11.10';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
