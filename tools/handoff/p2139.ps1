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

# THE BACKPACK WORDS LINE UP WITH THE GRID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  hudPanel(x,y,PW,hh,0.96);   // v18.13: the one HUD panel
'@ @'
  hudPanel(x,y,PW,hh,0.96);   // v18.13: the one HUD panel
  // v21.39, from the 4K visual pass of 2026-10-09 (W-D1): THE BACKPACK WORDS LINE UP WITH THE GRID. Every line of text in this panel
  // sat 11 pixels in from the panel edge at every screen size, while the tiles start a margin in (MARG, which grows with the screen),
  // so at 4K the title, the gun, its numbers and the item line hugged the left edge of the panel about 75 pixels left of the first
  // tile, and the key line, the rounds and the price hugged the right edge. From here on x and PW are the text column, which starts
  // where the grid starts and ends where it ends. The panel, the box the mouse uses (G.bagPanel, recorded above) and the grid are
  // where they were.
  var _tm=Math.max(0,(gx-x)-11); x+=_tm; PW-=2*_tm;
'@

SubRx @'
var VER='21.38';
'@ @'
var VER='21.39';
'@

$pat = "(?m)^  now:'v21\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.39: The words in the backpack line up with the item tiles instead of hugging the panel edges. Check 21.39 fails on v21.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
