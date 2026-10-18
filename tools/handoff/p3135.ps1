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

# GUN CARD HINT ROW, RUN INFO ROWS FIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var _gtop=trDemo()?LH(62):LH(90), _gh=trDemo()?LH(58):LH(100);
'@ @'
var _gtop=trDemo()?LH(62):LH(66), _gh=trDemo()?LH(58):LH(76); /* v28.xx (cw-cardhint), the critic (2026-10-19): the career card is 76 high, the backpack hint left the top (order: name, ammo, one quiet row) so the card has no dead strip over the name */
'@

SubRx @'
ctx.fillText(padOn()?padB(pbn(8)+'  BACKPACK'):(keyLabel('KeyB','B')+' / '+keyLabel('KeyI','I')+'  BACKPACK'),W-16,by-LH(70));
'@ @'
ctx.textAlign='left'; ctx.fillText(padOn()?padB(pbn(8)+'  BACKPACK'):(keyLabel('KeyB','B')+' / '+keyLabel('KeyI','I')+'  BACKPACK'),(typeof _wpx==='number'&&_wpx===_wpx)?_wpx+LH(10):W-LH(130),by); ctx.textAlign='right'; /* v28.xx (cw-cardhint), the critic (2026-10-19): the backpack hint sits on the bottom row of the card, left, opposite the item count; it was above the gun name */
'@

SubRx @'
var pad=8, lh=LH(13), bw=trBW(), inner=bw-pad*2;
'@ @'
var pad=8, lh=LH(13), bw=trBW(), inner=bw-pad*2-6; /* v28.xx (cw-cardhint), the critic (2026-10-19): a long contract row ended on the panel edge (rows are drawn 6 in from the margin); the wrap leaves the 6 */
'@

SubRx @'
var VER='31.34';
'@ @'
var VER='31.35';
'@

$pat = "(?m)^  now:'v31\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.35: The career gun card puts the backpack hint on its bottom row, and run info rows stay inside the panel. Check 31.35 fails on v31.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
