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

# THREE LINES OF PLAYER TEXT TELL THE TRUTH AND USE HIS WORDS (review 2026-09-27).

SubRx @'
, and every raid is still played alone.</div>
'@ @'
, and when the host takes the party up, everyone ascends into the same raid.</div>
'@

SubRx @'
  'GRENADES, BELT KEYS, STASH, WARDROBE, SAVES AND STORMS.
'@ @'
  'GRENADES, BELT KEYS, STASH, RACKS, SAVES AND STORMS.
'@

SubRx @'
  'NEW FOR THE PARTY. Every player chooses a kit at the lift. 
'@ @'
  'NEW FOR THE PARTY. Every player chooses a kit when the party ascends from the sector page. 
'@

SubRx @'
var VER='16.64';
'@ @'
var VER='16.65';
'@

$pat = "(?m)^  now:'v16\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.65: THREE LINES OF PLAYER TEXT TELL THE TRUTH AND USE HIS WORDS. The PARTY window said every raid is still played alone, untrue since the party began to ascend together; it now says the party ascends into the same raid. A what is new line said WARDROBE, a word he retired; it says RACKS. The party line said every player chooses a kit at the lift, but the quick ascent asks nobody; it now says when the party ascends from the sector page. Check 16.65 fails on v16.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
