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

# v10.60, fourth part, and it is the corpus catching something that matters more
# than the build it interrupted. The what-is-new card a friend reads on the way
# in was written at v10.45 and the game is at v10.60, fifteen builds of news
# missing, four of them things he asked for tonight. With an alpha going out to
# friends in three days that card IS the game's introduction. Five new lines at
# the top, and the card's own version moves to this build.
SubRx @'
var WHATSNEW_VER='10.45';
'@ @'
var WHATSNEW_VER='10.60';
'@
SubRx @'
  'A NEW CHARACTER GETS A WELCOME PACK: a green gun and a blue one, heals, plates and grenades, offered once, the first time down.',
'@ @'
  'A NEW CHARACTER GETS A WELCOME PACK: a green gun and a blue one, heals, plates and grenades, offered once, the first time down.',
  'FULL-BODY OUTFITS. A new rack at the top of the Depot, above everything else: the Skeleton, the Machine, the Trooper, the Android, the Tomb Explorer, the Baller and the Street Poet. An outfit overrules every other rack; Own Clothes puts them back in charge.',
  'EVERY GUN HAS ITS OWN VOICE. Sixteen guns used to share eleven; the Magnum and the Longshot borrowed the rifle. Each one now has its own crack, its own weight and, if it earns one, the room answering. Reloading, the bolt going home and an empty gun all make a sound.',
  'FOOTSTEPS ARE HEEL AND SOLE, left and right in your ears, and the ground says what it is: grit on stone, a creaking board, ringing plate, a rustle in leaves, a splash and then a drip. The machines and the pillagers walk on the same five surfaces you do.',
  'WALLS ARE SOLID. Nothing goes see-through when you stand behind it, and in the Undercroft nobody can stand inside the part of a wall that is painted, so the people down there stop catching on the counters.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
