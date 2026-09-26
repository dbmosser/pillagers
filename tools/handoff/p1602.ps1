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

# PARTLY CLOUDY DOES NOT HOLD. Weather audit finding 10 (audit-wwhovd0n0.json), its own fix.

SubRx @'
  G.wxTurnsLeft--;
'@ @'
  G.wxTurnsLeft--;
  // v16.02, weather audit finding 10: PARTLY CLOUDY DOES NOT HOLD. A turn INTO partly with no turn left said This will not hold
  // and then held to extraction, since the rain-or-storm break above runs only when partly is the current sky. Partly exists to
  // turn, so a turn into it keeps one turn back for that break. No draw is added here; the break draws as it always has.
  if(nw.id==='partly'&&G.wxTurnsLeft<1) G.wxTurnsLeft=1;
'@

SubRx @'
var VER='16.01';
'@ @'
var VER='16.02';
'@

$pat = "(?m)^  now:'v16\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.02: PARTLY CLOUDY DOES NOT HOLD. Weather audit finding 10. A weather turn into Partly Cloudy said This will not hold, and when it was the last turn of the raid it held to extraction. A turn into partly now keeps one turn back, so the rain or storm break it announces still comes. No number moved and map building is untouched. Check 16.02 fails on v16.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
