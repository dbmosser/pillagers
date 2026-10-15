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

# SETTINGS TEXT IN ONE VOICE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
hint:'THE WORLD ONLY. HUD AND TEXT STAY SHARP. LOWER RUNS FASTER.'
'@ @'
hint:'The world only. HUD and text stay sharp. Lower runs faster.'
'@

SubRx @'
hint:'HIGH: LAMPS CAST SHADOWS. STANDARD: LAMPS, NO SHADOWS. CLASSIC: THE ORIGINAL LOOK.'
'@ @'
hint:'High: lamps cast shadows. Standard: lamps, no shadows. Classic: the original look.'
'@

SubRx @'
hint:'BLOOM AND COLOUR GRADE. OFF RUNS FASTER.'
'@ @'
hint:'Bloom and colour grade. Off runs faster.'
'@

SubRx @'
hint:'SHAKE, HIT PAUSE, HIT FLASH, BLOOM AND GRAIN.'
'@ @'
hint:'Shake, hit pause, hit flash, bloom and grain.'
'@

SubRx @'
hint:'LARGE FOR TV: BIGGER RAID TEXT FOR A SCREEN ACROSS THE ROOM.'
'@ @'
hint:'Large for TV: bigger raid text for a screen across the room.'
'@

SubRx @'
hint:'THE STREET AROUND YOU, TOP RIGHT IN A RAID.'
'@ @'
hint:'The street around you, top right in a raid.'
'@

SubRx @'
hint:'MENU CLICKS AND HUD PINGS: PICKUPS, HIT TICKS AND THE CLOCK. ON TOP OF EFFECTS VOLUME.'
'@ @'
hint:'Menu clicks and HUD pings: pickups, hit ticks and the clock. On top of effects volume.'
'@

SubRx @'
hint:'YOUR STEPS AND THE STEPS YOU HEAR. LOWER IS QUIETER FEET ALL ROUND.'
'@ @'
hint:'Your steps and the steps you hear. Lower is quieter feet all round.'
'@

SubRx @'
hint:'ONE CHANNEL FOR EVERYTHING, NO LEFT OR RIGHT. FOR ONE EAR OR ONE SPEAKER.'
'@ @'
hint:'One channel for everything, no left or right. For one ear or one speaker.'
'@

SubRx @'
hint:'HOLD: AIM WHILE THE BUTTON IS DOWN. TOGGLE: PRESS ONCE TO AIM, AGAIN TO STOP.'
'@ @'
hint:'Hold: aim while the button is down. Toggle: press once to aim, again to stop.'
'@

SubRx @'
hint:'TOGGLE: ONE PRESS CROUCHES, THE NEXT STANDS. HOLD: CROUCHED ONLY WHILE THE KEY IS DOWN. KEYBOARD ONLY.'
'@ @'
hint:'Toggle: one press crouches, the next stands. Hold: crouched only while the key is down. Keyboard only.'
'@

SubRx @'
hint:'HOLD: RUN WHILE THE KEY IS DOWN. TOGGLE: PRESS ONCE TO RUN, UNTIL YOU STOP OR TIRE. THE PAD STICK CLICK TOO.'
'@ @'
hint:'Hold: run while the key is down. Toggle: press once to run, until you stop or tire. The pad stick click too.'
'@

SubRx @'
hint:'HOW FAR THE AIM TURNS FOR A MOVE OF THE MOUSE. 100% IS THE CURSOR AS IT IS. NOT WHILE THE BACKPACK, THE MAP OR THE WHEEL IS OPEN.'
'@ @'
hint:'How far the aim turns for a move of the mouse. 100% is the cursor as it is. Not while the backpack, the map or the wheel is open.'
'@

SubRx @'
hint:'THE SAME, WHILE YOU AIM DOWN SIGHTS. LOWER IS STEADIER.'
'@ @'
hint:'The same, while you aim down sights. Lower is steadier.'
'@

SubRx @'
hint:'THE TRIGGER ON AN EMPTY MAGAZINE RELOADS IT. OFF: IT ONLY CLICKS UNTIL YOU PRESS RELOAD.'
'@ @'
hint:'The trigger on an empty magazine reloads it. Off: it only clicks until you press reload.'
'@

SubRx @'
hint:'A SOLO RAID PAUSES WHEN YOU SWITCH AWAY. NEVER IN A PARTY.'
'@ @'
hint:'A solo raid pauses when you switch away. Never in a party.'
'@

