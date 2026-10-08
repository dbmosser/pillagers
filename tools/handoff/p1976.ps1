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

# THE STASH FILTER ROW IS READABLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        d.style.fontSize='10.5px';
'@ @'
        d.style.fontSize='13px';   // v19.76, seen on a 4K menu text scan (2026-10-08): 10.5px was the smallest print in any menu, in a row with room to spare
'@

SubRx @'
sq.style.cssText='flex:1;min-width:0;font-size:11px;padding:3px 6px';
'@ @'
sq.style.cssText='flex:1;min-width:0;font-size:13px;padding:4px 8px';
'@

SubRx @'
sb.id='stashsort'; sb.style.fontSize='10.5px';
'@ @'
sb.id='stashsort'; sb.style.fontSize='13px';
'@

SubRx @'
var VER='19.75';
'@ @'
var VER='19.76';
'@

$pat = "(?m)^  now:'v19\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.76: The stash category tabs, search box and SORT are easier to read. Check 19.76 fails on v19.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
