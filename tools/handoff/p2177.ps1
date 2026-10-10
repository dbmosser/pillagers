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

# A LISTENER AT YOUR SIDE KEEPS STRIKING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        // Recovering from its own blow: it is still coming, but slowly, and that
'@ @'
        // v21.77, HIS NOTE (2026-10-09): "listeners and crawlers exhibiting weird behavior where they don't hurt me when they charge me,
        // particularly if im standing still". A Listener follows you only by the sound of your feet, so once it reached a man who had
        // stopped moving it heard nothing, waited out its seven seconds at the spot and went dormant pressed against him, and a
        // dormant Listener never strikes. Measured: five blows in the first seven seconds, then asleep at his side for good. A thing
        // touching you has found you, as the crawler rule of v11.07 says: inside its reach plus a stride it keeps you, still or
        // crouched, and it never settles while you are in reach. Out of reach, standing still still loses it, as it always has.
        if((CFG.listenTouch===undefined?1:CFG.listenTouch)&&!p.downed&&(dist(e,p)-(e.r+(p.r||11)))<=MELEE_REACH+20){ e.heardX=p.x; e.heardY=p.y; e.millT=0; }
        // Recovering from its own blow: it is still coming, but slowly, and that
'@

SubRx @'
var VER='21.76';
'@ @'
var VER='21.77';
'@

$pat = "(?m)^  now:'v21\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.77: A Listener that reaches you no longer falls asleep at your side when you stand still. It keeps striking. Check 21.77 fails on v21.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
