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

# TRYING ON OUTFITS KEEPS THE PREVIEWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function cosLookKey(){ return ['outfit','skin',
'@ @'
// v19.49, from the review (2026-10-08): the worn outfit is left out. The piece previews are painted with the outfit off (v19.09) and the
// outfit previews never keyed on it, so trying on outfits threw away all 57 pictures and repainted them unchanged on every click.
function cosLookKey(){ return ['skin',
'@

SubRx @'
var VER='19.48';
'@ @'
var VER='19.49';
'@

$pat = "(?m)^  now:'v19\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.49: Clicking through outfits in FASHION no longer repaints every picture. Check 19.49 fails on v19.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
