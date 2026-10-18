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

# the superhot key is named in words, left of 1, on the F1 list and beside the Settings row (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
['`','superhot on/off']
'@ @'
['LEFT OF 1','superhot on/off']
'@

SubRx @'
html+='<div class="sdh">key: '+escHtml(keyName('Backquote'))+' (left of 1)</div>';
'@ @'
html+='<div class="sdh">key: left of 1</div>';   // cw-shkey2: in words, the tick alone was hard to see
'@

SubRx @'
var VER='31.25';
'@ @'
var VER='31.26';
'@

$pat = "(?m)^  now:'v31\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.26: The Superhot key is named in words on the F1 list and beside the Settings row: left of 1. Check 31.26 fails on v31.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
