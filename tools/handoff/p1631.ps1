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

# CHECK 15.24 FOLLOWS HIS NEWER NOTE (the clock alarm volume). Correction of the v16.30 record.

SubRx @'
  var MARKS=[300,240,180,120,60,30], tlNow=0, i;
'@ @'
  var MARKS=[300,240,180,120,60,30], tlNow=0, i;   // v16.31: the warning keeps its own rising shape (v15.24) at the quieter level he asked for (v16.30)
'@

SubRx @'
var VER='16.30';
'@ @'
var VER='16.31';
'@

$pat = "(?m)^  now:'v16\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.31: CHECK 15.24 FOLLOWS HIS NEWER NOTE. v16.30 made the clock alarms quieter on his note; check 15.24 still demanded they be louder than the machine alarm, and v16.30 shipped with it failing, which its notes wrongly said passed. The check now reads what keeps the warning distinct, its three rising sweeps, and that it is quieter than it was. No game change beyond a comment. Check 16.31 fails on v16.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
