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

# A TWO PLAYER RUN ENDS ON TIME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  return arcadeRebuild()?'new':'fail';
'@ @'
  // v34.xx (cw-joinburn): a player 2 asking in once the clock is out (the site burning, or the clock resting at 0 while the host boards) waits for the next run; the rebuild gave the run a fresh 10 minute clock, so it never ended
  if(raidClockOn()&&(G.nuking||G.timeLeft<=0)) return 'wait';
  return arcadeRebuild()?'new':'fail';
'@

SubRx @'
var VER='34.94';
'@ @'
var VER='34.95';
'@

$pat = "(?m)^  now:'v34\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.95: A two player run ends when its clock runs out, even if player 2 presses A while the site burns. Check 34.95 fails on v34.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
