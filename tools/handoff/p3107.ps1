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

# HOW TO PLAY SAYS LEFT STICK AND RIGHT STICK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeAttKeys(cell,txt){

'@ @'
// v28.xx (cw-sticks), the critic on 46 (3 of 5): "L STICK and R STICK are cryptic". The how to play keys say left stick and right stick in full.
function arcadeKeyWord(s){ return String(s==null?'':s).replace(/^L STICK$/i,'LEFT STICK').replace(/^R STICK$/i,'RIGHT STICK'); }
function arcadeAttKeys(cell,txt){
  txt=arcadeKeyWord(txt);

'@

SubRx @'
var VER='31.06';
'@ @'
var VER='31.07';
'@

$pat = "(?m)^  now:'v31\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.07: The how to play card says left stick and right stick in full. Check 31.07 fails on v31.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
