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

# ============ HIS NOTE, THE OTHER HALF: THE HUM ALSO SURVIVES A PAUSE.
# ============
# ============ v10.85 cut the ambient bed when a raid ENDS. His note said "like
# ============ after you die, etc", and this is the etc, and it is the one most
# ============ people will meet: the entire raid update, tickAmbience included,
# ============ sits inside a branch gated on !G.paused. Open the pause box and
# ============ nothing writes those gains again, so the bed holds its last level
# ============ for as long as the menu is open. Pausing happens many times a
# ============ raid; dying happens once.
# ============
# ============ AND IT HOLDS AT WHATEVER THE ROOM WAS. The level follows the
# ============ nearest hunting body, so pausing while something is on you leaves
# ============ the loudest version of the bed running under a still menu.
# ============
# ============ THE FIX: duck on the frame the pause opens, once, not every frame,
# ============ and let tickAmbience bring it back on its own when play resumes.
# ============ It already ramps toward its live target with a 0.45 time constant,
# ============ so the room comes back in about a second rather than snapping on.
# ============ NO DIAL MOVES. Nothing here changes a number in the game.
SubRx @'
  if(!G.paused&&!G.over&&G.deathBeat!==undefined&&G.deathBeat!==null){
'@ @'
  // v10.86, HIS NOTE: the raid update below is gated on !G.paused and
  // tickAmbience lives inside it, so a pause froze the ambient bed at its last
  // level and it hummed through the whole menu. Ducked once on the frame the
  // pause opens, and tickAmbience ramps it back by itself on resume.
  if(G.paused&&!G.over){ if(!G._ambDuck){ G._ambDuck=1; try{ ambienceOff(); }catch(_ap){} } }
  else if(G._ambDuck){ G._ambDuck=0; }
  if(!G.paused&&!G.over&&G.deathBeat!==undefined&&G.deathBeat!==null){
'@

SubRx @'
var VER='10.85';
'@ @'
var VER='10.86';
'@
SubRx @'
  now:'v10.85: your note about hums that last way too long. The ambient bed is five voices that are never stopped on purpose and silenced by turning their gain down instead, and the only thing that turned it down ran inside the raid loop. End a raid and the gain froze where it stood, loudest if something was on top of you when you died.',
'@ @'
  now:'v10.86: the same hum, the way most people will actually meet it. The whole raid update sits behind a not-paused guard and the ambient bed is turned down inside it, so opening the pause box froze the bed at its last level and it hummed under the menu. Pausing happens many times a raid; dying happens once.',
'@
SubRx @'
  'THE HUM STOPS WHEN THE RAID DOES.
'@ @'
  'AND THE HUM STOPS WHEN YOU PAUSE. Same fault as the one below, met the common way: the room tone is turned down inside the part of the frame that a pause switches off, so it used to hold its level under the pause menu. It ducks now and comes back when you resume.',
  'THE HUM STOPS WHEN THE RAID DOES.
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
