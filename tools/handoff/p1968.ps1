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

# THE PAD CONTROLS PANEL NAMES NO KEYBOARD KEY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
MH=MROW*_mr+LH(16);
'@ @'
MH=MROW*_mr+((PAD&&PAD.on)?LH(6):LH(16));
'@

SubRx @'
    ctx.fillText('H  full list',mx,my+LH(7)+MROW*_mr+LH(3));
'@ @'
    // v19.68, seen on the 4K controller screenshot (2026-10-08): on a controller (player 2 in co-op) no button opens the full list, so
    // H  full list named a keyboard key the pad player cannot press. On a pad the line and its row are left out.
    if(!(PAD&&PAD.on)) ctx.fillText('H  full list',mx,my+LH(7)+MROW*_mr+LH(3));
'@

SubRx @'
var VER='19.67';
'@ @'
var VER='19.68';
'@

$pat = "(?m)^  now:'v19\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.68: On a controller the controls panel lists only pad buttons. Check 19.68 fails on v19.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
