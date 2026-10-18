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

# Party start clears any open window (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var mi=(P&&typeof P.mapIx==='number')?P.mapIx:0;
  WNSEEN=1;
'@ @'
  var mi=(P&&typeof P.mapIx==='number')?P.mapIx:0;
  WNSEEN=1;
  try{ var _om=document.querySelectorAll('.modal.on'), _oi; for(_oi=0;_oi<_om.length;_oi++) _om[_oi].classList.remove('on'); }catch(_om2){}   /* v30.xx (cw-partyclear): a window left open on the title (the welcome pack on a fresh profile) stayed open under the party attract and showed through it. The party starts on a clear screen */
'@

SubRx @'
var VER='30.03';
'@ @'
var VER='30.04';
'@

$pat = "(?m)^  now:'v30\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.04: The party attract starts on a clear screen. Check 30.04 fails on v30.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
