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

# THE DAY AND WEATHER BUTTONS LINE UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    <span style="font-size:13px;letter-spacing:.14em;color:var(--ash)">SURFACE</span>
'@ @'
    <!-- v21.33, from the whole-game bug hunt of 2026-10-08 (W-B3), seen on the 4K lift picture: THE TWO CHOICE ROWS SHARE ONE COLUMN.
         SURFACE is a little narrower than WEATHER, so DAY started a few pixels left of SURPRISE ME under it. Both row names now take
         the same width, a little wider than WEATHER, so the first button of each row starts in the same place. -->
    <span style="font-size:13px;letter-spacing:.14em;color:var(--ash);min-width:5.8em">SURFACE</span>
'@

SubRx @'
    <span style="font-size:13px;letter-spacing:.14em;color:var(--ash)">WEATHER</span>
'@ @'
    <span style="font-size:13px;letter-spacing:.14em;color:var(--ash);min-width:5.8em">WEATHER</span>
'@

SubRx @'
var VER='21.32';
'@ @'
var VER='21.33';
'@

$pat = "(?m)^  now:'v21\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.33: On the lift page the DAY and SURPRISE ME buttons start in one column. Check 21.33 fails on v21.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
