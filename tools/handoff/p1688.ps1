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

# THE WHAT IS NEW CARD NAMES HIS PLAYTEST CHANGES (it had fallen sixteen builds behind).

SubRx @'
var WHATSNEW_VER='16.71';
'@ @'
var WHATSNEW_VER='16.88';
'@

SubRx @'
  'NEW FOR THE PARTY. Every player chooses a kit when the party ascends from the sector page.
'@ @'
  'FROM YOUR PLAYTEST. On a controller A rolls, B crouches, RT fires or uses what is selected, LT or a right stick click aims, X loots or reloads, Y searches in an extraction circle or patches up a teammate with the heal or plate selected on your tactical belt, a bumper tap changes the belt and a held bumper zooms, and D-pad left and right set the aim distance. A picks up and places in the backpack and on the Stash screen. Kid firing and kid mode 1/20 are in Settings, and the kit question offers TOP GEAR and RANDOM FROM STASH.',
  'NEW FOR THE PARTY. Every player chooses a kit when the party ascends from the sector page.
'@

SubRx @'
var VER='16.87';
'@ @'
var VER='16.88';
'@

$pat = "(?m)^  now:'v16\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.88: THE WHAT IS NEW CARD NAMES HIS PLAYTEST CHANGES. It was written at v16.71 and had fallen sixteen builds behind. One line goes in under the co-op line: his controller layout, picking up and placing on a controller, kid firing and kid mode 1/20, and TOP GEAR and RANDOM FROM STASH. Check 16.88 fails on v16.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
