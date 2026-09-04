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
# ============ THE FRESH PROFILE HOUR, WHICH THE ALPHA NEEDS AND NOBODY HAD DONE.
# ============ A friend arrives with nothing: no runs, no stash, one gun and 600
# ============ credits. Every station on the floor was walked up to and pressed on
# ============ exactly that profile.
# ============ THE SWEEP FOUND NOTHING. Nine stations, none threw, none opened an
# ============ empty panel, none did nothing. The stash reads correctly with
# ============ nothing in it and its tabs switch and filter.
# ============ THREE TIMES MY OWN PROBE CRIED WOLF and each one is worth more than
# ============ the clean result: the stash station opens a SCREEN and not a modal,
# ============ so a modal-only sweep called it dead; the tab elements are two
# ============ levels down, so clicking the container did nothing and read as a
# ============ tab that does not work; and an owned gun draws as an ICON with no
# ============ text, so counting words called a full shelf empty.
# ============ The check that ships holds the sweep, in cells rather than in
# ============ words, so nobody has to learn those three again.
SubRx @'
var VER='11.10';
'@ @'
var VER='11.11';
'@
SubRx @'
  now:'v11.10: the crawler question from v11.07, answered. The bot cannot show that bug: over 1,647 simulated steps crawlers were inside biting distance for 693 frames and none of them were in the blind band, because the bot never crouches and its concealment never drops below 0.40 while the bug needs 0.36. It only ever reached a human who hides, which is why you hit it twice and no number I have run ever showed it. Nothing in the game changed here.',
'@ @'
  now:'v11.11: the fresh profile hour, which the alpha needs and nobody had done. A friend arrives with no runs, no stash, one gun and 600 credits; every station on the floor was walked up to and pressed on exactly that profile. Nothing threw, nothing opened empty, nothing did nothing, and the stash reads right with nothing in it. Three of my own probes cried wolf on the way, and the check that ships is written so nobody repeats them.',
'@
SubRx @'
var WHATSNEW_VER='11.10';
'@ @'
var WHATSNEW_VER='11.11';
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
