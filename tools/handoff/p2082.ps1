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

# FEWER BIG ROBOTS FOR PLAYER 2 TOO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        nm=rr()<.5?mkSentry(ss.x,ss.y):mkCrawler(ss.x,ss.y);
'@ @'
        // v20.82, from the whole-game bug hunt of 2026-10-08 (H61): THREE IN TEN ARE SENTRIES HERE TOO. The siege a spectating host runs
        // for his party kept the old one in two when v18.06 (his son: fewer big robots) made the siege three in ten, so a ring player 2
        // held after the host was out drew more sentries than the same call brings solo. The same single draw, the same share now.
        nm=rr()<.3?mkSentry(ss.x,ss.y):mkCrawler(ss.x,ss.y);
'@

SubRx @'
var VER='20.81';
'@ @'
var VER='20.82';
'@

$pat = "(?m)^  now:'v20\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.82: In co-op, after the host is out, a ship call brings the same few sentries it does solo. Check 20.82 fails on v20.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
