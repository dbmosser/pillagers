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

# Abandoned card: the title is the plain title colour (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
else { t.textContent='ABANDONED'; t.style.color='var(--ash)';
'@ @'
else { t.textContent='ABANDONED'; t.style.color='var(--tx-1)';   // v28.xx (cw-abtitle60) the critic on screen 60 (2 of 5): "the title is dull grey, dimmer than every other text, reads as disabled". Only extract and KIA take a colour; this one is the plain title colour.
'@

SubRx @'
var VER='29.91';
'@ @'
var VER='29.92';
'@

$pat = "(?m)^  now:'v29\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.92: Abandoned card: the title is easier to read. Check 29.92 fails on v29.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
