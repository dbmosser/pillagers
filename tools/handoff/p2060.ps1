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

# THE SURVIVOR YOU HELPED NEVER SHOOTS YOU (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
          var _mOwn=!!(b.owner&&b.owner.merc);
'@ @'
          // v20.60, from the whole-game bug hunt of 2026-10-08 (H4): AND SO DOES A ROUND FROM THE SURVIVOR YOU HELPED. On his walk to
          // a ring he shoots machines within 380, and a round that went wide of a crawler you were fighting hit you as hard as a
          // hostile man's: it could put you down, and the card named him. A helped survivor who has not turned on you is on your
          // side, so his rounds pass through you (and the party up top) as your hire's do. A hostile survivor's rounds still hit.
          var _mOwn=!!(b.owner&&(b.owner.merc||(b.owner.kind==='stray'&&b.owner.helped&&!b.owner.hostile)));
'@

SubRx @'
var VER='20.59';
'@ @'
var VER='20.60';
'@

$pat = "(?m)^  now:'v20\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.60: The survivor you help no longer hits you with his shots at the machines. Check 20.60 fails on v20.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
