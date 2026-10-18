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

# THE PLAYER 2 PARTY ATTRACT STARTS ON A CLEAR SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(!arcadeSandboxIn(role)) return false;

'@ @'
    if(!arcadeSandboxIn(role)) return false;
    if(role==='p2'){ try{ var _om3=document.querySelectorAll('.modal.on'), _oj; for(_oj=0;_oj<_om3.length;_oj++) _om3[_oj].classList.remove('on'); }catch(_om4){} }   /* v30.xx (cw-p1p2), HIS ORDER (2026-10-18): "there seem to be a lot of inconsistencies between p1 and p2 games, please coordinate them better". The clear above runs before player 2 leaves its title (NET.start), and that start opens the welcome pack of a fresh save on the floor while the arcade is still off, so it stayed open under the player 2 attract and showed through the blur (player 1 showed the Undercroft). Cleared again now the arcade is on */

'@

SubRx @'
var VER='31.10';
'@ @'
var VER='31.11';
'@

$pat = "(?m)^  now:'v31\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.11: In the party arcade the player 2 screen no longer shows the welcome pack behind the party pages, it shows the Undercroft like player 1. Check 31.11 fails on v31.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
