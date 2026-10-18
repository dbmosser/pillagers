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

# PACK ALL AND CLEAR SIT BY THE PACK LABEL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
min-width:5.8em">PACK</span>';
'@ @'
min-width:5.8em">PACK</span><button class="pkb" data-pa="all">PACK ALL</button><button class="pkb" data-pa="none">CLEAR</button>';
'@

SubRx @'
  h+='<button class="pkb" data-pa="all">ALL</button><button class="pkb" data-pa="none">NONE</button>';
'@ @'
  // v28.xx (cw-packbulk), quality pass: the two whole-pack buttons stood after the CASH chip and read as cash buttons beside its own MAX. They sit right after the PACK label now and say what they do, PACK ALL and CLEAR.
'@

SubRx @'
var VER='29.25';
'@ @'
var VER='29.26';
'@

$pat = "(?m)^  now:'v29\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.26: On the pre-raid screen, Pack all and Clear sit next to the Pack label. Check 29.26 fails on v29.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
