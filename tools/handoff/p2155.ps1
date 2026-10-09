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

# THE PILLAGER BOARD ENDS UNDER ITS LAST NAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var boxH=HOr.c?LH(18):(LH(20)+(_rShown+_rSum)*LH1+LH(6));
'@ @'
  var boxH=HOr.c?LH(18):(LH(20)+(_rShown+_rSum)*LH1-LH(3));   // v21.55, from the 4K visual pass (V-B11): the board ended a full empty row under the last name; now the room under it matches the room over the heading
'@

SubRx @'
var VER='21.54';
'@ @'
var VER='21.55';
'@

$pat = "(?m)^  now:'v21\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.55: The CURRENT PILLAGERS board no longer has an empty row at the bottom. Check 21.55 fails on v21.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
