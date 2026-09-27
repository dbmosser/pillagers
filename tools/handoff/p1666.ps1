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

# IN A RAID, B NEVER CLOSES A HIDDEN UNDERCROFT BACKPACK (review of v16.58, 2026-09-27).

SubRx @'
  try{ if(typeof hubBagOpen!=='undefined'&&hubBagOpen){ hubBagOpenSet(false); return true; } }catch(_hb){}
'@ @'
  // v16.66, stability (review of v16.58): the Undercroft backpack is closed here only on the floor. A teammate carried up with
  // it open kept the flag in the raid, so his first B there (v16.58 sends B here) shut the unseen floor backpack, saved its old
  // packing plan and left the map or backpack in front of him open.
  try{ if(typeof state!=='undefined'&&state==='hub'&&typeof hubBagOpen!=='undefined'&&hubBagOpen){ hubBagOpenSet(false); return true; } }catch(_hb){}
'@

SubRx @'
var VER='16.65';
'@ @'
var VER='16.66';
'@

$pat = "(?m)^  now:'v16\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.66: IN A RAID, B NEVER CLOSES A HIDDEN UNDERCROFT BACKPACK. Stability pass before a co-op session. A teammate carried up with his Undercroft backpack open kept it open out of sight, so his first B in the raid shut that unseen backpack, saved its old packing plan, and left the map or backpack in front of him open. B now closes the Undercroft backpack only in the Undercroft. Check 16.66 fails on v16.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
