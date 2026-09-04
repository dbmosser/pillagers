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

# ============ HIS NOTE 21: SOMETIMES A SHOT MAKES A RED RING AND SOMETIMES NOT.
# ============
# ============ "sometimes my shots make a red noise circle when they hit
# ============ something, sometimes they don't --whats up with that?", 2026-09-04.
# ============
# ============ MEASURED, one pistol round into one sentry at 160 units, thirty
# ============ frames each, with the target's own return fire held off so the only
# ============ rings are the ones his shot caused:
# ============   idle machine that survives   one ring, robot MOVING
# ============   awake machine that survives  one ring, robot MOVING
# ============   machine killed outright      NO RING AT ALL
# ============
# ============ SO THE RING IS NOT HIS HIT. A landed round pings nothing. The ring
# ============ that follows is the thing he hit taking a STEP, in the pale red of
# ============ a machine moving; kill it outright and it never steps, so there is
# ============ nothing. His own noises have drawn no ring since v5.31, on the
# ============ grounds that he knows what he just did.
# ============
# ============ AND THE ONE THING THAT IS SUPPOSED TO TEACH HIM THAT IS WRONG IN
# ============ TWO WAYS. The sound key beside the legend, whose whole job is the
# ============ colour language, carries:
# ============   a cream swatch labelled "you", for a ring that CANNOT EXIST,
# ============     because ping refuses to draw the player's own noises
# ============   #e65100 for pillager firing, an ORANGE, when the game has drawn
# ============     it in #ff3b30 since v9.63, changed on his own word: "RED"
# ============ So the legend taught him a colour that never appears and showed the
# ============ wrong swatch for one that does.
# ============
# ============ THE FIX: the key is BUILT FROM the colour table rather than typed
# ============ out beside it, so a swatch can never drift from what is drawn
# ============ again; the impossible entry is replaced by the rule that actually
# ============ explains his question, and the silence is named too, because "no
# ============ ring" is information: it means nothing out there made a sound.
SubRx @'
var SOUNDKEY=[
  ['#ff8a80','robot moving'],['#c62828','robot firing'],
  ['#ffb74d','pillager moving'],['#e65100','pillager firing'],
  ['#FFF6DC','you'],['#ffd54f','environment']
];
'@ @'
// v11.08, HIS NOTE 21: BUILT FROM THE COLOUR TABLE, never typed beside it. Two of
// the six entries here were wrong: a cream swatch labelled "you", for a ring that
// cannot exist because ping has refused to draw his own noises since v5.31, and
// an orange for pillager firing, which the game has drawn red since v9.63 on his
// own word. A key that teaches the wrong colour is worse than no key.
var SOUNDKEY=[
  [SNDCOL.robot.move, 'machine moving'],
  [SNDCOL.robot.fire, 'machine firing'],
  [SNDCOL.raider.move,'pillager moving'],
  [SNDCOL.raider.fire,'pillager firing'],
  [SNDCOL.env.move,   'the world'],
  // His question, answered where it is asked. The ring is never his own noise,
  // and a thing he kills outright never takes the step that would have made one.
  [SNDCOL.env.move,   'never your own']
];
'@

SubRx @'
var VER='11.07';
'@ @'
var VER='11.08';
'@
SubRx @'
  now:'v11.07: crawlers not attacking, your note, asked twice. Reproduced: a crawler 30 units away with a bite that reaches 36, facing you, bites for 65 damage in three seconds at concealment 0.35 and does NOTHING at 0.25 and below. Its eyes shrink with your concealment and its reach does not, so there is a band where it can bite and cannot see, and the bite only exists inside chase. Its sight now has a floor equal to its own reach: you cannot hide from something that is touching you.',
'@ @'
  now:'v11.08: the red ring on a hit, your question. Measured: the ring is NOT your hit. A landed round pings nothing; the ring that follows is the thing you hit taking a step, and a target killed outright never steps, so there is none. The sound key that is meant to teach that was wrong twice over, with a swatch for a ring that cannot exist and the pre-v9.63 orange for pillager fire. It is built from the colour table now.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE NOISE RING IS NEVER YOUR OWN. A ring after your shot is the thing you hit taking a step, which is why a target you kill outright makes none. The sound key in the legend now reads its swatches from the colours the game actually draws, and it had two of them wrong.',
'@
SubRx @'
var WHATSNEW_VER='11.07';
'@ @'
var WHATSNEW_VER='11.08';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
