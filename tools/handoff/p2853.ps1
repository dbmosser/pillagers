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

# NO FINISH PROMPT WHILE YOU DIE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var e=(p&&!p.downed&&G&&!G.over&&!G.sim)?finTarget(p):null, s, z, r, f;
'@ @'
  // v28.53 (cloud-feel-finish-dying), CLOUD HUNT 2026-10-15: not in the death beat either. killPlayer clears downed and sets dying for 1.5 s, and
  // finisherTick refuses then, so FINISH stayed drawn over a downed pillager in reach while V did nothing.
  var e=(p&&!p.downed&&!p.dying&&G&&!G.over&&!G.sim)?finTarget(p):null, s, z, r, f;
'@

SubRx @'
var VER='28.52';
'@ @'
var VER='28.53';
'@

$pat = "(?m)^  now:'v28\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.53: The FINISH prompt no longer hangs over a downed pillager while you die. Check 28.53 fails on v28.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
