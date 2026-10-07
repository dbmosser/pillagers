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

# A COVERED HOST WINDOW KEEPS THE KEPT RAID RUNNING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hidWant(){ return !!(typeof NET==='object'&&NET&&NET.on&&NET.role==='host'&&typeof netEntsHost==='function'&&netEntsHost()); }
'@ @'
function hidWant(){ return !!(typeof NET==='object'&&NET&&NET.on&&NET.role==='host'&&(NET.specG||(typeof netEntsHost==='function'&&netEntsHost()))); }   // v18.51, from the code comb (2026-10-07): and while the host spectates the raid it kept for the party, back on the floor with its window covered
'@

SubRx @'
var VER='18.50';
'@ @'
var VER='18.51';
'@

$pat = "(?m)^  now:'v18\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.51: When player 1 is out of the raid and their window is covered, player 2 raid keeps running normally. Check 18.51 fails on v18.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
