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

# ============ HIS NOTE 18, THE HALF I LEFT UNVERIFIED: THE MENUS.
# ============
# ============ v10.95 put the canvas on one family and its own Not verified line
# ============ said: "the DOM, which this check does not trace, is set in the game
# ============ font by the stylesheet but was not measured word by word".
# ============ His instruction was "use the entire font across the entire game",
# ============ and half of the game is menus.
# ============
# ============ THIS BUILD CHANGES NOTHING IN THE GAME. The sweep found nothing to
# ============ change, which is a result and is reported as one. What it adds is
# ============ the measurement, so the claim stops being my word for it.
SubRx @'
var VER='11.08';
'@ @'
var VER='11.09';
'@
SubRx @'
  now:'v11.08: the red ring on a hit, your question. Measured: the ring is NOT your hit. A landed round pings nothing; the ring that follows is the thing you hit taking a step, and a target killed outright never steps, so there is none. The sound key that is meant to teach that was wrong twice over, with a swatch for a ring that cannot exist and the pre-v9.63 orange for pillager fire. It is built from the colour table now.',
'@ @'
  now:'v11.09: the menus, measured. v10.95 put the canvas on one font and left the DOM as my word for it. Every element in the document is now read for the family it actually computes to, and they all come back the game font. Nothing needed changing, so nothing was: the only two exceptions are the game name itself and the dev text editor, both deliberate. A check holds it there from now on.',
'@
SubRx @'
var WHATSNEW_VER='11.08';
'@ @'
var WHATSNEW_VER='11.09';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
