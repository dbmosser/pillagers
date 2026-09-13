$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# HARNESS REPAIR: CHECK 8.88 FORCED A 2560x1440 CANVAS BEFORE ASKING WHETHER IT COULD.
#
# The v13.40 corpus hung at check 29, v8.88, in a pane carrying frozen tabs: the console
# log (r1340b) ended at "REGRESS start 29 v8.88" and the page stopped answering.
# The check called __forceSize(2560,1440), which resizes the game and HUD canvases to
# 2560x1440 and runs the game resize, and only then read innerHeight to discover the
# pane cannot reach 1440p and SKIP. The skip was always the outcome here; the expensive
# resize came first.
#
# The viewport is now read before the big resize. If the pane is under 1400 tall, the
# check restores what it changed and returns the same SKIP text without forcing the
# 2560x1440 canvas. Where the real viewport does reach 1440, nothing changes.
SubRx @'
     // And the monitor has to reach it: 1440p is a third bigger than 1080p.
     __forceSize(2560,1440);
     var _vh=window.innerHeight||0;
'@ @'
     // And the monitor has to reach it: 1440p is a third bigger than 1080p.
     // r1340c: ask the real viewport first. The pane never reaches 1440, and forcing a
     // 2560x1440 canvas just to find that out hung a worn renderer at this check.
     var _vh=window.innerHeight||0;
     if(_vh>=1400) __forceSize(2560,1440);
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
