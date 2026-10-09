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

# THE HOT GROUND KEEPS MOVING AFTER THE HOST IS OUT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    tickRaiderWaves(wdt);   // v20.37 (H10): new pillagers still arrive for the party; only a raid frame ran this, and that stops with the host run
'@ @'
    tickRaiderWaves(wdt);   // v20.37 (H10): new pillagers still arrive for the party; only a raid frame ran this, and that stops with the host run
    try{ tickHot(wdt); }catch(_sth){}   // v21.24, from the review of 2026-10-09 (R2): and the hot ground keeps moving for the party (v20.39 left it to the host, whose raid frame stops)
'@

SubRx @'
  if(!G.sim){
    say('The hot ground has moved. Check your map.');
'@ @'
  if(!G.sim&&!(typeof NET==='object'&&NET&&NET.specTick)){   // v21.24 (R2): a host watching his party makes no line or sound for it; the party is told by the world word
    say('The hot ground has moved. Check your map.');
'@

SubRx @'
var VER='21.23';
'@ @'
var VER='21.24';
'@

$pat = "(?m)^  now:'v21\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.24: In co-op, the hot ground keeps moving for player 2 after the host is out. Check 21.24 fails on v21.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
