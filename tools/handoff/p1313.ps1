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

# v13.13 is a GUARD build. Nothing in the game changed.
SubRx @'
var VER='13.12';
'@ @'
var VER='13.13';
'@

$pat = "(?m)^  now:'v13\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.13: the price of calling the ship now has a test, which closes the last unguarded piece of the extraction system. Calling is meant to be the moment the raid turns: a siege builds through the inbound wait, and if that ever stopped happening the most expensive decision in the game would quietly become free and nothing on screen would say so. Measured on a live raid at seed 4242 with the real key and real frames: the call goes in, and siege-born hostiles appear during the countdown that were not on the landing when it started. The check has a real control rather than an assertion about a level, and it is the arm that gives it teeth: an identical raid of the same length with NO call must produce none, so the arm is measuring the call and not simply time passing. THE EXTRACTION SYSTEM IS NOW FULLY DRIVEN. Every line the v13.11 entry listed as not verified has since been measured: the inbound countdown runs, the ship lands, the window closes and the ship leaves cleanly with the ring left open and callable again, a second call works, and two separate points can be inbound at once and both behave. FOR HIS RULING, NOT MINE TO DECIDE: that last one means every extraction point on the map can be called, 1.6 seconds each, so a player can have three ships in the air and pick whichever is safest, which removes the commitment the call is supposed to be. The code anticipates moving between rings, so this may be intended. It is a rules question and it is his, and no dial has been touched',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
