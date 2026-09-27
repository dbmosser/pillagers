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

# THE KIT WAIT NEVER STARTS A RAID FROM INSIDE A RAID (stability pass before his co-op session, 2026-09-27).

SubRx @'
  NET.kitWait=null; clearTimeout(w.tm); NET.status=''; netRefresh();
  w.f();
'@ @'
  NET.kitWait=null; clearTimeout(w.tm); NET.status=''; netRefresh();
  // v16.48, stability: the wait only ever sends the party up from the Undercroft floor. If the host went up another way while
  // it ran (the quick ascent on R at the lift), its 15 s timer ran out inside the raid and started a second raid on a new seed,
  // with no end to the first and the teammate left behind on the old one.
  if(typeof state!=='undefined'&&state!=='hub') return false;
  w.f();
'@

SubRx @'
var VER='16.47';
'@ @'
var VER='16.48';
'@

$pat = "(?m)^  now:'v16\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.48: THE KIT WAIT NEVER STARTS A RAID FROM INSIDE A RAID. Stability pass before a co-op session. When the host asks the party for its kit, a 15 second timer sends everyone up if a teammate is slow to answer. If the host went up another way while it ran (the quick ascent on R at the lift), the timer ran out inside the raid and started a second raid on a new seed, leaving the teammate on the old one. The timer now only ever sends the party up from the Undercroft floor. Check 16.48 fails on v16.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
