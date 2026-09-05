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

# STAMPS ONLY. No game code changes in this build: the two STILL OPEN lines it
# closes were closed by v9.79 and by v11.14 plus v11.17, and this build measures
# that on seven seeds and guards it.
SubRx @'
var VER='11.21';
'@ @'
var VER='11.22';
'@
SubRx @'
var WHATSNEW_VER='11.21';
'@ @'
var WHATSNEW_VER='11.22';
'@
SubRx @'
  'THE SECOND MAP MEASURED THE SAME WAY. The test robot ran the same 320 raids on THE COLD MILE with the building rules off and on, so the bigger map has its own number and not the first map borrowed.',
'@ @'
  'NO BUILDING LOSES ITS ROOMS AND NO CORNER IS WALLED OFF BEHIND A TABLE. Measured on seven seeds of both maps: the repair pass that used to tear out interiors now touches nothing, and the little pockets of floor behind furniture are gone with the doorway rules.',
  'THE SECOND MAP MEASURED THE SAME WAY. The test robot ran the same 320 raids on THE COLD MILE with the building rules off and on, so the bigger map has its own number and not the first map borrowed.',
'@
SubRx @'
  now:'v11.21: THE COLD MILE measured the way COLD STORAGE was at v11.19 and v11.20: 320 paired seeds, the seven building rules off and on, the robot at its pinned greed, with the follower fix in both arms. The mile is where most of the doors, partitions and furniture moved, so it gets its own number.',
'@ @'
  now:'v11.22: two STILL OPEN lines measured and closed. The v9.72 line said eight buildings on the mile stayed sealed after the repair pass; on seven seeds of both maps the pass now demolishes nothing and seals nothing, and with the yard-wall cut off it still does, so the instrument sees. The v10.40 niches behind furniture, 12 by 12 to 84 by 28, are gone on all five of its seeds with the doorway rules on, and back with them off.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
