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

# HAUL REVEAL: PLAIN EMPTY SLOTS, BALANCED ROWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root .ocwin .haulit[data-r="gold"]{ border-bottom-color:var(--r-gold) !important; }

'@ @'
  #root .ocwin .haulit[data-r="gold"]{ border-bottom-color:var(--r-gold) !important; }
  /* v28.xx (cw-endslots), the critic on 76 (3 of 5, P0): "nine empty boxes with coloured bottom bars above the revealed items". The rarity rules just above (same weight, later) beat the .hid rule, so a slot not yet shown gave away its rarity. A hidden slot is now a plain grey slot, and the strip wraps balanced (7 and 6, not 9 and 3). */
  #root .ocwin .haulit.hid[data-r]{ border-bottom-color:var(--ui-line) !important; }
  #root .ocwin .haulstrip{ text-wrap:balance; }

'@

SubRx @'
var VER='31.57';
'@ @'
var VER='31.58';
'@

$pat = "(?m)^  now:'v31\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.58: A tile not yet shown is a plain grey slot. The haul strip wraps in even rows. Check 31.58 fails on v31.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
