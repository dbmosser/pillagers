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

# THE TITLE FILLS THE SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@ @'
  /* vNN.xx, UI REDESIGN ui5q2a (his #50, from the AAA judge of the title shots 01, 44 and 57): THE TITLE SITS ON THE WHOLE SCREEN.
     The Undercroft floor walking behind the title is smaller than the screen, so at 1080p and 4K it showed as a lighter rectangle
     with dark bands round it, like a letterboxed screenshot. The title glass now blurs the floor a little and closes to near black
     towards every edge, so no edge of the floor shows and the people walking still read as a world behind the menu. */
  #root #title.on{ background:radial-gradient(ellipse 58% 60% at 50% 45%, rgba(8,9,10,0) 40%, rgba(8,9,10,.95) 88%),
    linear-gradient(90deg, rgba(17,19,21,.8) 0%, rgba(17,19,21,.9) 26%, rgba(17,19,21,.9) 74%, rgba(17,19,21,.8) 100%);
    -webkit-backdrop-filter:blur(4px); backdrop-filter:blur(4px); }
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@

SubRx @'
var VER='25.02';
'@ @'
var VER='25.03';
'@

$pat = "(?m)^  now:'v25\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.03: The title backdrop is soft and fades to black at the edges, with no rectangle showing. Check 25.03 fails on v25.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
