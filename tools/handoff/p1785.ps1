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

# THE KEYS WINDOW IN THE GAME FONT, AND IT SCROLLS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
'<div id="keyslist"></div><div class="pbox" style="display:flex;gap:8px;margin-top:14px"><button id="keysreset"
'@ @'
'<div id="keyslist" style="max-height:58vh;overflow-y:auto;padding-right:6px"></div><div class="pbox" style="display:flex;gap:8px;margin-top:14px"><button id="keysreset"
'@

SubRx @'
    document.body.appendChild(m);
    document.getElementById('keysreset').onclick=
'@ @'
    (document.getElementById('partymodal')&&document.getElementById('partymodal').parentNode||document.body).appendChild(m);   // v17.85: beside the other windows, in their font
    document.getElementById('keysreset').onclick=
'@

SubRx @'
var VER='17.84';
'@ @'
var VER='17.85';
'@

$pat = "(?m)^  now:'v17\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.85: The CHANGE KEYS window is in the game font and scrolls. Check 17.85 fails on v17.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
