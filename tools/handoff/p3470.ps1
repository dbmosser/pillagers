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

# THE LOST PAD TAG COLOURS COME FROM THE COLOUR TABLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #pausebox.padlost h3 .pl.p1{ color:#f5b73b; }
#root #pausebox.padlost h3 .pl.p2{ color:#5fd7e8; }

'@ @'
/* v34.70 (cw-padtagcol): the p1 and p2 tag colours (his r3-13: P1 amber, P2 cyan) are set from the shared colour table in padLostTitle, not typed here as raw colours. */

'@

SubRx @'
    var sp=document.createElement('span'); sp.className='pl '+same; sp.textContent=same;

'@ @'
    var sp=document.createElement('span'); sp.className='pl '+same; sp.textContent=same;
    sp.style.color=(same==='p2')?'#5fd7e8':UIC.warn;   // v34.70 (cw-padtagcol): P1 amber (the warn token), P2 cyan, his r3-13

'@

SubRx @'
var VER='34.69';
'@ @'
var VER='34.70';
'@

$pat = "(?m)^  now:'v34\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.70: The lost pad title looks the same; its p1 and p2 tag colours no longer sit as raw colours in the css. Check 34.70 fails on v34.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
