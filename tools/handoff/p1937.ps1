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

# THE RUN CARD BUTTON STRIP SITS ON THE EDGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    padding:30px 52px 26px; border-radius:6px; max-width:880px; max-height:86vh;
'@ @'
    padding:30px 52px 0; border-radius:6px; max-width:880px; max-height:86vh;   /* v19.37: no bottom padding, so the pinned button row sits on the card edge (its 26px moved to the last line) */
'@

SubRx @'
  <div style="font-size:11px;color:var(--ash);margin-top:8px;max-width:520px;line-height:1.5">Copy report puts
'@ @'
  <div style="font-size:11px;color:var(--ash);margin-top:8px;max-width:520px;line-height:1.5;margin-bottom:26px">Copy report puts
'@

SubRx @'
var VER='19.36';
'@ @'
var VER='19.37';
'@

$pat = "(?m)^  now:'v19\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.37: Nothing shows under the run card buttons on a long card. Check 19.37 fails on v19.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
