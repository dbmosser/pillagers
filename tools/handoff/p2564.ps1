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

# THE PLOP IS HALF AS LOUD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    g4.gain.setValueAtTime(.07*vol,t); g4.gain.exponentialRampToValueAtTime(.001,t+.12);
'@ @'
    // v25.xx (swapquiet), HIS ORDER 2026-10-13: "plop sound when i change weapons or equip other items should be 50% quieter", then "that
    // plop sound you use for everything should be 50% quieter". This chirp is the plop: the belt keys, the wheel, the pad bumpers, an
    // equip, a drag onto a key, a menu press and the stash all play it. Its level is halved HERE, at the source, so every caller is half
    // as loud (.07 to .035). The green find is this same voice on the dry path (pickUnc) and keeps its old level; no other sound changes.
    g4.gain.setValueAtTime(.07*vol*(_fnd?1:0.5),t); g4.gain.exponentialRampToValueAtTime(.001,t+.12);
'@

SubRx @'
var VER='25.63';
'@ @'
var VER='25.64';
'@

$pat = "(?m)^  now:'v25\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.64: The short rising plop heard when you change weapons, equip items or press a menu button is now half as loud. Check 25.64 fails on v25.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
