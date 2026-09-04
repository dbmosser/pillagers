$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\AUDIT.md'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
- TITLE SCREEN WASTES THE SCREEN. His shot on a wide monitor: the whole thing is
  a narrow column in the middle with empty space either side. It is DOM, so the
  v8.81 canvas HUD scaling does not touch it.
'@ @'
- ~~TITLE SCREEN WASTES THE SCREEN.~~ CLOSED AT v10.73. His shot on a wide
  monitor: the whole thing is a narrow column in the middle with empty space
  either side. Reproduced at 1920x1080: content x=427 to x=1493, so 1,066 of
  1,920 pixels, 56 percent, with 427 empty down each side. The column was capped
  at 820 and the only widening rule was gated on min-aspect-ratio 19/10, an
  ultrawide, so 16/9 missed it by a tenth. Cap follows the viewport now with an
  820 floor: 56 to 81 percent at 1080p, 78 to 81 at 1366x768.
'@

SubRx @'
- FOOTPRINTS THROUGH WALLS. "i can see pillager footprints when i can't see the
  pillager -- intentional? I wanted sound visualization for stuff we couldn't
  see". So: footprint DECALS should be gated on sight; the sound ping is the
  thing that is meant to show through.
'@ @'
- ~~FOOTPRINTS THROUGH WALLS.~~ ALREADY DONE, read at v10.73 and not re-measured:
  both decal draws carry a sight gate, "if((dc.print||dc.ripple)&&!dc.mine&&
  !canSee(...)) continue" and the same on G.prints, with mine bypassing it so
  your own wake is never hidden from you. His words: "i can see pillager
  footprints when i can't see the pillager -- intentional? I wanted sound
  visualization for stuff we couldn't see". The sound ping still shows through,
  which is what he asked for.
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
