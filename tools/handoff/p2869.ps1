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

# LIQUOR SCREEN EFFECT HALVED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var dr=8.5*(1-Math.exp(-buzzLevel('drunk')*1.8/7)), ac=8.5*
'@ @'
  // v28.69 (lean4), HIS ORDER (2026-10-15): "one shot of liquor is too intense on the fx, turn it down". The Liquor screen strength dr (the warp, the sway and the menu
  // panels all read it) tops out at 4.25 now, half of the old 8.5; a single dose reads 0.96, was 1.93. Blotter (ac) and the gameplay veer and slow are unchanged.
  var dr=4.25*(1-Math.exp(-buzzLevel('drunk')*1.8/7)), ac=8.5*
'@

SubRx @'
var VER='28.68';
'@ @'
var VER='28.69';
'@

$pat = "(?m)^  now:'v28\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.69: A shot of liquor now bends the screen half as much. Check 28.69 fails on v28.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
