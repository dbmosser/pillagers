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
    HB.near=null; HB.eLock=true; keys={};
'@ @'
    HB.near=null; HB.eLock=true; keys={};
    // v14.45, floor audit finding 1: A ROLL DOES NOT CARRY THROUGH A RAID. Station actions still fire mid-roll, so a roll
    // toward the lift and R inside its 0.38 s froze the floor with the roll part done; he was placed at the lamp above and on
    // the first free frame back rolled up to 160 units out of it in the old direction. The roll ends with the arrival.
    if(HB.player) HB.player.rollT=0;
'@
SubRx @'
var VER='14.44';
'@ @'
var VER='14.45';
'@

$pat = "(?m)^  now:'v14\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.45: A ROLL DOES NOT CARRY THROUGH A RAID. A roll toward the lift followed by R inside its 0.38 seconds froze the floor mid-roll, and coming back he was placed at the lamp and then rolled up to 160 units out of it. Arriving on the floor now ends any roll. Check 14.45 sets a roll part done and arrives on the floor; it fails on v14.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
