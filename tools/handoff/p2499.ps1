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

# A BAR WITH NOTHING TO DO FOLDS AWAY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    _cb.disabled=!_rdy;
'@ @'
    _cb.disabled=!_rdy;
    // vNN.xx, UI REDESIGN ui5q2n (his #50, from the AAA judge of the Mainframe and stash shots): A BAR WITH NOTHING TO DO FOLDS AWAY.
    // With nothing finished, a full width greyed NOTHING COMPLETED TO CLAIM bar sat over the contract list, the widest thing on the
    // tab and the one that did nothing. It shows only when something can be claimed; the stash SELL bar does the same.
    _cb.style.display=_rdy?'':'none';
'@

SubRx @'
    _sb.disabled=!_sn;
'@ @'
    _sb.disabled=!_sn;
    _sb.style.display=_sn?'':'none';   // vNN.xx (ui5q2n): with nothing to sell the full width greyed bar folds away
'@

SubRx @'
var VER='24.98';
'@ @'
var VER='24.99';
'@

$pat = "(?m)^  now:'v24\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.99: The claim and sell bars show only when there is something to claim or sell. Check 24.99 fails on v24.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
