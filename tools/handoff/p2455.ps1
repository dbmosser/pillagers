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

# A LOCKED TILE KEEPS ITS NAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
'@ @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
  /* vNN.xx, UI REDESIGN ui5q1i (his #50, from the lint of the craft shot): A LOCKED TILE KEEPS ITS NAME. A recipe you cannot make
     yet (and a locked tile anywhere in the shop) faded the whole tile to 42 percent, so its name read at about 2.3:1 against the
     cell. The picture and the price fade as before; the name stays readable in the second text colour, as on the locked Fashion
     tiles (ui6b), and a pad highlight on it no longer fades it twice. */
  #root .vcell.locked, #root .vcell.locked.padfocus{ opacity:1 !important; border-color:var(--ui-line); }
  #root .vcell.locked > *:not(.vlbl){ opacity:.42; }
  #root .vcell.locked .vlbl{ opacity:1; color:var(--tx-2); }
'@

SubRx @'
var VER='24.54';
'@ @'
var VER='24.55';
'@

$pat = "(?m)^  now:'v24\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.55: A recipe you cannot make yet dims its picture but keeps its name readable. Check 24.55 fails on v24.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
