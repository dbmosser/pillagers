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

# A STALE HOST UP TOP MARK CLEARS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(m.t==='raidno'){ NET.status='Player 1 is not up top.'; netRefresh(); return 'raidno'; }
'@ @'
  if(m.t==='raidno'){ NET.hostSeed=0; NET.status='Your host is not up top.'; netRefresh(); return 'raidno'; }   // v17.60: a stale mark clears with the answer
'@

SubRx @'
      if(typeof m.up==='number'&&m.up>0){ NET.hostSeed=m.up>>>0; NET.status+=' They are in a raid now: go up at the lift to join it.'; }   // v17.53: a teammate who links late can drop in
'@ @'
      NET.hostSeed=0;   // v17.60: the welcome says whether the host is up; an old mark does not outlive it
      if(typeof m.up==='number'&&m.up>0){ NET.hostSeed=m.up>>>0; NET.status+=' They are in a raid now: go up at the lift to join it.'; }   // v17.53: a teammate who links late can drop in
'@

SubRx @'
var VER='17.59';
'@ @'
var VER='17.60';
'@

$pat = "(?m)^  now:'v17\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.60: JOIN THE RAID IN PROGRESS goes away if your host turns out not to be up top. Check 17.60 fails on v17.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
