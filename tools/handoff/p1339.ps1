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

# HELPING THE SURVIVOR WITH NOTORIETY: THE CACHE AND PAY LINE WAS WRITTEN OVER BY THE
# NOTORIETY LINE IN THE SAME CALL.
#
# Found by the 2026-09-13 read-only hunt, confirmed by two skeptics. strayGive says one
# sentence with where the cache is, how much he paid and what he handed over (its own
# comment says say() holds one line, so what he did is one sentence), then, with
# notoriety above zero, lowers it and says the notoriety line with a plain say() in the
# same call. He read only the notoriety line.
#
# FIX: the notoriety line goes through sayWhenFree, so it follows the pay sentence when
# that runs out. Nothing is reworded; a player with no notoriety sees what he saw before.
SubRx @'
    say('Word of that will travel too. Notoriety '+P.notoriety+'.');
'@ @'
    sayWhenFree('Word of that will travel too. Notoriety '+P.notoriety+'.');   // v13.39: waits for the cache and pay line above instead of writing over it
'@

SubRx @'
var VER='13.38';
'@ @'
var VER='13.39';
'@

$pat = "(?m)^  now:'v13\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.39: THE SURVIVOR PAY LINE WAS WRITTEN OVER BY THE NOTORIETY LINE. Found by a read-only hunt and confirmed by two skeptics: helping the survivor says one sentence with where the cache is, what he paid and what he handed over, and a player carrying notoriety then had it lowered and heard Word of that will travel too with a plain say in the same call, so he never read the pay sentence. The notoriety line now waits its turn through sayWhenFree and follows when the pay sentence runs out; a player with no notoriety sees what he saw before, and nothing is reworded. Check 13.39 stages a survivor who wants a bandage, presses E beside him through the player update at notoriety 2, confirms he was helped and notoriety fell to 1, steps the frame loop, and requires the pay sentence and then the notoriety line on screen in that order; it fails on v13.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
