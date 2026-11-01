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

# EXTRACTED CARD: ROOM UNDER THE BONUS LINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
lines.push('<span style="color:var(--amber)">extraction bonus +$'+_xb.toLocaleString()+'</span>'); }
'@ @'
lines.push('<span class="ocbonus" style="display:block;margin:4px 0 24px;font-size:16px;color:var(--tx-2)">extraction bonus +$'+_xb.toLocaleString()+'</span>'); }   // v37.xx (cw-m1bonusgap): the critic on screen 38 found the line 12px from the stat strip; a block with 24px under it
'@

SubRx @'
var VER='37.25';
'@ @'
var VER='37.26';
'@

$pat = "(?m)^  now:'v37\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.26: the extraction bonus line is its own block in the secondary text colour with 24px under it Check 37.26 fails on v37.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
