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

# KEYS LIST: LOWER CASE WORDS, FLAT KEY CAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #keyslist .keybtn.wait{ box-shadow:none; }
'@ @'
#root #keyslist .keybtn.wait{ box-shadow:none; }
/* v31.xx (cw-pset7) critic c-31z round 2 (Pad buttons 74 at 2, P0: "every action label starts with a capital letter ... his order is all lower case"; P1: "the 3px bottom bevel is a shadow-style edge the guide bans"; "the last line is hard-clipped at the footer"). Now: the Keys and Pad buttons rows show their words as written (lower case, the ::first-letter capital is gone), key caps are a flat 1px line box with no bevel, and the list keeps 32px under its last row. */
#root #keyslist .row b::first-letter{ text-transform:none; }
#root #keyslist .keybtn{ box-shadow:none; }
#root #keyslist{ padding-bottom:var(--sp-4); }
'@

SubRx @'
var VER='31.38';
'@ @'
var VER='31.39';
'@

$pat = "(?m)^  now:'v31\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.39: The Keys and Pad buttons lists show lower case words and flat key caps. Check 31.39 fails on v31.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
