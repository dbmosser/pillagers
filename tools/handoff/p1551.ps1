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

# THE WHAT IS NEW CARD, KEPT CURRENT. WHATSNEW_VER stood at 15.39 against a build at 15.50, due for its refresh, and the card said
# nothing about the pause box, pillager body and raid clock fixes of v15.40 to v15.50. Only my first card line is rewritten in place:
# it takes the new news and keeps the phrases checks 15.27 and 15.39 read; the second line and every other line are untouched.
SubRx @'
var WHATSNEW_VER='15.39';
'@ @'
var WHATSNEW_VER='15.51';
'@
SubRx @'
  'GRENADES, EXTRACTION, THE PEDDLER AND HEALING. A pillager grenade sounds where it lands, and on a controller X calls or extracts from any landed ring. A click on the open stall never fires your gun. Bandages and resting stop at 85, only a Medkit takes you past 85, and the raid clock has its own siren.',
'@ @'
  'THE PAUSE BOX, PILLAGERS, GRENADES AND HEALING. Holding ESC or P no longer flickers the pause box, and a controller Menu pauses at the stall. A revived pillager keeps his gun and one you downed stays your kill. A pillager grenade sounds where it lands, only a Medkit takes you past 85, and the raid clock reads 0:10 when it says ten seconds.',
'@
SubRx @'
var VER='15.50';
'@ @'
var VER='15.51';
'@

$pat = "(?m)^  now:'v15\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.51: THE WHAT IS NEW CARD IS CURRENT AGAIN. WHATSNEW_VER stood at 15.39 against 15.50, due for its refresh, and the card said nothing about the pause box, pillager body and raid clock fixes. My first card line is rewritten in place, keeping what checks 15.27 and 15.39 read, and WHATSNEW_VER moves to 15.51. Check 15.51 requires the card current and naming the pause box news; it fails on v15.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
