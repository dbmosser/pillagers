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

# EVERY KEY THAT DOES SOMETHING IS ON THE KEYS LIST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ['KeyT','offer an item to a teammate'],['KeyN','ping'],['KeyP','pause']];
'@ @'
  ['KeyT','offer an item to a teammate'],['KeyN','ping'],['KeyP','pause'],
  // v18.54, FROM THE CODE COMB (2026-10-07): EVERY KEY THAT DOES SOMETHING IS ON THE LIST. G, Q, Z, V and O work in the raid but were
  // not here, so binding an action onto one of them did not swap: reload on G kept R as reload too, and the belt item on G was gone
  // with no way back but RESET. They are listed now, so a bind onto one swaps like any other.
  ['KeyG','use the selected belt item'],['KeyQ','switch throwable'],['KeyZ','drop an item for a teammate'],['KeyV','emotes'],['KeyO','order your hire']];
'@

SubRx @'
  if(typeof logical!=='string'||typeof physical!=='string'||!physical||physical==='Escape'||physical==='Tab'||/^Digit[1-9]$/.test(physical)) return false;
'@ @'
  if(typeof logical!=='string'||typeof physical!=='string'||!physical||physical==='Escape'||physical==='Tab'||physical==='Backspace'||physical==='Backquote'||/^Digit[1-9]$/.test(physical)) return false;   // v18.54: and never BACKSPACE (the cursor) or the key left of 1 (Superhot), which keep their own jobs
'@

SubRx @'
var VER='18.53';
'@ @'
var VER='18.54';
'@

$pat = "(?m)^  now:'v18\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.54: CHANGE KEYS lists G, Q, Z, V and O too, and moving an action onto any key swaps the two cleanly. Check 18.54 fails on v18.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
