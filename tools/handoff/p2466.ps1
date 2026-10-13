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

# THE FASHION RACKS FILL THE PANEL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
'@ @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
  /* vNN.xx, UI REDESIGN ui5q1j (his #50, from the AAA judge of the Fashion shot): THE RACKS FILL THE PANEL. The rack tiles were
     96px, so a requirement such as 12 EXTRACTIONS ran edge to edge against both borders and PUT 3 WARDENS DOWN (0 OF 3) broke into
     five lines over the name; the racks used only the left half of the panel; and a locked tile looked almost like an owned one.
     The racks are a grid of tiles at least 132px wide that share the whole width, the requirement line is not letter-spaced past
     the edges, and a locked tile carries a small lock in its top right corner. No word changed. */
  #root #appavatarpicker > div:has(> .costile){ display:grid !important; grid-template-columns:repeat(auto-fill,minmax(132px,1fr)); gap:8px !important; }
  #root #appavatarpicker .costile{ position:relative; width:auto; min-width:0; padding:10px 8px; }
  #root #appavatarpicker .cosname{ letter-spacing:.02em; line-height:1.25; }
  #root #appavatarpicker .cosreq{ letter-spacing:.03em; line-height:1.25; overflow-wrap:anywhere; }
  #root #appavatarpicker .costile.lock::before{ content:''; position:absolute; top:6px; right:6px; width:14px; height:14px; opacity:1;
    background:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3E%3Cpath d='M4 7V5a4 4 0 0 1 8 0v2h1v8H3V7h1zm2 0h4V5a2 2 0 0 0-4 0v2z' fill='%23aaa498'/%3E%3C/svg%3E") center/contain no-repeat; }
'@

SubRx @'
var VER='24.65';
'@ @'
var VER='24.66';
'@

$pat = "(?m)^  now:'v24\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.66: The Fashion racks fill the panel with wider tiles, and locked tiles show a lock. Check 24.66 fails on v24.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
