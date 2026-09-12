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

# HIS TELEMETRY, run #3 of the 2026-09-11 export, on v12.85: DEAD, 3860 credits
# lost, lastHit YOUR OWN CHARGE, killer OTHER.
#
# The death card names it correctly, because it prefers lastHitName. Everything
# that KEEPS a record does not: the run record, the export line, the run list,
# the career killers tally and the damage-by-source table all file it as other,
# which is the bucket for a thing the game could not identify. The game could
# identify it perfectly.
#
# v8.23 is where this came from. It found that an ENEMY grenade was reported as
# YOUR OWN CHARGE and bucketed under other, and gave the enemy case a real source
# while leaving your own charge on the placeholder it was already using.
#
# This matters because it is his most common recorded cause of death. A man who
# reads his own reports cannot see that he has killed himself three times if
# every one of them says other.
SubRx @'
  var _fSrc=_fMine?'other':(f.by.kind||'raider');
'@ @'
  // v13.14, HIS TELEMETRY: your own charge is not an unidentified source. It was
  // filed as other, the bucket for something the game cannot name, while the
  // very next line names it exactly. So the death card said YOUR OWN CHARGE and
  // every record that outlives the card said other, which is how three deaths to
  // his own frag charge became three deaths to nothing in particular.
  var _fSrc=_fMine?'yourself':(f.by.kind||'raider');
'@

SubRx @'
      dmg:{sentry:0,crawler:0,raider:0,snitch:0,other:0},
'@ @'
      dmg:{sentry:0,crawler:0,raider:0,snitch:0,yourself:0,other:0},
'@

SubRx @'
var VER='13.13';
'@ @'
var VER='13.14';
'@

$pat = "(?m)^  now:'v13\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.14: from HIS OWN TELEMETRY rather than from a queue. Run 3 of the 2026-09-11 export, on v12.85: dead, 3860 credits lost, lastHit YOUR OWN CHARGE, killer OTHER. The death card names it right because it prefers the last hit name, and everything that KEEPS a record does not: the run record, the export line, the run list, the career killers tally and the damage-by-source table all filed it as other, which is the bucket for a thing the game could not identify, while the line directly below named it exactly. It came from v8.23, which found that an ENEMY grenade was being reported as YOUR OWN CHARGE and bucketed under other, and gave the enemy case a real source while leaving your own charge on the placeholder it was already using. It is his most common recorded cause of death and he has now done it three times, and a man reading his own reports could not see that, because every one of them said other. Reproduced before it was touched: a real player charge, the shape the throw actually pushes, at his feet on a live raid, and the pending killer came back other with the last hit name already reading YOUR OWN CHARGE. It is now yourself, so the export says killer yourself, the run list says by yourself, the career tally has a row for it and the damage table has a bucket declared for it rather than one appearing by accident. The control is the v8.23 case: an enemy charge must still report the thrower kind and must not be swallowed by this',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
