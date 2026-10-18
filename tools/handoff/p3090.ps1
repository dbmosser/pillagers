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

# TITLE: FEWER KEY HINTS, 48PX BUTTONS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      <b style="color:var(--bone)">CTRL</b> crouch &nbsp;
      <b style="color:var(--bone)">E</b> search &nbsp;
      <b style="color:var(--bone)">B / I</b> backpack &nbsp;
      <b style="color:var(--bone)">M</b> map &nbsp;

'@ @'
      <!-- v28.xx (cw-title-legend), the critic on screen 01 (3 of 5, P1): "nine key hints are gameplay controls on a menu, clutter, too small to read from a couch; cut it". Five stay (move, aim, fire, search, F1 for the rest); crouch, backpack and map live in the F1 controls list. -->
      <b style="color:var(--bone)">E</b> search &nbsp;

'@

SubRx @'
#root #title #titleres button{ min-height:44px; padding:0 24px; font-size:16px; }
'@ @'
#root #title #titleres button{ min-height:48px; padding:0 24px; font-size:16px; }   /* v28.xx (cw-title-legend), the critic (3 of 5, P2): the top-right buttons 44 to 48px, the guide button height --btn-h-sm. */
'@

SubRx @'
var VER='30.89';
'@ @'
var VER='30.90';
'@

$pat = "(?m)^  now:'v30\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.90: The title key line is shorter and the top-right buttons are taller. Check 30.90 fails on v30.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
