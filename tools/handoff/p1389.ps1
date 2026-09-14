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

# SEARCHING AND LOOT AUDIT OF 2026-09-14, finding 4: AN ITEM DROPPED AGAINST A WALL COULD LAND INSIDE
# IT AND NEVER BE SEARCHABLE. dropItem places the pile 6 to 18 units below the player with no
# wall test. Pressed against the top face of a wall, a player's centre is 11 units from it, so
# roughly two drops in five put the pile's centre inside the wall. It was drawn, but the search
# needs a clear line to the pile, so no prompt appeared from either side and the item was lost
# to him (a pillager's distance-only loot test could still take it). A pile with no clear line
# from the player is now put down at his feet.
SubRx @'
  var c=setLoot(mkContainer(p.x+rnd(-14,14),p.y+rnd(6,18),'crate'),[key]);
  c.time=0.6; c.dropped=1;
'@ @'
  var c=setLoot(mkContainer(p.x+rnd(-14,14),p.y+rnd(6,18),'crate'),[key]);
  c.time=0.6; c.dropped=1;
  // v13.89, loot audit: never inside a wall, where no search could reach it. At his feet instead.
  if(G.vseg&&!losClear(p.x,p.y,c.x,c.y,G.vseg)){ c.x=p.x; c.y=p.y; }
'@
SubRx @'
var VER='13.88';
'@ @'
var VER='13.89';
'@

$pat = "(?m)^  now:'v13\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.89: A DROPPED ITEM NEVER LANDS INSIDE A WALL. Searching and loot audit of 2026-09-14, finding 4: dropItem put the pile 6 to 18 units below the player with no wall test, so pressed against a wall about two drops in five landed inside it, drawn but unsearchable from either side. A pile with no clear line from the player is now put at his feet. Check 13.89 presses the player against the top of a solid wall, drops forty items, and requires every pile reachable in a clear line, with the wall itself blocking a pile placed 18 units down as the precondition; it fails on v13.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
