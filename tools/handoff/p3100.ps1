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

# TITLE: SAVES BLOCK AS WIDE AS THE MODES, NAME BOX LOWER CASE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root #slotpanel{ max-width:900px; margin-left:auto; margin-right:auto; }
'@ @'
  #root #slotpanel{ max-width:var(--menu-w); margin-left:auto; margin-right:auto; }   /* v28.xx (cw-title-saves), the critic on screen 01 (3 of 5): "the saves block is 898px wide under a 558px mode column". One column: the saves block is as wide as the mode buttons (--menu-w). */
'@

SubRx @'
    if(pin) pin.value=P.pname||'';
'@ @'
    window.titleNameShown=function(n){ return n==='PILLAGER'?'pillager':n; };   // v28.xx (cw-title-saves), the critic on screen 01 (P0): the name box showed PILLAGER in capitals, and every word on screen is lower case (his order 2026-10-18). Only the default name is lowered; a name he typed keeps its letters.
    if(pin) pin.value=titleNameShown(P.pname||'');
'@

SubRx @'
if(_nv&&_nv!==P.pname){ P.pname=_nv; saveProfile(); }
'@ @'
if(_nv&&_nv!==P.pname&&_nv!==titleNameShown(P.pname)){ P.pname=_nv; saveProfile(); }   // v28.xx (cw-title-saves): the lowered default is not a new name
'@

SubRx @'
var VER='30.99';
'@ @'
var VER='31.00';
'@

$pat = "(?m)^  now:'v30\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.00: The saves block lines up with the mode buttons and the name box is lower case. Check 31.00 fails on v30.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
