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

# ============ THE TWO MESSAGES THAT MAKE YOU CHANGE YOUR PLAN NAMED THE RING
# ============ SOMETHING THE MAP DOES NOT CALL IT.
# ============
# ============ HIS RULE: one word per thing. Every surface names an extraction
# ============ point with a LETTER. The map draws EXTRACT A, EXTRACT B, EXTRACT C
# ============ off String.fromCharCode(65+index); the banner and the inbound
# ============ marker both call extLetter. Two messages do not, and they are the
# ============ two that matter most, because they are the ones that make a player
# ============ change his plan in the middle of a raid:
# ============
# ============     "Extraction 3 closes in two minutes."
# ============     "Extraction 3 is closed."
# ============
# ============ REPRODUCED on v10.74 at seed 4242 on COLD STORAGE, by running the
# ============ raid clock down to 200 seconds with the real frame loop: zones 0
# ============ and 2 close, the map draws EXTRACT A, EXTRACT B and EXTRACT C with
# ============ two of them marked CLOSED, and the message beside it says
# ============ "Extraction 3 is closed." A friend hears about 3, looks at the map
# ============ he has just been pointed at, and there is no 3 on it.
# ============
# ============ extLetter already exists and is what every other surface uses. It
# ============ takes the zone, not the index, so it cannot drift from the map.
SubRx @'
      say('Extraction '+(ci+1)+' closes in two minutes.');
'@ @'
      // v10.75, his one-word rule: the same letter the map and the banner use.
      say('Extraction '+extLetter(cz)+' closes in two minutes.');
'@

SubRx @'
      say('Extraction '+(ci+1)+' is closed.');
'@ @'
      say('Extraction '+extLetter(cz)+' is closed.');   // v10.75: the letter, as everywhere else
'@

SubRx @'
var VER='10.74';
'@ @'
var VER='10.75';
'@
SubRx @'
  now:'v10.74: the buttons at the end of a raid stay on screen. Die with a full bag and Log run and return, along with Copy report next to it, were below the bottom of the card, so the way out and the way to send the report were both behind a scroll.',
'@ @'
  now:'v10.75: the two warnings about an extraction point closing call it by the same letter the map does. They said "Extraction 3" while the map beside them drew EXTRACT A, B and C, so the one message that makes you change your plan named something that was not on the map.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
