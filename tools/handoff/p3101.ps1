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

# THE ARCADE PAUSE BOX HAS NO HOSTING LINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var _hw=document.getElementById('pausehost'); if(_hw) _hw.style.display=netHostHolds()?'':'none';   // v16.38: the host is told what quitting costs the party

'@ @'
    var _hw=document.getElementById('pausehost'); if(_hw) _hw.style.display=netHostHolds()?'':'none';   // v16.38: the host is told what quitting costs the party
    if(_hw&&typeof ARCADE==='object'&&ARCADE&&ARCADE.on) _hw.style.display='none';   // v30.xx (cw-p1p2), HIS ORDER (2026-10-18): "please coordinate them better". Only the player 1 pause box carried this sentence; in the party arcade both pause boxes are alike (the window still asks before it closes)

'@

SubRx @'
var VER='31.00';
'@ @'
var VER='31.01';
'@

$pat = "(?m)^  now:'v31\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.01: The party arcade pause box is now the same in both windows: the extra hosting line only the player 1 window showed is gone. Check 31.01 fails on v31.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
