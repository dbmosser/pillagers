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

# THE LIFT ROW NAMES ARE READABLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    <span style="font-size:11px;letter-spacing:.14em;color:var(--ash)">SURFACE</span>
'@ @'
    <!-- v19.81, seen on a 4K menu text scan (2026-10-08): SURFACE and WEATHER were 11px beside 14px hints; 13 now -->
    <span style="font-size:13px;letter-spacing:.14em;color:var(--ash)">SURFACE</span>
'@

SubRx @'
    <span style="font-size:11px;letter-spacing:.14em;color:var(--ash)">WEATHER</span>
'@ @'
    <span style="font-size:13px;letter-spacing:.14em;color:var(--ash)">WEATHER</span>
'@

SubRx @'
var VER='19.80';
'@ @'
var VER='19.81';
'@

$pat = "(?m)^  now:'v19\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.81: SURFACE and WEATHER on the lift page are easier to read. Check 19.81 fails on v19.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
