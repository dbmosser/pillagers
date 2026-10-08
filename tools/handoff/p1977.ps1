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

# THE STASH KEY ROW IS READABLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    font-size:10.5px; letter-spacing:.13em; color:var(--ash); text-transform:uppercase; }
'@ @'
    font-size:12.5px; letter-spacing:.13em; color:var(--ash); text-transform:uppercase; }   /* v19.77, seen on a 4K menu text scan (2026-10-08): 10.5px, the smallest print in any menu, on a row half empty */
'@

SubRx @'
    background:var(--bone); color:#11161d; font-size:10.5px; font-weight:700;
'@ @'
    background:var(--bone); color:#11161d; font-size:12.5px; font-weight:700;
'@

SubRx @'
var VER='19.76';
'@ @'
var VER='19.77';
'@

$pat = "(?m)^  now:'v19\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.77: The key row under the stash is easier to read. Check 19.77 fails on v19.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
