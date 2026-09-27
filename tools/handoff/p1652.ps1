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

# A CONTROLLER NEVER LANDS ON THE CONTROLLER ROW OR, IN A SAME MACHINE PAIR, ON END THE PARTY (stability, 2026-09-27).

SubRx @'
    var el=q[i],cs=getComputedStyle(el);
'@ @'
    var el=q[i],cs=getComputedStyle(el);
    // v16.52, stability (controller audit): the PARTY window opens with the pad highlight on its CONTROLLER row, and one press of
    // A there cycled the pick: with one pad plugged in the second press chose a pad that is not there, so player 2 lost all input
    // (B could no longer shut the window), the pick was saved, and player 1 took the pad. END THE PARTY was one press with no
    // confirm and split a same machine pair until a reload. The mouse still reaches both; the pad no longer lands on them.
    if(el.id==='partypadbtn'||(el.id==='partyquit'&&typeof NET==='object'&&NET&&NET.same)) continue;
'@

SubRx @'
var VER='16.51';
'@ @'
var VER='16.52';
'@

$pat = "(?m)^  now:'v16\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.52: A CONTROLLER NEVER LANDS ON THE CONTROLLER ROW OR ON END THE PARTY. Stability pass before a co-op session. The PARTY window opened with the controller highlight on its CONTROLLER row, and one press there could hand player 2 a pad that is not plugged in, leaving no input at all, saved for next time. In a same machine pair END THE PARTY was one press with no confirm. The mouse still reaches both; a controller no longer lands on them. Check 16.52 fails on v16.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
