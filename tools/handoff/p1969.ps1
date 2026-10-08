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

# THE CONTROLLER FOCUS IS EASY TO SEE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .padfocus{ outline:2px solid var(--amber) !important; outline-offset:2px;
    box-shadow:0 0 0 4px rgba(255,192,74,.22) !important; }
'@ @'
  /* v19.69, seen on the 4K controller screenshot (2026-10-08): on a TV the 2px line was easy to lose, and on an empty slot, which
     is drawn faded, it came out a dim brown. Thicker, with a brighter ring and a soft glow, and the focused thing always at full
     strength, so player 2 finds it from the couch. */
  .padfocus{ outline:3px solid var(--amber) !important; outline-offset:2px; opacity:1 !important;
    box-shadow:0 0 0 6px rgba(255,192,74,.35), 0 0 22px 4px rgba(255,192,74,.45) !important; }
'@

SubRx @'
var VER='19.68';
'@ @'
var VER='19.69';
'@

$pat = "(?m)^  now:'v19\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.69: Player 2 can see at a glance where the controller is pointing in every menu. Check 19.69 fails on v19.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