SubRx @'
hint:'HOW HARD THE PICTURE SHAKES: BLASTS, HEAVY HITS AND THE WARDEN. OFF HOLDS IT STILL.'
'@ @'
hint:'How hard the picture shakes: blasts, heavy hits and the warden. Off holds it still.'
'@

SubRx @'
hint:'LIFTS OR SINKS THE SHADOWS OF THE WORLD. NIGHT RAIDS ARE DARK ON PURPOSE.'
'@ @'
hint:'Lifts or sinks the shadows of the world. Night raids are dark on purpose.'
'@

SubRx @'
hint:'THE FRAMES EACH SECOND, SMALL, IN THE TOP LEFT CORNER.'
'@ @'
hint:'The frames each second, small, in the top left corner.'
'@

SubRx @'
hint:'THE NUMBERS THAT FLOAT OFF A TARGET WHEN YOU HIT IT, AND OFF YOU WHEN YOU ARE HIT.'
'@ @'
hint:'The numbers that float off a target when you hit it, and off you when you are hit.'
'@

SubRx @'
hint:'THE SHAPE: CROSS, DOT, CIRCLE OR T. THE MAGAZINE AND RELOAD RINGS STAY AROUND IT.'
'@ @'
hint:'The shape: cross, dot, circle or t. The magazine and reload rings stay around it.'
'@

SubRx @'
hint:'WHITE IS THE USUAL, AMBER WHILE AIMING. THE OTHERS HOLD ONE COLOUR FOR BOTH.'
'@ @'
hint:'White is the usual, amber while aiming. The others hold one colour for both.'
'@

SubRx @'
hint:'HOW BIG THE CROSSHAIR IS, WITH THE RINGS ROUND IT.'
'@ @'
hint:'How big the crosshair is, with the rings round it.'
'@

SubRx @'
hint:'HOW BIG THE MINIMAP IS, TOP RIGHT. THE PANELS UNDER IT MOVE DOWN.'
'@ @'
hint:'How big the minimap is, top right. The panels under it move down.'
'@

SubRx @'
hint:'HOW MUCH STREET IT SHOWS. CLOSE IS A TIGHT VIEW, WIDE IS THE LIE OF THE LAND.'
'@ @'
hint:'How much street it shows. Close is a tight view, wide is the lie of the land.'
'@

SubRx @'
hint:'RECOLOURS RARITY AND THE ENEMY AND ALLY MARKS: DEUTERANOPIA AND PROTANOPIA (RED-GREEN), TRITANOPIA (BLUE-YELLOW).'
'@ @'
hint:'Recolours rarity and the enemy and ally marks: deuteranopia and protanopia (red-green), tritanopia (blue-yellow).'
'@

SubRx @'
hint:'TONES DOWN THE BRIGHT FLASHES: BLASTS, MUZZLE FLASHES, LIGHTNING AND FORGE SPARKS.'
'@ @'
hint:'Tones down the bright flashes: blasts, muzzle flashes, lightning and forge sparks.'
'@

SubRx @'
hint:'HOW FAR A STICK MOVES TO REACH FULL TILT: WALKING AND AIMING. HIGHER IS QUICKER.'
'@ @'
hint:'How far a stick moves to reach full tilt: walking and aiming. Higher is quicker.'
'@

SubRx @'
hint:'HOW FAR A STICK MOVES BEFORE THE GAME SEES IT. RAISE IT IF A WORN STICK DRIFTS.'
'@ @'
hint:'How far a stick moves before the game sees it. Raise it if a worn stick drifts.'
'@

SubRx @'
hint:'THE AIM STICK UP BECOMES DOWN. THE ITEM WHEEL AND THE MAP KEEP THEIR OWN WAY.'
'@ @'
hint:'The aim stick up becomes down. The item wheel and the map keep their own way.'
'@

SubRx @'
hint:'HOW HARD THE PAD BUZZES WHEN CONTROLLER RUMBLE IS ON.'
'@ @'
hint:'How hard the pad buzzes when controller rumble is on.'
'@

SubRx @'
var VER='27.54';
'@ @'
var VER='27.55';
'@

$pat = "(?m)^  now:'v27\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.55: Every Settings row description is in sentence case. Check 27.55 fails on v27.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
