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

# A RECORDING STOPS AT THE TITLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(Date.now()-REC.t0>REC.max*1000){ recStop(); return; }
'@ @'
  if(Date.now()-REC.t0>REC.max*1000){ recStop(); return; }
  if(typeof attTitleUp==='function'&&attTitleUp()){ recStop(); return; }   // v21.50: back on the title the canvas is empty, so a running recording stops there instead of filling with black
'@

SubRx @'
var VER='21.49';
'@ @'
var VER='21.50';
'@

$pat = "(?m)^  now:'v21\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.50: An F9 recording stops by itself when you go back to the title screen. Check 21.50 fails on v21.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
