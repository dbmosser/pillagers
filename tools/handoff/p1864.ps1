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

# THE SHOP SHOWS ITS ITEMS BIG (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .vcell .ic{ width:44% !important; height:44% !important; }
'@ @'
  .vcell .ic{ width:60% !important; height:60% !important; object-fit:contain; }   /* v18.64, seen on the shop screenshot (2026-10-07): the new pictures were 44% of a shop, craft or hire tile, small in a lot of empty tile; 60% still leaves room for the name */
'@

SubRx @'
var VER='18.63';
'@ @'
var VER='18.64';
'@

$pat = "(?m)^  now:'v18\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.64: Items in the shop, craft and hire lists are shown about a third bigger. Check 18.64 fails on v18.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
