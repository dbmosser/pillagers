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

# HOLDING ESC OR TAB ON THE LOADOUT QUESTION NO LONGER SHUTS THE SECTOR PAGE IT PUTS BACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  e.preventDefault(); e.stopPropagation();
  // v10.10, his answer 1: EVERY window is closed through its own door. v8.12
'@ @'
  e.preventDefault(); e.stopPropagation();
  // v17.20, co-op hunt 2026-09-28: A HELD ESC OR TAB SHUTS ONE WINDOW, ONCE. Not yet on the loadout question (and Hire nobody)
  // puts back the window it was asked from in the same press, and the first key repeat half a second later pressed that
  // window's CLOSE too, so a held key left him on the bare floor and the lift put his NIGHT back to DAY. A repeat is spent
  // here, still stopped, the rule the pause box has kept since v15.49.
  if(e.repeat) return;
  // v10.10, his answer 1: EVERY window is closed through its own door. v8.12
'@

SubRx @'
var VER='17.19';
'@ @'
var VER='17.20';
'@

$pat = "(?m)^  now:'v17\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.20: Co-op hunt 2026-09-28, menus finding 5: the document capture listener that shuts the front window on ESC or TAB acted on every keydown, key repeats included. Not yet on the loadout question (and on the Hire nobody question) puts the window it was asked from back inside the same press, so the first key repeat about half a second later found that window in front and pressed its CLOSE: one held key shut two windows, and the lift then reset NIGHT to DAY, the loss v15.63 fixed. The listener now spends a key repeat once a window is open, still stopping it and preventing its default so a repeated TAB neither moves the focus nor reaches the floor or raid keys. It is the rule the pause box listener has kept since v15.49. A held key with no window open is unchanged. No number and no player text moved. Check 17.20 fails on v17.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
