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

# B IS ON NO KEY LIST. v13.17 made B back out of whatever is in front, on his
# note, because Escape is not working for him. v13.22 announces it once on the
# what is new card, which a player sees one time and dismisses by walking. The
# key list behind H is the reference he opens when he wants to know what a key
# does, and B was not on it. It was not on it for the hire either: B has cycled a
# hired pillager orders since v3.73 and no legend has ever said so.
#
# THE FULL LIST ONLY. The compact list that shows by default is deliberately tiny,
# on his note to make the legend smaller, and it names only the thirteen keys a
# player presses constantly. B is a key he reaches for when something is in the
# way, which is what the full list is for.
#
# IN THE WORLD GROUP, after P, because B sits with the keys that change what is on
# the screen rather than with movement, combat or gear.
SubRx @'
['WORLD',[['E','search / call for extraction'],['X','search, even on the way out'],['M','map'],['H','cycle this list'],['P','pause']]],
'@ @'
['WORLD',[['E','search / call for extraction'],['X','search, even on the way out'],['M','map'],['H','cycle this list'],['P','pause'],['B','back out of a menu, or order your hire']]],
'@

SubRx @'
var VER='13.22';
'@ @'
var VER='13.23';
'@

$pat = "(?m)^  now:'v13\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.23: B IS ON THE KEY LIST NOW, and it was on none. v13.17 made B back out of whatever is in front, on his note, because Escape is not working for him, and v13.22 announces it once on the what is new card, which a player sees one time and dismisses by walking. The key list behind H is the reference he opens when he wants to know what a key does, and B was not on it; nor had it ever been for the hire, although B has cycled a hired pillager orders since v3.73. The row goes on the FULL list only: the compact list that shows by default is deliberately tiny, on his note to make the legend smaller, and it names the keys a player presses constantly, while B is a key he reaches for when something is in the way, which is what the full list is for. It sits in the WORLD group after P, with the keys that change what is on the screen. WHY THE EXISTING LEGEND CHECK COULD NOT HAVE CAUGHT THIS: check 8192 requires every legend label to be drawn on the full panel, but it looks for the label itself, and a single B is already on the screen inside BKSP, so a B row that never drew would still pass it. Check 13.23 looks for the row description on the drawn panel instead, and requires the row to exist in the table; both fail on v13.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
