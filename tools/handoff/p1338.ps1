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

# KILLING THE LAST PILLAGER A KILL CONTRACT NEEDS: "CONTRACT DONE" WAS WRITTEN OVER BY
# "NAME WILL REMEMBER THAT." IN THE SAME STEP.
#
# Found by the 2026-09-13 read-only hunt, confirmed by two skeptics. In one updateEnts
# call the kill handler credits the kill (contractKill), contractStep says CONTRACT
# DONE on the last kill, and then, for a named pillager, the grudge block says the
# grudge line with a plain say(). say() keeps one line, so the only in-raid word that
# the contract is done never reached a frame; the CONDITIONS panel drops a finished
# contract, so only the report after the raid showed it.
#
# FIX: the grudge line goes through sayWhenFree, so it waits behind whatever is showing.
# With nothing showing it appears at once, as before. No wording or numbers change.
SubRx @'
          say(e.name+' will remember that.');
'@ @'
          sayWhenFree(e.name+' will remember that.');   // v13.38: waits its turn. contractKill above may have just said the contract is done in this same step, and a plain say wrote over it before any frame drew it.
'@

SubRx @'
var VER='13.37';
'@ @'
var VER='13.38';
'@

$pat = "(?m)^  now:'v13\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.38: CONTRACT DONE WAS WRITTEN OVER BY THE GRUDGE LINE. Found by a read-only hunt and confirmed by two skeptics: killing the last pillager a kill contract needs ran the contract step, which said CONTRACT DONE, and then the grudge block for a named pillager, which said NAME will remember that, with a plain say in the same step. say keeps one line, so the only in-raid word that the contract was done never reached the screen, and the conditions panel drops a finished contract. The grudge line now waits its turn through sayWhenFree: with nothing showing it appears at once, and with a line showing it follows when that one runs out. No wording or numbers change. Check 13.38 stages a kill contract one pillager short, fires a real player round into a downed named pillager through the frame loop, confirms the kill finished the contract and wrote the grudge, and requires the contract line and then the grudge line on screen in that order; it fails on v13.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
