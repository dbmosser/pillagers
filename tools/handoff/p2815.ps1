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

# THE NINTH BELT KEY STAYS ON SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(_gi=0;_gi<1;_gi++) h+='<div style="background:rgba(20,23,26,.55);border-radius:4px;padding:4px 5px 3px"><div style="display:flex;gap:4px">'+_gh[_gi]+'</div><div style="text-align:center;font-size:11px;letter-spacing:.1em;color:var(--ash);margin-top:2px">'+_gn[_gi]+'</div></div>';
'@ @'
  // v28.15 (cloud-menus-belt-key9-fits), CLOUD HUNT 2026-10-15: THE NINTH KEY STAYS IN THE LOADOUT PANEL. The group box took the width of nine keys at
  // their full size (min-content), so it never shrank and key 9 ran past the panel, off screen at 1440p. min-width:0 lets the box take the room there is
  // and the keys shrink on one row, square, as v18.98 and v23.14 meant.
  for(_gi=0;_gi<1;_gi++) h+='<div style="background:rgba(20,23,26,.55);border-radius:4px;padding:4px 5px 3px;min-width:0"><div style="display:flex;gap:4px">'+_gh[_gi]+'</div><div style="text-align:center;font-size:11px;letter-spacing:.1em;color:var(--ash);margin-top:2px">'+_gn[_gi]+'</div></div>';
'@

SubRx @'
var VER='28.14';
'@ @'
var VER='28.15';
'@

$pat = "(?m)^  now:'v28\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.15: All nine tactical belt keys on the stash now stay inside the LOADOUT panel at 1440p and 4K. Check 28.15 fails on v28.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
