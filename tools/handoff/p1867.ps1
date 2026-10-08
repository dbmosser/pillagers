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

# THE TITLE ROWS ARE SOLID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #modemenu button.moderow{ min-width:440px; padding:9px 28px; font-size:12px; letter-spacing:.22em; }
'@ @'
  #modemenu button.moderow{ min-width:440px; padding:9px 28px; font-size:12px; letter-spacing:.22em; }
  #modemenu button.moderow.ghost{ background:rgba(9,13,28,.88); }   /* v18.67, seen on the title screenshot (2026-10-07): the mode rows were see-through, so the Undercroft behind the title showed inside them, a head in 2 PLAYER CO-OP; solid now, the gold outline kept */
'@

SubRx @'
border-radius:3px;padding:8px 11px;background:rgba(0,0,0,.28);display:flex;justify-content:space-between;gap:10px;align-items:center
'@ @'
border-radius:3px;padding:8px 11px;background:rgba(9,13,28,.82);display:flex;justify-content:space-between;gap:10px;align-items:center
'@

SubRx @'
var VER='18.66';
'@ @'
var VER='18.67';
'@

$pat = "(?m)^  now:'v18\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.67: The title buttons and save rows are solid, with nothing showing through them. Check 18.67 fails on v18.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
