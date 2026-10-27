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

# FROZEN REDRAW STAYS STEADY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(state==='raid'&&G&&!G.over&&!G.sim&&!HID.fromWorker&&!document.hidden&&DRS.frameStart!==undefined){
'@ @'
if(dt>0&&state==='raid'&&G&&!G.over&&!G.sim&&!HID.fromWorker&&!document.hidden&&DRS.frameStart!==undefined){   // v28.xx (cw-steadyframe): a frozen redraw (dt 0) is not a real frame, so it never feeds the auto resolution window; on a slow PC its stale frame gap pushed the scale down between two redraws and the picture changed
'@

SubRx @'
var VER='34.97';
'@ @'
var VER='34.98';
'@

$pat = "(?m)^  now:'v34\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.98: A redraw that does not advance the clock never changes the auto resolution. Check 34.98 fails on v34.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
