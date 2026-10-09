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

# THE REC MARK SHOWS THE TIME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(Date.now()-REC.t0>REC.max*1000){ recStop(); return; }
'@ @'
  // v21.48: THE REC MARK SAYS HOW LONG, so the 3 minute stop is never a surprise (it is a page element, never in the clip)
  if(REC.mark){ var _rs=Math.floor((Date.now()-REC.t0)/1000), _rt='&#9679; REC '+fmtClock(_rs)+' / '+fmtClock(REC.max); if(REC.mark._t!==_rt){ REC.mark._t=_rt; REC.mark.innerHTML=_rt; } }
  if(Date.now()-REC.t0>REC.max*1000){ recStop(); return; }
'@

SubRx @'
function recTell(s){
'@ @'
function fmtClock(s){ s=Math.max(0,Math.floor(s)); return Math.floor(s/60)+':'+('0'+(s%60)).slice(-2); }   // v21.48: m:ss for the REC mark
function recTell(s){
'@

SubRx @'
var VER='21.47';
'@ @'
var VER='21.48';
'@

$pat = "(?m)^  now:'v21\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.48: While recording with F9, the REC mark shows how long you have recorded out of 3 minutes. Check 21.48 fails on v21.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
