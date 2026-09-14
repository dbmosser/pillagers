$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
    var _hubBusy=!!(_titleUp||document.querySelector('.modal.on')||document.querySelector('.imenu')||   // v12.06: the character screen counts here too
                    document.getElementById('hub').classList.contains('on'));
'@ @'
    // v14.46, floor audit finding 2: THE OPEN BACKPACK COUNTS AS BUSY. It freezes the floor like a window, but SPACE and H
    // still acted behind it: SPACE clanked and left a full roll to start the moment it closed, and H toggled a panel hidden
    // under it. Only H and SPACE read this; ESC, TAB and P keep their own backpack rule below.
    var _hubBusy=!!(_titleUp||document.querySelector('.modal.on')||document.querySelector('.imenu')||   // v12.06: the character screen counts here too
                    document.getElementById('hub').classList.contains('on')||hubBagOpen);
'@
SubRx @'
var VER='14.45';
'@ @'
var VER='14.46';
'@

$pat = "(?m)^  now:'v14\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.46: SPACE AND H WAIT WHILE THE FLOOR BACKPACK IS OPEN. The open backpack freezes the floor, but SPACE behind it clanked and left a full roll to start when it closed, and H toggled a panel hidden under it. Both now wait for the backpack to close, like any window. Check 14.46 presses SPACE with the backpack shut, then SPACE and H with it open; it fails on v14.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
