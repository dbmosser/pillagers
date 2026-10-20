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

# SLOW FRAME TOASTS ARE HEADLINES ONLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
sayWhenFree('RESOLUTION STEPPED DOWN','sys',{sub:'Settings: Auto resolution'});
'@ @'
sayWhenFree('RESOLUTION STEPPED DOWN','sys'); /* v32.xx (cw-systoastbare): no detail line, the critic (screen 22) read it as an explaining sentence over the map. Old text: sub 'Settings: Auto resolution'. Reason: a system toast is a headline only */
'@

SubRx @'
sayWhenFree('RUNNING SLOWLY','sys',{sub:'Settings: Render resolution, Effects'});
'@ @'
sayWhenFree('RUNNING SLOWLY','sys'); /* v32.xx (cw-systoastbare): no detail line, same reason. Old text: sub 'Settings: Render resolution, Effects' */
'@

SubRx @'
var VER='32.04';
'@ @'
var VER='32.05';
'@

$pat = "(?m)^  now:'v32\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.05: The two slow-frame toasts show only their headline. Check 32.05 fails on v32.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
