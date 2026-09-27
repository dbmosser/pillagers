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

# A SECOND CONTROLLER GOES TO PLAYER 1 (his controller rule of 2026-09-27).

SubRx @'
  if(side!=='p2') return (pick>=0&&pick<n&&gps[pick]&&gps[pick].connected)?pick:-1;
'@ @'
  if(side!=='p2'){
    if(pick>=0) return (pick<n&&gps[pick]&&gps[pick].connected)?pick:-1;
    // v16.35, HIS RULE of 2026-09-27: player 1 plays keyboard and mouse, player 2 takes the first controller, and a second
    // controller goes to player 1. With no pick the host plays the first connected pad player 2 is not on.
    taken=netPadFor('p2',taken,-1,gps);
    for(i=0;i<n;i++) if(i!==taken&&gps[i]&&gps[i].connected) return i;
    return -1;
  }
'@

SubRx @'
  if(NET.same==='host') return netPadIxOk(NET.padIx);
'@ @'
  if(NET.same==='host') return (netPadIxOk(NET.padIx)>=0)?NET.padIx:-2;   // v16.35: with no pick, the second controller player 2 hands over
'@

SubRx @'
  return (side==='p2')?'THE FIRST FREE CONTROLLER':'NO CONTROLLER, KEYBOARD AND MOUSE';
'@ @'
  return (side==='p2')?'THE FIRST FREE CONTROLLER':'KEYBOARD AND MOUSE, AND A SECOND CONTROLLER';   // v16.35
'@

SubRx @'
var VER='16.34';
'@ @'
var VER='16.35';
'@

$pat = "(?m)^  now:'v16\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.35: A SECOND CONTROLLER GOES TO PLAYER 1. His rule: player 1 plays keyboard and mouse, player 2 takes the first controller, and a second controller goes to player 1. The host with no pick played no pad at all; it now plays the first connected pad player 2 is not on, in front or handed over. A pick on the CONTROLLER row still wins. Check 15.77 restaged on the two lines that asserted the old rule. Check 16.35 fails on v16.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
