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

# THE FEEDBACK WINDOW SAYS CLOSE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    <button id="fbcancel" data-esc="1" style="padding:8px 22px">CANCEL</button>
'@ @'
    <!-- v26.10 (nightfix1), from the overnight regression run of 2026-10-13: HIS RULE, CLOSE AND ESC ON EVERY MENU. The feedback window (v24.50) was the one window whose way out said CANCEL. It says CLOSE, like the rest. -->
    <button id="fbcancel" data-esc="1" style="padding:8px 22px">CLOSE</button>
'@

SubRx @'
var VER='26.09';
'@ @'
var VER='26.10';
'@

$pat = "(?m)^  now:'v26\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.10: The feedback window has a CLOSE button now, like every other window. Check 26.10 fails on v26.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
