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

# THE KEYS WINDOW SCALES WITH THE SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    (document.getElementById('partymodal')&&document.getElementById('partymodal').parentNode||document.body).appendChild(m);   // v17.85: beside the other windows, in their font
'@ @'
    (document.getElementById('partymodal')&&document.getElementById('partymodal').parentNode||document.body).appendChild(m);   // v17.85: beside the other windows, in their font
    try{ if(typeof applyMenuZoom==='function') applyMenuZoom(); }catch(_kz){}   // vNN.xx (ui5q1v, the 4K Keys shot): built after the zoom was set, so it takes the menu zoom now, as every window does
'@

SubRx @'
var VER='24.79';
'@ @'
var VER='24.80';
'@

$pat = "(?m)^  now:'v24\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.80: The Keys window is drawn at the right size on a 4K screen. Check 24.80 fails on v24.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
