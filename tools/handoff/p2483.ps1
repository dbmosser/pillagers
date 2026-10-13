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

# NO DARK INK ON THE STATS PAGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
'@ @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
  /* vNN.xx, UI REDESIGN ui5q1q (his #50, from the lint of the Mainframe YOUR STATS shot): the caption over the run log (EVERY RUN,
     NEWEST FIRST) took the dark ink meant for the cream cards and read at about 3:1 on the graphite page; it is the second text
     colour there now. The cream cards keep their ink. */
  #root #opane_rec .crlab{ color:var(--tx-2); }
'@

SubRx @'
  <div class="tpane" id="opane_rec" style="display:none;flex-direction:column;flex:1;min-height:0">
'@ @'
  <!-- vNN.xx (ui5q1q): a long page that scrolls on purpose, marked for the visual lint -->
  <div class="tpane" id="opane_rec" data-lint-scroll style="display:none;flex-direction:column;flex:1;min-height:0">
'@

SubRx @'
var VER='24.82';
'@ @'
var VER='24.83';
'@

$pat = "(?m)^  now:'v24\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.83: The caption over the run log on YOUR STATS can be read. Check 24.83 fails on v24.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
