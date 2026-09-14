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

# v14.64: the game is unchanged. Check 10.37 was written before v14.49 and v14.51 and asserted their old behaviour; this build
# corrects the check, and carries the version and the DEVNOW line the parse gate needs.
SubRx @'
var VER='14.63';
'@ @'
var VER='14.64';
'@

$pat = "(?m)^  now:'v14\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.64: CHECK 10.37 FOLLOWS THE CRASH RULES OF v14.49 AND v14.51. The game is unchanged. The full corpus on v14.55 found check 10.37 red on its own: it wanted the crash location to hold the word Error, which v14.51 now drops in favour of the line and column, and its cap test fired twenty messages differing only in a number, which v14.49 now counts as one crash. The check now accepts a line and column location and its cap probes differ in letters; everything it claimed still holds',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
