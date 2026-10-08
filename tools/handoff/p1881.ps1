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

# THE FASHION RACKS FILL THEIR PANEL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  <div class="hubgrid" style="grid-template-columns:260px 1fr;margin-top:6px">
    <div class="panel">
      <h2>Your operator</h2>
'@ @'
  <!-- v18.81, seen on the FASHION screenshot (2026-10-07): the racks were capped at 520 pixels, so at 1080p they stopped a third of
       the way down their panel (the EYES row cut through, blank below) while the whole grid scrolled for the tall slot list on the
       left. Each column now fills the window and scrolls on its own. -->
  <div class="hubgrid" style="grid-template-columns:260px 1fr;grid-template-rows:minmax(0,1fr);margin-top:6px">
    <div class="panel" style="overflow-y:auto;min-height:0">
      <h2>Your operator</h2>
'@

SubRx @'
    <div class="panel">
      <h2>The racks</h2>
      <div id="appavatarpicker" style="padding:8px 12px;flex:1;min-height:0;max-height:520px;overflow-y:auto"></div>
'@ @'
    <div class="panel" style="display:flex;flex-direction:column;min-height:0">
      <h2>The racks</h2>
      <div id="appavatarpicker" style="padding:8px 12px;flex:1;min-height:0;overflow-y:auto"></div>
'@

SubRx @'
var VER='18.80';
'@ @'
var VER='18.81';
'@

$pat = "(?m)^  now:'v18\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.81: In FASHION the racks use the whole panel and scroll on their own, as does the slot list on the left. Check 18.81 fails on v18.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
