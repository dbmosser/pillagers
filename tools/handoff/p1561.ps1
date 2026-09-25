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

# THE WHAT IS NEW CARD, KEPT CURRENT. WHATSNEW_VER stood at 15.51 against a build at 15.60, near its refresh, and the card said
# nothing about the end of raid card on a controller, the rack highlight or the door keys of v15.52 to v15.60. Only my first card
# line is rewritten in place: it takes the new news and keeps the phrases checks 15.27, 15.39 and 15.51 read; every other line stays.
SubRx @'
var WHATSNEW_VER='15.51';
'@ @'
var WHATSNEW_VER='15.61';
'@
SubRx @'
  'THE PAUSE BOX, PILLAGERS, GRENADES AND HEALING. Holding ESC or P no longer flickers the pause box, and a controller Menu pauses at the stall. A revived pillager keeps his gun and one you downed stays your kill. A pillager grenade sounds where it lands, only a Medkit takes you past 85, and the raid clock reads 0:10 when it says ten seconds.',
'@ @'
  'THE END OF RAID CARD, RACKS, KEYS AND THE PAUSE BOX. A controller leaves the end of raid card with B, and building your last rack never moves the highlight onto SLOT A DATA CORE. A door key is never hidden behind another locked door. Holding ESC or P no longer flickers the pause box, a pillager grenade sounds where it lands, and only a Medkit takes you past 85.',
'@
SubRx @'
var VER='15.60';
'@ @'
var VER='15.61';
'@

$pat = "(?m)^  now:'v15\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.61: THE WHAT IS NEW CARD IS CURRENT AGAIN. WHATSNEW_VER stood at 15.51 against 15.60, near its refresh, and the card said nothing about the end of raid card on a controller, the rack highlight or the door keys. My first card line is rewritten in place, keeping what checks 15.27, 15.39 and 15.51 read, and WHATSNEW_VER moves to 15.61. Check 15.61 requires the card current and naming the end of raid card news; it fails on v15.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
