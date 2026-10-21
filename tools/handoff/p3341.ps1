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

# AIR STRIKE BAR SITS LOWER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  y=Math.round(top-64*z-g8-bh);
  E=[HUDBOX.gear,handPlateBox(),
'@ @'
  y=Math.round(top-g8-bh);   // v28.xx (cw-airlow), HIS NOTE 2026-10-20: "airstrike bar needs to be much lower": the 64 px lift is gone, the plate stands on the belt with the 8 px gap; the clearance loop below still lifts it over a real obstacle
  E=[HUDBOX.gear,handPlateBox(),
'@

SubRx @'
var VER='33.40';
'@ @'
var VER='33.41';
'@

$pat = "(?m)^  now:'v33\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.41: The air strike plate stands just over the belt at the right end, and still lifts only for a real obstacle like an item in hand. Check 33.41 fails on v33.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
