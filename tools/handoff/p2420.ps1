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

# NO ROLL IN THE DROP-IN HOLD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function tryRoll(){
  var p=G.player;
'@ @'
function tryRoll(){
  var p=G.player;
  // v24.20, HIS ORDER 2026-10-12 (his #39, full controller navigation): NO ROLL IN THE DROP-IN HOLD. After a demo respawn he stands
  // frozen for 3 seconds (DROPPING IN 3 2 1) inside his spawn shield, but SPACE, and the pad A that sends the same key, still started
  // a roll: the roll took the shield down while he could not move, so the press meant to be ready threw his cover away before he
  // was in. While the hold runs the roll does nothing; it works the moment he drops in.
  if(G.arcade&&typeof ARCADE==='object'&&ARCADE&&(+ARCADE.holdT||0)>0) return;
'@

SubRx @'
var VER='24.19';
'@ @'
var VER='24.20';
'@

$pat = "(?m)^  now:'v24\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.20: Rolling during the drop-in countdown no longer drops your spawn shield. Check 24.20 fails on v24.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
