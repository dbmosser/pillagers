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

# Hide PvP on the title (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<button class="deploy ghost moderow" id="modepvp" data-mode="pvp">2 PLAYER PVP (SAME MACHINE)</button>
'@ @'
<button class="deploy ghost moderow" id="modepvp" data-mode="pvp" style="display:none">2 PLAYER PVP (SAME MACHINE)</button><!-- v28.xx (cw-nopvp), his answer Q72 (2026-10-18): "Hide PvP". The row stays in the page so netTitleInit still wires it; it is not shown and the arrows skip it -->
'@

SubRx @'
<div class="modelater"><button class="deploy ghost moderow" id="modepvpsrv" data-mode="pvpsrv" disabled>PVP (SERVER)</button><span>coming later</span></div>
'@ @'
<div class="modelater" style="display:none"><button class="deploy ghost moderow" id="modepvpsrv" data-mode="pvpsrv" disabled>PVP (SERVER)</button><span>coming later</span></div>
'@

SubRx @'
var VER='30.24';
'@ @'
var VER='30.25';
'@

$pat = "(?m)^  now:'v30\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.25: The title no longer lists PvP. Check 30.25 fails on v30.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
