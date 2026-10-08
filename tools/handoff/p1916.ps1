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

# THE FASHION OPERATOR PANEL KEEPS ITS FRAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    <div class="panel" style="overflow-y:auto;min-height:0">
      <h2>Your operator</h2>
      <div id="appavatar"></div>
      <!-- v10.16, his answers 18 and 19: a randomiser and three saved looks -->
      <div id="applooks" style="border-top:1px solid var(--steel-hi);padding:8px 10px"></div>

'@ @'
    <div class="panel" style="display:flex;flex-direction:column;min-height:0">
      <h2>Your operator</h2>
      <!-- v19.16, from the review (2026-10-07): an inner box scrolls, as the racks do, so the panel frame line and the heading stay put
           when the slot list scrolls; before, the whole panel scrolled and its frame line slid up through the slot rows -->
      <div id="appopscroll" style="flex:1;min-height:0;overflow-y:auto">
      <div id="appavatar"></div>
      <!-- v10.16, his answers 18 and 19: a randomiser and three saved looks -->
      <div id="applooks" style="border-top:1px solid var(--steel-hi);padding:8px 10px"></div>
      </div>

'@

SubRx @'
var VER='19.15';
'@ @'
var VER='19.16';
'@

$pat = "(?m)^  now:'v19\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.16: Scrolling the FASHION slot list keeps the panel frame and heading still. Check 19.16 fails on v19.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
