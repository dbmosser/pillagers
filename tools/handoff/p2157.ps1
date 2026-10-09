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

# THE RUN CARD SCROLLBAR STAYS INSIDE ITS CORNERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ocwin{ max-height:min(86vh,calc(100% - 32px)); }   /* v18.97: and the card always fits inside the screen, at any menu zoom */
'@ @'
  .ocwin{ max-height:min(86vh,calc(100% - 32px)); }   /* v18.97: and the card always fits inside the screen, at any menu zoom */
  .ocwin::-webkit-scrollbar-track{ margin:16px 0; }   /* v21.57, from the 4K visual pass (V-E4): on a run card that scrolls, the scrollbar stays inside the rounded corners */
'@

SubRx @'
var VER='21.56';
'@ @'
var VER='21.57';
'@

$pat = "(?m)^  now:'v21\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.57: On a long run card, the scrollbar now stays inside the rounded corners. Check 21.57 fails on v21.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
