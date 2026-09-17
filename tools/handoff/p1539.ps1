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

# THE WHAT IS NEW CARD, KEPT CURRENT. WHATSNEW_VER stood at 15.27 against a build at 15.38, due for its refresh, and the card said
# nothing about the grenade sound, the controller extraction or the stall fixes of v15.28 to v15.38. Only my first card line is
# rewritten in place: it takes the new news and keeps the phrase check 15.27 reads; the second line, which carries every older
# checked phrase, is untouched, as is every other line.
SubRx @'
var WHATSNEW_VER='15.27';
'@ @'
var WHATSNEW_VER='15.39';
'@
SubRx @'
  'HEALING, THE RAID CLOCK AND YOUR HIRE. Bandages and resting stop at 85, and only a Medkit takes you past 85. The raid clock has its own siren before it runs out, a raid keeps the clock it started with, and gun slot 1 no longer goes black. Your hire leaves the crate you are searching alone and never turns up as a stranger.',
'@ @'
  'GRENADES, EXTRACTION, THE PEDDLER AND HEALING. A pillager grenade sounds where it lands, and on a controller X calls or extracts from any landed ring. A click on the open stall never fires your gun. Bandages and resting stop at 85, only a Medkit takes you past 85, and the raid clock has its own siren.',
'@
SubRx @'
var VER='15.38';
'@ @'
var VER='15.39';
'@

$pat = "(?m)^  now:'v15\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.39: THE WHAT IS NEW CARD IS CURRENT AGAIN. WHATSNEW_VER stood at 15.27 against 15.38, due for its refresh, and the card said nothing about the grenade sound, the controller extraction or the stall fixes. My first card line is rewritten in place, keeping what check 15.27 reads, and WHATSNEW_VER moves to 15.39. Check 15.39 requires the card current and naming the grenade news; it fails on v15.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
